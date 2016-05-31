defmodule ExBlocktrail do
  use HTTPoison.Base


  def latest_block(_) do
    url = "/btc/block/latest?"
    with {:ok, response} <- ExBlocktrail.get(url),
          latest_block_data = BlockData.new(response.body),
      do: {:ok, latest_block_data}
  end

  def block_txs(block_hash, options) do
    url = "/btc/block/#{block_hash}/transactions?" <> URI.encode_query(%{page: options.page})
    with {:ok, response} <- ExBlocktrail.get(url),
          paged_data = PagedResponse.new(response.body),
      do: {:ok, paged_data}
  end

  def all_block_txs(block_hash) do

  end

  def process_url(url) do
    key = Application.get_env(:ex_blocktrail, :api_key)
    url = url
    |> YURI.parse
    |> YURI.put("api_key", key)
    |> to_string

    "https://api.blocktrail.com/v1" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end

end

defmodule BlockData do
  defstruct [
    hash: "",
    height: "",
    block_time: "",
    difficulty: "",
    merkleroot: "",
    prev_block: "",
    next_block: "",
    byte_size: "",
    confirmations: 0,
    transactions: "",
    value: "",
    miningpool_name: "",
    miningpool_url: "",
    miningpool_slug: "" ]

    use ExConstructor
    use Vex.Struct

    validates :hash, presence: true

end


defmodule PagedResponse do
  defstruct [
    current_page: 0,
    per_page: 0,
    total: 0,
    data: %{}]

  use ExConstructor
  use Vex.Struct
end

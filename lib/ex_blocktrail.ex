defmodule ExBlocktrail do
  use HTTPoison.Base

  def latest_block(token) do
    url = String.downcase(token) <> "/block/latest"
    with {:ok, response} <- ExBlocktrail.get(url),
          latest_block_data = BlockData.new(response.body),
      do: {:ok, latest_block_data}
  end

  def process_url(url) do
    key = Application.get_env(:ex_blocktrail, :api_key)
    "https://api.blocktrail.com/v1/" <> url <> "?" <> URI.encode_query(%{api_key: key})
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

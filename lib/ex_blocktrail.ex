defmodule BlocktrailCom do
  use HTTPoison.Base

  @spec latest_block(String.t()) :: BlockData.t()
  def latest_block(_) do
    url = "/btc/block/latest?"
    with {:ok, response} <- BlocktrailCom.get(url),
          latest_block_data = BlockData.new(response.body),
      do: {:ok, latest_block_data}
  end

  @spec block_txs(String.t()) :: { atom, PagedResponse.t()}
  def block_txs(block_hash, options \\ []) do
    page = Keyword.get(options, :page, 0)
    limit = Keyword.get(options, :limit, 200)
    url = "/btc/block/#{block_hash}/transactions?" <> URI.encode_query(%{page: page, limit: limit})
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = BlocktrailCom.get(url)
    case body do
      %{"code" => 401, "msg" => "Missing API key"} -> {:error, "Missing API key"}
      _ -> {:ok, PagedResponse.new(body)}
    end
  end

  @spec block_txs_all(String.t()) :: [BlockData.t()]
  def block_txs_all(block_hash) do
    {:ok, paged_res} = block_txs(block_hash)
    hd_page_tx_num = length(paged_res.data)
    txs = cond do
      hd_page_tx_num >= paged_res.total -> paged_res.data
      hd_page_tx_num < paged_res.total ->
        num_pages = div(paged_res.total, paged_res.per_page) + 1
        next_page = paged_res.current_page + 1
        paged_res.data ++ Enum.flat_map(next_page..num_pages, fn page_index ->
          {:ok, paged_res} = block_txs(block_hash, page: page_index) #TODO: concurrent txs retrieval
          paged_res.data
        end)
    end

    {:ok, txs}
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
  @moduledoc """
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

  """
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
  @moduledoc """
  defstruct [
    current_page: 0,
    per_page: 0,
    total: 0,
    data: %{}]
  """
  defstruct [
    current_page: 0,
    per_page: 0,
    total: 0,
    data: %{}]

  use ExConstructor
  use Vex.Struct
end

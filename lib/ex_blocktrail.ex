defmodule BlocktrailCom do
  @moduledoc """
  Collection of API wrappers and helpers
  """
  use HTTPoison.Base
  alias BlocktrailCom.{BlockData, PagedResponse}

  @spec latest_block(String.t) :: BlockData.t
  def latest_block(_) do
    url = "/btc/block/latest?"
    with {:ok, response} <- BlocktrailCom.get(url),
      latest_block_data = BlockData.new(response.body),
    do: {:ok, latest_block_data}
  end

  @spec block_txs(String.t) :: { atom, PagedResponse.t }
  def block_txs(block_hash, options \\ []) do
    page = Keyword.get(options, :page, 0)
    limit = Keyword.get(options, :limit, 200)
    url = "/btc/block/#{block_hash}/transactions?" <> URI.encode_query(%{page: page, limit: limit})
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = BlocktrailCom.get(url)
    {:ok, PagedResponse.new(body)}
  end

  @doc """
  Helper function that returns success tuple with all transactions of requested block.
  """
  @spec block_txs_all(String.t) :: [ BlockData.t ]
  def block_txs_all(block_hash) do
    {:ok, paged_res} = block_txs(block_hash)
    txs = if length(paged_res.data) >= paged_res.total do
      paged_res.data
    else
      num_pages = div(paged_res.total, paged_res.per_page) + 1
      paged_res.data ++ Enum.flat_map(2..num_pages, fn page_index ->
        {:ok, paged_res} = block_txs(block_hash, page: page_index) #TODO: concurrent txs retrieval
        paged_res.data
      end)
    end

    {:ok, txs}
  end

  @doc """
  Possible arguments for options are [sort_dir: "asc" | "desc", limit: 0-200, page: 0..n]
  """
  def all_blocks(options \\ []) do
    q_map = options
    |> Enum.drop_while(fn {_,v} -> is_nil(v) end)
    |> Enum.into(%{})
    |> Map.put_new(:limit, 200)

    url = "/btc/all-blocks?" <> URI.encode_query(q_map)
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = BlocktrailCom.get(url)
    {:ok, PagedResponse.new(body)}
  end


  def reduce_paged_response do
    #TODO extract traversal and folding of PagedResponse from block_tx_all
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
    body = body
    |> Poison.decode!
    case body do
      %{"code" => 401, "msg" => "Missing API key"} -> throw("Missing API key")
      _ -> body
    end
  end

end

defmodule BlocktrailCom.BlockData do
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
    hash: nil,
    height: nil,
    block_time: nil,
    difficulty: nil,
    merkleroot: nil,
    prev_block: nil,
    next_block: nil,
    byte_size: nil,
    confirmations: 0,
    transactions: nil,
    value: nil,
    miningpool_name: nil,
    miningpool_url: nil,
    miningpool_slug: nil ]

    use ExConstructor
    use Vex.Struct

    validates :hash, [length: 64, presence: true]
  end


  defmodule BlocktrailCom.PagedResponse do
    @moduledoc """
    defstruct [
    current_page: 0,
    per_page: 0,
    total: 0,
    data: %{}]
    """
    defstruct [
      current_page: nil,
      per_page: nil,
      total: nil,
      data: nil]

      use ExConstructor
      use Vex.Struct
    end

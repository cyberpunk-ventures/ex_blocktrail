defmodule ExBlocktrail do
  use HTTPoison.Base


  def latest_block(token) do
    String.downcase(token) <> "/block/latest"
  end

  def process_url(url) do
    key = Application.get_env(:ex_blocktrail, :api_key)
    "https://api.blocktrail.com/v1/" <> url <> "?" <> URI.encode_query(%{api_key: key})
  end




end

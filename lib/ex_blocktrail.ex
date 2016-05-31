defmodule ExBlocktrail do
  use HTTPoison.Base

  def latest_block(token) do
    url = String.downcase(token) <> "/block/latest"
    with {:ok, response} <- ExBlocktrail.get(url),
      do: {:ok, response.body}
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

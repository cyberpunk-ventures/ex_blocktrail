defmodule ExBlocktrailTest do
  use ExUnit.Case
  doctest ExBlocktrail

  test "latest BTC block" do
    api_key = System.get_env("BLOCKTRAIL_API_KEY")
    Application.put_env(:ex_blocktrail, :api_key, api_key)
    {:ok, block_data} = ExBlocktrail.latest_block("BTC")
    assert Vex.valid?(block_data)
  end
end

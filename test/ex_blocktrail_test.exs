defmodule ExBlocktrailTest do
  use ExUnit.Case
  doctest ExBlocktrail


  test "latest BTC block" do
    {:ok, block_data} = ExBlocktrail.latest_block("BTC")
    assert Vex.valid?(block_data)
  end

  test "block txs" do

  end
end

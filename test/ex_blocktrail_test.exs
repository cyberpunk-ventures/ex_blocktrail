defmodule BlocktrailComTest do
  use ExUnit.Case, async: true
  doctest BlocktrailCom

  test "latest BTC block" do
    {:ok, block_data} = BlocktrailCom.latest_block("BTC")
    assert Vex.valid?(block_data)
  end

  test "block txs" do
    {:ok, txs} = BlocktrailCom.block_txs("000000000003ba27aa200b1cecaad478d2b00432346c3f1f3986da1afd33e506")
    assert length(txs.data) == 4
  end

  test "all block txs with 1 page of results" do
    {:ok, txs} = BlocktrailCom.block_txs_all("00000000000000003021634037ebf164433fa819aac82d4dac8852e14a1a6952")
    assert length(txs) == 41
  end

  test "all block txs with more than 1 page of results" do
    {:ok, txs} = BlocktrailCom.block_txs_all("00000000000000001bb82a7f5973618cfd3185ba1ded04dd852a653f92a27c45")
    assert length(txs) == 779
  end
end

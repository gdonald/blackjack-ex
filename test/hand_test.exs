defmodule HandTest do
  use ExUnit.Case

  alias Blackjack.Hand

  describe "Hand.final_count/2" do
    test "a soft count with [1, 10] returns 21" do
      values = [1, 10]
      assert Hand.final_count(values, :soft) == 21
    end

    test "a hard count with [1, 10] returns 11" do
      values = [1, 10]
      assert Hand.final_count(values, :hard) == 11
    end
  end
end

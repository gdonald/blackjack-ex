defmodule HandSpec do
  use ESpec
  alias Blackjack.Hand

  let :values, do: [1, 10]

  describe "Hand.final_count/2" do
    it "a soft count with [1, 10] returns 21" do
      expect Hand.final_count(values(), :soft) |> to(eq 21)
    end

    it "a hard count with [1, 10] returns 11" do
      expect Hand.final_count(values(), :hard) |> to(eq 11)
    end
  end
end

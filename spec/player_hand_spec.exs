defmodule PlayerHandSpec do
  use ESpec
  alias Blackjack.{PlayerHand, Card, Hand}

  let :card_1, do: %Card{value: 0}
  let :card_2, do: %Card{value: 9}
  let :player_hand, do: %PlayerHand{hand: %Hand{cards: [card_1(), card_2()]}}

  describe "PlayerHand.get_value/2" do
    it "a soft count with [🂡, 🂫] returns 21" do
      assert PlayerHand.get_value(player_hand(), :soft) |> to(eq 21)
    end

    it "a hard count with [🂡, 🂫] returns 11" do
      assert PlayerHand.get_value(player_hand(), :hard) |> to(eq 11)
    end
  end
end

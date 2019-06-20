defmodule PlayerHandTest do
  use ExUnit.Case
  alias Blackjack.{PlayerHand, Card, Hand}

  describe "PlayerHand.get_value/2" do
    test "a soft count with [🂡, 🂫] returns 21" do
      card_1 = %Card{value: 0, suit_value: 0}
      card_2 = %Card{value: 9, suit_value: 0}
      player_hand = %PlayerHand{hand: %Hand{cards: [card_1, card_2]}}
      assert PlayerHand.get_value(player_hand, :soft) == 21
    end

    test "a hard count with [🂡, 🂫] returns 11" do
      card_1 = %Card{value: 0, suit_value: 0}
      card_2 = %Card{value: 9, suit_value: 0}
      player_hand = %PlayerHand{hand: %Hand{cards: [card_1, card_2]}}
      assert PlayerHand.get_value(player_hand, :hard) == 11
    end
  end
end

defmodule DealerHandTest do
  use ExUnit.Case
  alias Blackjack.{DealerHand, Card, Hand}

  describe "DealerHand.get_value/2" do
    test "a soft count with [🂡, 🂫] and hidden down card returns 21" do
      card_1 = %Card{value: 0, suit_value: 0}
      card_2 = %Card{value: 9, suit_value: 0}
      player_hand = %DealerHand{hand: %Hand{cards: [card_1, card_2]}}
      assert DealerHand.get_value(player_hand, :soft) == 10
    end

    test "a hard count with [🂡, 🂫] and hidden down card returns 11" do
      card_1 = %Card{value: 0, suit_value: 0}
      card_2 = %Card{value: 9, suit_value: 0}
      player_hand = %DealerHand{hand: %Hand{cards: [card_1, card_2]}}
      assert DealerHand.get_value(player_hand, :hard) == 10
    end

    test "a soft count with [🂡, 🂫] and unhidden down card returns 21" do
      card_1 = %Card{value: 0, suit_value: 0}
      card_2 = %Card{value: 9, suit_value: 0}
      player_hand = %DealerHand{hand: %Hand{cards: [card_1, card_2]}, hide_down_card: false}
      assert DealerHand.get_value(player_hand, :soft) == 21
    end

    test "a hard count with [🂡, 🂫] and unhidden down card returns 11" do
      card_1 = %Card{value: 0, suit_value: 0}
      card_2 = %Card{value: 9, suit_value: 0}
      player_hand = %DealerHand{hand: %Hand{cards: [card_1, card_2]}, hide_down_card: false}
      assert DealerHand.get_value(player_hand, :hard) == 11
    end
  end
end

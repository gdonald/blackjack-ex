defmodule HandTest do
  use ExUnit.Case
  alias Blackjack.{Card, Hand, Shoe}

  describe "Hand.is_blackjack?/1" do
    test "[🂡, 🂫] returns true" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ace, ten]}
      assert Hand.is_blackjack?(hand)
    end

    test "[🂫, 🂡] returns true" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten, ace]}
      assert Hand.is_blackjack?(hand)
    end

    test "[🂫] returns false" do
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten]}
      refute Hand.is_blackjack?(hand)
    end

    test "[🂫, 🂡, 🂫] returns false" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      hand = %Hand{cards: [ten, ace, ten]}
      refute Hand.is_blackjack?(hand)
    end
  end

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

  describe "Hand.deal_card!/2" do
    test "removes a shoe card and puts it in the hand" do
      ace = %Card{value: 0}
      ten = %Card{value: 9}
      shoe = %Shoe{cards: [ace, ten]}
      hand = %Hand{}

      assert length(hand.cards) == 0
      assert length(shoe.cards) == 2

      {hand, shoe} = Hand.deal_card!(hand, shoe)
      assert length(hand.cards) == 1
      assert length(shoe.cards) == 1

      [card | _rest] = hand.cards
      assert card == ace
      [card | _rest] = shoe.cards
      assert card == ten
    end
  end
end

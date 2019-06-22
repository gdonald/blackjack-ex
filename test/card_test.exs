defmodule CardTest do
  use ExUnit.Case
  alias Blackjack.Card

  describe "Card.to_s/1" do
    test "returns an Ace of Spades" do
      card = %Card{value: 0, suit_value: 0}
      assert Card.to_s(card) == "🂡"
    end

    test "returns a card back" do
      card = %Card{value: 13, suit_value: 0}
      assert Card.to_s(card) == "🂠"
    end
  end

  describe "Card.is_ace?/1" do
    test "returns true" do
      card = %Card{value: 0, suit_value: 0}
      assert Card.is_ace?(card) == true
    end

    test "returns false" do
      card = %Card{value: 1, suit_value: 0}
      assert Card.is_ace?(card) == false
    end
  end

  describe "Card.is_ten?/1" do
    test "returns true" do
      card = %Card{value: 9, suit_value: 0}
      assert Card.is_ten?(card) == true
    end

    test "returns false" do
      card = %Card{value: 8, suit_value: 0}
      assert Card.is_ten?(card) == false
    end
  end

  describe "Card.val/1" do
    test "returns 9" do
      card = %Card{value: 8, suit_value: 0}
      assert Card.val(card) == 9
    end

    test "returns 10" do
      card = %Card{value: 9, suit_value: 0}
      assert Card.val(card) == 10
    end
  end

  describe "Card.one_or_eleven/3" do
    test "doing a soft count and a total of 11 returns 1" do
      assert Card.one_or_eleven(:soft, 1, 11) == 1
    end

    test "doing a soft count and a total of 10 returns 11" do
      assert Card.one_or_eleven(:soft, 1, 10) == 11
    end

    test "doing a hard count with a total of 11 returns 1" do
      assert Card.one_or_eleven(:hard, 1, 11) == 1
    end

    test "doing a hard count with a total of 10 returns 1" do
      assert Card.one_or_eleven(:hard, 1, 10) == 1
    end
  end
end

defmodule FaceTest do
  use ExUnit.Case
  alias Blackjack.{Card, Face}

  describe "Face.value/1" do
    test "returns an Ace of Spades" do
      card = %Card{value: 0}
      assert Face.value(card) == "🂡"
    end

    test "returns a card back" do
      card = %Card{value: 13}
      assert Face.value(card) == "🂠"
    end
  end

  describe "Face.card_back/0" do
    test "returns a card back" do
      assert Face.card_back() == "🂠"
    end
  end
end

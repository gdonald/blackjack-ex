defmodule FaceTest do
  use ExUnit.Case
  alias Blackjack.{Card, Face}

  describe "Face.value/1" do
    test "returns an Ace of Spades" do
      card = %Card{value: 0, suit_value: 0}
      assert Face.value(card) == "🂡"
    end

    test "returns a card back" do
      card = %Card{value: 13, suit_value: 0}
      assert Face.value(card) == "🂠"
    end
  end
end

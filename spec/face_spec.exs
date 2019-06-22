defmodule FaceSpec do
  use ESpec
  alias Blackjack.{Card, Face}

  describe "Face.value/1" do
    it "returns an Ace of Spades" do
      card = %Card{value: 0}
      expect Face.value(card) |> to(eq "🂡")
    end

    it "returns a card back" do
      card = %Card{value: 13}
      expect Face.value(card) |> to(eq "🂠")
    end
  end
end

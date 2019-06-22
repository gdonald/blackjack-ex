defmodule ShoeSpec do
  use ESpec
  alias Blackjack.{Card, Shoe}

  describe "Shoe.shuffle_spec/0" do
    it "returns shuffle specs" do
      expected = {{95, 8}, {92, 7}, {89, 6}, {86, 5}, {84, 4}, {82, 3}, {81, 2}, {80, 1}}
      expect Shoe.shuffle_specs |> to(eq expected)
    end
  end

  describe "Shoe.new/1" do
    it "creates a new shoe" do
      shoe = Shoe.new(1)
      expect length(shoe.cards) |> to(eq 52)
    end
  end

  describe "Shoe.next_card/1" do
    it "returns the next card and updated shoe" do
      shoe = Shoe.new(1)
      {card, shoe} = Shoe.next_card(shoe)
      expect %Card{} = card
      expect %Shoe{} = shoe
      expect length(shoe.cards) |> to(eq 51)
    end
  end
end
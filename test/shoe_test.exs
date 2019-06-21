defmodule ShoeTest do
  use ExUnit.Case

  alias Blackjack.{Card, Shoe}

  describe "Shoe.shuffle_spec/0" do
    test "returns shuffle specs" do
      expected = {{95, 8}, {92, 7}, {89, 6}, {86, 5}, {84, 4}, {82, 3}, {81, 2}, {80, 1}}
      assert Shoe.shuffle_specs == expected
    end
  end

  describe "Shoe.new/1" do
    test "creates a new shoe" do
      shoe = Shoe.new(1)
      assert length(shoe.cards) == 52
    end
  end

  describe "Shoe.next_card/1" do
    test "returns the next card and updated shoe" do
      shoe = Shoe.new(1)
      {card, shoe} = Shoe.next_card(shoe)
      assert %Card{} = card
      assert %Shoe{} = shoe
      assert length(shoe.cards) == 51
    end
  end
end
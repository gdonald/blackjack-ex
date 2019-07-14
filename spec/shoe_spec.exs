defmodule ShoeSpec do
  use ESpec
  alias Blackjack.{Card, Game, Shoe}

  describe "Shoe.shuffle_spec/0" do
    it "returns shuffle specs" do
      expected = [{95, 8}, {92, 7}, {89, 6}, {86, 5}, {84, 4}, {82, 3}, {81, 2}, {80, 1}]
      expect Shoe.shuffle_specs
             |> to(eq expected)
    end
  end

  describe "Shoe.new/1" do
    it "creates a new shoe" do
      shoe = Shoe.new_regular(1)
      expect length(shoe.cards)
             |> to(eq 52)
    end
  end

  describe "Shoe.next_card/1" do
    it "returns the next card and updated shoe" do
      shoe = Shoe.new_regular(1)
      {card, shoe} = Shoe.next_card(shoe)
      expect %Card{} = card
      expect %Shoe{} = shoe
      expect length(shoe.cards)
             |> to(eq 51)
    end
  end

  describe "Shoe.used_cards_percent/2" do
    let :game, do: %Game{}
    let :card, do: %Card{}

    it "returns 90" do
      shoe = %Shoe{cards: [card(), card(), card(), card(), card()]}
      expect Shoe.used_cards_percent(shoe, game())
      |> to(eq 90)
    end
  end

  describe "Shoe.needs_to_shuffle/2" do
    let :game, do: %Game{}

    it "returns false when there are plenty of cards" do
      shoe = %Shoe{cards: (for _ <- 1..11, do: %Card{})}
      expect Shoe.needs_to_shuffle?(shoe, game())
             |> to(be_false())
    end

    it "returns true when cards are running low" do
      shoe = %Shoe{cards: [%Card{}]}
      expect Shoe.needs_to_shuffle?(shoe, game())
             |> to(be_true())
    end

    it "returns true when no cards" do
      expect Shoe.needs_to_shuffle?(%Shoe{}, game())
             |> to(be_true())
    end
  end
end

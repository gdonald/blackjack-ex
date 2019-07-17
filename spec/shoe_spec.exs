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

  describe "Shoe.new_regular/1" do
    it "creates a new regular shoe" do
      shoe = Shoe.new_regular(1)
      expect length(shoe.cards)
             |> to(eq 52)
    end
  end

  describe "Shoe.new_aces_jacks/1" do
    it "creates a new shoe with only aces and jacks" do
      shoe = Shoe.new_aces_jacks(1)
      expect length(shoe.cards)
             |> to(eq 32)

      result = Enum.reduce(
                 shoe.cards,
                 [],
                 fn (card, acc) ->
                   valid = card.value == 0 || card.value == 10
                   if !valid, do: acc ++ [valid], else: acc
                 end
               )
               |> length == 0

      expect result
             |> to(be_true())
    end
  end

  describe "Shoe.new_jacks/1" do
    it "creates a new shoe with only jacks" do
      shoe = Shoe.new_jacks(1)
      expect length(shoe.cards)
             |> to(eq 20)

      result = Enum.reduce(
                 shoe.cards,
                 [],
                 fn (card, acc) ->
                   valid = card.value == 10
                   if !valid, do: acc ++ [valid], else: acc
                 end
               )
               |> length == 0

      expect result
             |> to(be_true())
    end
  end

  describe "Shoe.new_aces/1" do
    it "creates a new shoe with only aces" do
      shoe = Shoe.new_aces(1)
      expect length(shoe.cards)
             |> to(eq 20)

      result = Enum.reduce(
                 shoe.cards,
                 [],
                 fn (card, acc) ->
                   valid = card.value == 0
                   if !valid, do: acc ++ [valid], else: acc
                 end
               )
               |> length == 0

      expect result
             |> to(be_true())
    end
  end

  describe "Shoe.new_sevens/1" do
    it "creates a new shoe with only sevens" do
      shoe = Shoe.new_sevens(1)
      expect length(shoe.cards)
             |> to(eq 20)

      result = Enum.reduce(
                 shoe.cards,
                 [],
                 fn (card, acc) ->
                   valid = card.value == 6
                   if !valid, do: acc ++ [valid], else: acc
                 end
               )
               |> length == 0

      expect result
             |> to(be_true())
    end
  end

  describe "Shoe.new_eights/1" do
    it "creates a new shoe with only eights" do
      shoe = Shoe.new_eights(1)
      expect length(shoe.cards)
             |> to(eq 20)

      result = Enum.reduce(
                 shoe.cards,
                 [],
                 fn (card, acc) ->
                   valid = card.value == 7
                   if !valid, do: acc ++ [valid], else: acc
                 end
               )
               |> length == 0

      expect result
             |> to(be_true())
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

defmodule ShoeTest do
  use ExUnit.Case
  alias Blackjack.{Card, Game, Shoe}

  describe "Shoe.shuffle_spec/0" do
    test "returns shuffle specs" do
      expected = [{95, 8}, {92, 7}, {89, 6}, {86, 5}, {84, 4}, {82, 3}, {81, 2}, {80, 1}]
      assert Shoe.shuffle_specs() == expected
    end
  end

  describe "Shoe.new_regular/1" do
    test "creates a new regular shoe" do
      shoe = Shoe.new_regular(1)
      assert length(shoe.cards) == 52
    end
  end

  describe "Shoe.new_aces_jacks/1" do
    test "creates a new shoe with only aces and jacks" do
      shoe = Shoe.new_aces_jacks(1)
      assert length(shoe.cards) == 32

      result =
        Enum.reduce(
          shoe.cards,
          [],
          fn card, acc ->
            valid = card.value == 0 || card.value == 10
            if !valid, do: acc ++ [valid], else: acc
          end
        )
        |> length() == 0

      assert result
    end
  end

  describe "Shoe.new_jacks/1" do
    test "creates a new shoe with only jacks" do
      shoe = Shoe.new_jacks(1)
      assert length(shoe.cards) == 20

      result =
        Enum.reduce(
          shoe.cards,
          [],
          fn card, acc ->
            valid = card.value == 10
            if !valid, do: acc ++ [valid], else: acc
          end
        )
        |> length() == 0

      assert result
    end
  end

  describe "Shoe.new_aces/1" do
    test "creates a new shoe with only aces" do
      shoe = Shoe.new_aces(1)
      assert length(shoe.cards) == 20

      result =
        Enum.reduce(
          shoe.cards,
          [],
          fn card, acc ->
            valid = card.value == 0
            if !valid, do: acc ++ [valid], else: acc
          end
        )
        |> length() == 0

      assert result
    end
  end

  describe "Shoe.new_sevens/1" do
    test "creates a new shoe with only sevens" do
      shoe = Shoe.new_sevens(1)
      assert length(shoe.cards) == 20

      result =
        Enum.reduce(
          shoe.cards,
          [],
          fn card, acc ->
            valid = card.value == 6
            if !valid, do: acc ++ [valid], else: acc
          end
        )
        |> length() == 0

      assert result
    end
  end

  describe "Shoe.new_eights/1" do
    test "creates a new shoe with only eights" do
      shoe = Shoe.new_eights(1)
      assert length(shoe.cards) == 20

      result =
        Enum.reduce(
          shoe.cards,
          [],
          fn card, acc ->
            valid = card.value == 7
            if !valid, do: acc ++ [valid], else: acc
          end
        )
        |> length() == 0

      assert result
    end
  end

  describe "Shoe.next_card/1" do
    test "returns the next card and updated shoe" do
      shoe = Shoe.new_regular(1)
      {card, shoe} = Shoe.next_card(shoe)
      assert %Card{} = card
      assert %Shoe{} = shoe
      assert length(shoe.cards) == 51
    end
  end

  describe "Shoe.used_cards_percent/2" do
    test "returns 90" do
      game = %Game{}
      card = %Card{}
      shoe = %Shoe{cards: [card, card, card, card, card]}
      assert Shoe.used_cards_percent(shoe, game) == 90
    end
  end

  describe "Shoe.needs_to_shuffle/2" do
    test "returns false when there are plenty of cards" do
      game = %Game{}
      shoe = %Shoe{cards: for(_ <- 1..11, do: %Card{})}
      refute Shoe.needs_to_shuffle?(shoe, game)
    end

    test "returns true when cards are running low" do
      game = %Game{}
      shoe = %Shoe{cards: [%Card{}]}
      assert Shoe.needs_to_shuffle?(shoe, game)
    end

    test "returns true when no cards" do
      game = %Game{}
      assert Shoe.needs_to_shuffle?(%Shoe{}, game)
    end
  end
end

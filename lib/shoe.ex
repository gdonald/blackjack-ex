defmodule Blackjack.Shoe do
  defstruct cards: []

  alias Blackjack.{Card, Shoe}

  def shuffle_specs do
    [
      {95, 8},
      {92, 7},
      {89, 6},
      {86, 5},
      {84, 4},
      {82, 3},
      {81, 2},
      {80, 1}
    ]
  end

  def next_card(shoe) do
    {card, cards} = List.pop_at(shoe.cards, 0)
    {card, %Shoe{cards: cards}}
  end

  def used_cards_percent(shoe, game) do
    total_cards = game.num_decks * 52
    cards_dealt = total_cards - length(shoe.cards)
    trunc(cards_dealt / total_cards * 100)
  end

  def needs_to_shuffle?(shoe, game) do
    if length(shoe.cards) == 0 do
      true
    else
      used = Shoe.used_cards_percent(shoe, game)

      Enum.reduce(
        Shoe.shuffle_specs(),
        [],
        fn ({percent, decks_count}, acc) ->
          result = decks_count == game.num_decks && used > percent
          if result, do: acc ++ [result], else: acc
        end
      )
      |> length > 0
    end
  end

  def new(num_decks) do
    cards = new_regular(num_decks)
            |> Enum.shuffle

    %Shoe{cards: cards}
  end

  defp new_regular(num_decks) do
    for _decks <- 1..num_decks do
      for suit_value <- 0..3 do
        for value <- 0..12 do
          %Card{value: value, suit_value: suit_value}
        end
      end
    end
    |> List.flatten
  end

  defp new_aces_jacks(num_decks) do
    for _decks <- 1..(num_decks * 4) do
      for suit_value <- 0..3 do
        [
          %Card{value: 0, suit_value: suit_value},
          %Card{value: 10, suit_value: suit_value}
        ]
      end
    end
    |> List.flatten
  end

  defp new_jacks(num_decks) do
    for _decks <- 1..(num_decks * 5) do
      for suit_value <- 0..3 do
        %Card{value: 10, suit_value: suit_value}
      end
    end
    |> List.flatten
  end

  defp new_aces(num_decks) do
    for _decks <- 1..(num_decks * 5) do
      for suit_value <- 0..3 do
        %Card{value: 0, suit_value: suit_value}
      end
    end
    |> List.flatten
  end

  defp new_sevens(num_decks) do
    for _decks <- 1..(num_decks * 5) do
      for suit_value <- 0..3 do
        %Card{value: 6, suit_value: suit_value}
      end
    end
    |> List.flatten
  end

  defp new_eights(num_decks) do
    for _decks <- 1..(num_decks * 5) do
      for suit_value <- 0..3 do
        %Card{value: 7, suit_value: suit_value}
      end
    end
    |> List.flatten
  end
end

defmodule Blackjack.Shoe do
  defstruct cards: []

  alias Blackjack.{Card, Shoe}

  def shuffle_specs do
    {
      {95, 8},
      {92, 7},
      {89, 6},
      {86, 5},
      {84, 4},
      {82, 3},
      {81, 2},
      {80, 1}
    }
  end

  def next_card(shoe) do
    {card, cards} = List.pop_at(shoe.cards, 0)
    {card, %Shoe{cards: cards}}
  end

  def needs_to_shuffle(shoe) do
    case length(shoe.cards) do
      # TODO
      _ ->
        true
    end
  end

  def new_regular(num_decks) do
    cards = for _decks <- 1..num_decks do
      for suit_value <- 0..3 do
        for value <- 0..12 do
          %Card{value: value, suit_value: suit_value}
        end
      end
    end
    |> List.flatten
    |> Enum.shuffle

    %Shoe{cards: cards}
  end
end

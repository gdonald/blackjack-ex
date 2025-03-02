defmodule Blackjack.Hand do
  defstruct cards: []

  alias Blackjack.{Card, Hand, Shoe}

  def is_blackjack?(hand) do
    if length(hand.cards) != 2 do
      false
    else
      [card_1, card_2] = hand.cards

      if (Card.is_ace?(card_1) && Card.is_ten?(card_2)) ||
           (Card.is_ace?(card_2) && Card.is_ten?(card_1)) do
        true
      else
        false
      end
    end
  end

  def final_count(values, count_method) do
    Enum.reduce(
      values,
      0,
      fn value, total ->
        total + Card.one_or_eleven(count_method, value, total)
      end
    )
  end

  def deal_card!(hand, shoe) do
    {card, shoe} = Shoe.next_card(shoe)
    hand = %Hand{cards: hand.cards ++ [card]}

    {hand, shoe}
  end
end

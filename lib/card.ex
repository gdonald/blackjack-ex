defmodule Blackjack.Card do
  defstruct value: nil, suit_value: nil

  alias Blackjack.Face

  def to_s(card) do
    Face.value(card)
  end

  def is_ace(card) do
    card.value == 0
  end

  def is_ten(card) do
    card.value > 8
  end
end

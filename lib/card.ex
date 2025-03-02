defmodule Blackjack.Card do
  defstruct value: nil, suit_value: 0

  alias Blackjack.Face

  def to_s(card) do
    Face.value(card)
  end

  def is_ace?(card) do
    card.value == 0
  end

  def is_ten?(card) do
    card.value > 8
  end

  def val(card) do
    v = card.value + 1
    if v > 9, do: 10, else: v
  end

  def one_or_eleven(count_method, value, total) do
    if count_method == :soft && value == 1 && total < 11, do: 11, else: value
  end
end

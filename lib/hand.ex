defmodule Blackjack.Hand do
  defstruct cards: []

  def is_blackjack(hand) do

  end

  def final_count(values, count_method) do
    Enum.reduce(
      values,
      fn value, total ->
        total + Card.one_or_eleven(count_method, value, total)
      end
    )
  end
end

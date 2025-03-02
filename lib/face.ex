defmodule Blackjack.Face do
  alias Blackjack.Face

  def values do
    {{"🂡", "🂱", "🃁", "🃑"}, {"🂢", "🂲", "🃂", "🃒"}, {"🂣", "🂳", "🃃", "🃓"}, {"🂤", "🂴", "🃄", "🃔"},
     {"🂥", "🂵", "🃅", "🃕"}, {"🂦", "🂶", "🃆", "🃖"}, {"🂧", "🂷", "🃇", "🃗"}, {"🂨", "🂸", "🃈", "🃘"},
     {"🂩", "🂹", "🃉", "🃙"}, {"🂪", "🂺", "🃊", "🃚"}, {"🂫", "🂻", "🃋", "🃛"}, {"🂭", "🂽", "🃍", "🃝"},
     {"🂮", "🂾", "🃎", "🃞"}, {"🂠", "", "", ""}}
  end

  def value(card) do
    Face.values()
    |> elem(card.value)
    |> elem(card.suit_value)
  end

  def card_back do
    Face.values()
    |> elem(13)
    |> elem(0)
  end
end

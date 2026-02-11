defmodule Blackjack.Face do
  def values2 do
    [
      ~w[A♠ A♥ A♣ A♦],
      ~w[2♠ 2♥ 2♣ 2♦],
      ~w[3♠ 3♥ 3♣ 3♦],
      ~w[4♠ 4♥ 4♣ 4♦],
      ~w[5♠ 5♥ 5♣ 5♦],
      ~w[6♠ 6♥ 6♣ 6♦],
      ~w[7♠ 7♥ 7♣ 7♦],
      ~w[8♠ 8♥ 8♣ 8♦],
      ~w[9♠ 9♥ 9♣ 9♦],
      ~w[T♠ T♥ T♣ T♦],
      ~w[J♠ J♥ J♣ J♦],
      ~w[Q♠ Q♥ Q♣ Q♦],
      ~w[K♠ K♥ K♣ K♦],
      ~w[??]
    ]
  end

  def values do
    [
      ~w[🂡 🂱 🃁 🃑],
      ~w[🂢 🂲 🃂 🃒],
      ~w[🂣 🂳 🃃 🃓],
      ~w[🂤 🂴 🃄 🃔],
      ~w[🂥 🂵 🃅 🃕],
      ~w[🂦 🂶 🃆 🃖],
      ~w[🂧 🂷 🃇 🃗],
      ~w[🂨 🂸 🃈 🃘],
      ~w[🂩 🂹 🃉 🃙],
      ~w[🂪 🂺 🃊 🃚],
      ~w[🂫 🂻 🃋 🃛],
      ~w[🂭 🂽 🃍 🃝],
      ~w[🂮 🂾 🃎 🃞],
      ["🂠", "", "", ""]
    ]
  end

  def value(card, face_type \\ 1) do
    values_fn = if face_type == 2, do: &values2/0, else: &values/0
    values_fn.()
    |> Enum.at(card.value)
    |> Enum.at(card.suit_value)
  end

  def card_back(face_type \\ 1) do
    values_fn = if face_type == 2, do: &values2/0, else: &values/0
    values_fn.()
    |> Enum.at(13)
    |> Enum.at(0)
  end
end

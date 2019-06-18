defmodule Blackjack.PlayerHand do
  defstruct hand: nil

  alias Blackjack.{Card, Hand}

  def get_value(player_hand, count_method) do
    total =
      Enum.map(
        player_hand.hand.cards,
        fn card -> Card.val(card) end
      ) |> Hand.final_count(count_method)

    if count_method == :soft && total > 21,
       do: get_value(player_hand, :hard),
       else: total
  end
end

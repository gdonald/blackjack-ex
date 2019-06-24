defmodule Blackjack.DealerHand do
  defstruct hand: nil, hide_down_card: true

  alias Blackjack.{Card, DealerHand, Hand}

  def get_value(dealer_hand, count_method) do
    total =
      Enum.with_index(dealer_hand.hand.cards)
      |> Enum.map(
           fn ({card, index}) ->
             DealerHand.card_val(dealer_hand, index, card)
           end
         )
      |> Hand.final_count(count_method)

    if count_method == :soft && total > 21,
       do: DealerHand.get_value(dealer_hand, :hard),
       else: total
  end

  def card_val(dealer_hand, index, card) do
    if index == 0 && dealer_hand.hide_down_card,
       do: 0, else: Card.val(card)
  end

  def is_busted?(dealer_hand) do
    DealerHand.get_value(dealer_hand, :soft) > 21
  end

  def up_card_is_ace?(dealer_hand) do
    [first | _rest] = dealer_hand.hand.cards
    Card.is_ace?(first)
  end
end

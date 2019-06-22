defmodule Blackjack.PlayerHand do
  defstruct hand: nil, played: false, payed: false, status: :unknown

  alias Blackjack.{Card, Game, Hand, PlayerHand}

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

  def is_done(game, player_hand) do
    if player_hand.played
       || player_hand.stood
       || Hand.is_blackjack?(player_hand.hand)
       || PlayerHand.is_busted?(player_hand)
       || 21 == PlayerHand.get_value(player_hand, :soft)
       || 21 == PlayerHand.get_value(player_hand, :hard) do
      player_hand = %PlayerHand{player_hand | played: true}

      if !player_hand.payed && PlayerHand.is_busted?(player_hand) do
        player_hand = %PlayerHand{player_hand | payed: true, status: :lost}
        game = %Game{game | money: game.money - player_hand.bet}
        {true, game, player_hand}
      else
        {false, game, player_hand}
      end
    end
  end

  def is_busted?(player_hand) do
    get_value(player_hand, :soft) > 21
  end
end

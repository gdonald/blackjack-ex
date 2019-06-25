defmodule Blackjack.PlayerHand do
  defstruct hand: nil, bet: 500, played: false, payed: false, stood: false, status: :unknown

  alias Blackjack.{Card, Game, Hand, PlayerHand}

  def get_value(player_hand, count_method) do
    total =
      Enum.map(
        player_hand.hand.cards,
        fn card -> Card.val(card) end
      )
      |> Hand.final_count(count_method)

    if count_method == :soft && total > 21,
       do: PlayerHand.get_value(player_hand, :hard),
       else: total
  end

  def is_played?(player_hand) do
    player_hand.played
    || player_hand.stood
    || Hand.is_blackjack?(player_hand.hand)
    || PlayerHand.is_busted?(player_hand)
    || 21 == PlayerHand.get_value(player_hand, :soft)
    || 21 == PlayerHand.get_value(player_hand, :hard)
  end

  def handle_busted_hand!(player_hand, game) do
    if PlayerHand.is_busted?(player_hand) do
      player_hand = %PlayerHand{player_hand | payed: true, status: :lost}
      game = %Game{game | money: game.money - player_hand.bet}
      {player_hand, game}
    else
      {player_hand, game}
    end
  end

  def is_done?(player_hand, game) do
    if PlayerHand.is_played?(player_hand) do
      player_hand = %PlayerHand{player_hand | played: true}
      {player_hand, game} = PlayerHand.handle_busted_hand!(player_hand, game)
      {true, player_hand, game}
    else
      {false, player_hand, game}
    end
  end

  def is_busted?(player_hand) do
    PlayerHand.get_value(player_hand, :soft) > 21
  end

  def to_s(player_hand) do
    cards = Enum.map(
              player_hand.hand.cards,
              fn card ->
                Card.to_s(card)
              end
            )
            |> Enum.join(" ")
    value = PlayerHand.get_value(player_hand, :soft)

    " #{cards} ⇒  #{value}"
  end
end

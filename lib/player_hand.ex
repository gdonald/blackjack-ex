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

  def get_sign(player_hand) do
    cond do
      player_hand.status == :lost ->
        "-"
      player_hand.status == :won ->
        "+"
      true ->
        ""
    end
  end

  def get_bet(player_hand) do
    "$#{Game.format_money(player_hand.bet / 100.0)}"
  end

  def get_arrow(player_hand, index, game) do
    if !player_hand.played && index == game.current_player_hand do
      " ⇐"
    else
      ""
    end
  end

  def get_status(player_hand) do
    if player_hand.status == :lost do
      if PlayerHand.is_busted?(player_hand) do
        "Busted!"
      else
        "Lose!"
      end
    else
      if player_hand.status == :won do
        if Hand.is_blackjack?(player_hand.hand) do
          "Blackjack!"
        else
          "Won!"
        end
      else
        if player_hand.status == :push do
          "Push"
        end
      end
    end
  end

  def to_s(player_hand, index, game) do
    cards = Enum.map(
              player_hand.hand.cards,
              fn card ->
                Card.to_s(card)
              end
            )
            |> Enum.join(" ")
    value = PlayerHand.get_value(player_hand, :soft)
    sign = PlayerHand.get_sign(player_hand)
    bet = PlayerHand.get_bet(player_hand)
    arrow = PlayerHand.get_arrow(player_hand, index, game)
    status = PlayerHand.get_status(player_hand)

    " #{cards} ⇒  #{value}  #{sign}#{bet}#{arrow}  #{status}\n"
  end

  def can_split?(player_hand, game) do
    if player_hand.stood
       || length(game.player_hands) >= game.max_player_hands
       || game.money < Game.all_bets(game) + player_hand.bet do
      false
    else
      if length(player_hand.hand.cards) == 2 do
        [card_1, card_2] = player_hand.hand.cards
        card_1.value == card_2.value
      else
        false
      end
    end
  end

  def can_double?(player_hand, game) do
    !(player_hand.stood
      || length(player_hand.hand.cards) != 2
      || Hand.is_blackjack?(player_hand.hand)
      || game.money < Game.all_bets(game) + player_hand.bet)
  end

  def can_stand?(player_hand) do
    !(player_hand.stood
      || PlayerHand.is_busted?(player_hand)
      || Hand.is_blackjack?(player_hand.hand))
  end

  def can_hit?(player_hand) do
    !(player_hand.stood || player_hand.played
      || 21 == PlayerHand.get_value(player_hand, :hard)
      || Hand.is_blackjack?(player_hand.hand)
      || PlayerHand.is_busted?(player_hand))
  end

  def promoted_bet(player_hand) do
    if Hand.is_blackjack?(player_hand.hand) do
      player_hand.bet * 1.5
    else
      player_hand.bet
    end
  end

  def pay!(player_hand, dhv, dhb) do
    if player_hand.payed do
      {player_hand, 0}
    else
      phv = PlayerHand.get_value(player_hand, :soft)
      if dhb || phv > dhv do
        bet = PlayerHand.promoted_bet(player_hand)
        {%PlayerHand{player_hand | payed: true, status: :won, bet: bet}, bet}
      else
        if phv < dhv do
          {%PlayerHand{player_hand | payed: true, status: :lost}, -player_hand.bet}
        else
          {%PlayerHand{player_hand | payed: true, status: :push}, 0}
        end
      end
    end
  end

  def get_action(game, player_hand) do

  end

  def process(game) do
    if Game.more_hands_to_play?(game) do
      Game.play_more_hands!(game)
    else
      Game.play_dealer_hand!(game)
      |> Game.draw_hands
      |> Game.draw_bet_options
    end
  end

  def hit!(player_hand, game) do
    {hand, shoe} = Hand.deal_card!(player_hand.hand, game.shoe)
    player_hand = %PlayerHand{player_hand | hand: hand}
    game = %Game{game | shoe: shoe}

    if PlayerHand.is_done?(player_hand, game) do
      PlayerHand.process(game)
    else
      Game.draw_hands(game)
    end

    {player_hand, game}

    # TODO: Move to the hit! caller
    # game->playerHands.at(game->currentPlayerHand).getAction();
  end
end

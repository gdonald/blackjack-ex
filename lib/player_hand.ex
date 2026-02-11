defmodule Blackjack.PlayerHand do
  defstruct hand: nil, bet: 500, played: false, paid: false, stood: false, status: :unknown

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
    player_hand.played ||
      player_hand.stood ||
      Hand.is_blackjack?(player_hand.hand) ||
      PlayerHand.is_busted?(player_hand) ||
      21 == PlayerHand.get_value(player_hand, :soft) ||
      21 == PlayerHand.get_value(player_hand, :hard)
  end

  def handle_busted_hand!(%PlayerHand{} = player_hand, game) do
    if PlayerHand.is_busted?(player_hand) do
      player_hand = %{player_hand | paid: true, status: :lost}
      game = %{game | money: game.money - player_hand.bet}
      game = Game.update_current_player_hand!(game, player_hand)
      {player_hand, game}
    else
      {player_hand, game}
    end
  end

  def is_done?(%PlayerHand{} = player_hand, game) do
    if PlayerHand.is_played?(player_hand) do
      player_hand = %{player_hand | played: true}
      game = Game.update_current_player_hand!(game, player_hand)
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
    if !player_hand.played && index == game.current_player_hand_index do
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
    cards =
      Enum.map(
        player_hand.hand.cards,
        fn card ->
          Card.to_s(card, game.face_type)
        end
      )
      |> Enum.join(" ")

    value = PlayerHand.get_value(player_hand, :soft)
    sign = PlayerHand.get_sign(player_hand)
    bet = PlayerHand.get_bet(player_hand)
    arrow = PlayerHand.get_arrow(player_hand, index, game)
    status = PlayerHand.get_status(player_hand)

    " #{cards} ⇒  #{value}  #{sign}#{bet}#{arrow}  #{status}\r\n\r\n"
  end

  def can_split?(player_hand, game) do
    if player_hand.stood ||
         length(game.player_hands) >= game.max_player_hands ||
         game.money < Game.all_bets(game) + player_hand.bet do
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
    !(player_hand.stood ||
        length(player_hand.hand.cards) != 2 ||
        Hand.is_blackjack?(player_hand.hand) ||
        game.money < Game.all_bets(game) + player_hand.bet)
  end

  def can_stand?(player_hand) do
    !(player_hand.stood ||
        PlayerHand.is_busted?(player_hand) ||
        Hand.is_blackjack?(player_hand.hand))
  end

  def can_hit?(player_hand) do
    !(player_hand.stood || player_hand.played ||
        21 == PlayerHand.get_value(player_hand, :hard) ||
        Hand.is_blackjack?(player_hand.hand) ||
        PlayerHand.is_busted?(player_hand))
  end

  def promoted_bet(player_hand) do
    if Hand.is_blackjack?(player_hand.hand) do
      player_hand.bet * 1.5
    else
      player_hand.bet
    end
  end

  def pay!(%PlayerHand{} = player_hand, dhv, dhb) do
    if player_hand.paid do
      {player_hand, 0}
    else
      phv = PlayerHand.get_value(player_hand, :soft)

      if dhb || phv > dhv do
        bet = PlayerHand.promoted_bet(player_hand)
        {%{player_hand | paid: true, status: :won, bet: bet}, bet}
      else
        if phv < dhv do
          {%{player_hand | paid: true, status: :lost}, -player_hand.bet}
        else
          {%{player_hand | paid: true, status: :push}, 0}
        end
      end
    end
  end

  def draw_actions(game, player_hand) do
    hit = if PlayerHand.can_hit?(player_hand), do: "(H) Hit  ", else: ""
    stand = if PlayerHand.can_stand?(player_hand), do: "(S) Stand  ", else: ""
    split = if PlayerHand.can_split?(player_hand, game), do: "(P) Split  ", else: ""
    double = if PlayerHand.can_double?(player_hand, game), do: "(D) Double  ", else: ""

    IO.write(" #{hit}#{stand}#{split}#{double}\r\n")
  end

  def get_action(game, player_hand) do
    PlayerHand.draw_actions(game, player_hand)

    char = Game.get_input()

    cond do
      char == "h" ->
        PlayerHand.hit!(player_hand, game)

      char == "s" ->
        PlayerHand.stand!(player_hand, game)

      char == "p" ->
        Game.split_current_hand(game)

      char == "d" ->
        PlayerHand.double!(player_hand, game)

      true ->
        Game.clear(game)
        |> Game.draw_hands()
        |> PlayerHand.get_action(player_hand)
    end
  end

  def process(game) do
    if Game.more_hands_to_play?(game) do
      Game.play_more_hands!(game)
    else
      Game.play_dealer_hand!(game)
      |> Game.draw_hands()
      |> Game.draw_bet_options()
    end
  end

  def deal_card!(%PlayerHand{} = player_hand, game) do
    {hand, shoe} = Hand.deal_card!(player_hand.hand, game.shoe)
    player_hand = %{player_hand | hand: hand}
    game = Game.update_current_player_hand!(game, player_hand)
    {player_hand, %{game | shoe: shoe}}
  end

  def hit!(player_hand, game) do
    {player_hand, game} = PlayerHand.deal_card!(player_hand, game)
    {is_done, player_hand, game} = PlayerHand.is_done?(player_hand, game)

    if is_done do
      PlayerHand.process(game)
    else
      Game.draw_hands(game)
      |> PlayerHand.get_action(player_hand)
    end
  end

  def stand!(%PlayerHand{} = player_hand, game) do
    player_hand = %{player_hand | stood: true, played: true}
    game = Game.update_current_player_hand!(game, player_hand)

    if Game.more_hands_to_play?(game) do
      Game.play_more_hands!(game)
    else
      Game.play_dealer_hand!(game)
      |> Game.draw_hands()
      |> Game.draw_bet_options()
    end
  end

  def double!(%PlayerHand{} = player_hand, game) do
    {player_hand, game} = PlayerHand.deal_card!(player_hand, game)

    bet = player_hand.bet * 2
    player_hand = %{player_hand | played: true, bet: bet}

    game = Game.update_current_player_hand!(game, player_hand)
    {is_done, _player_hand, game} = PlayerHand.is_done?(player_hand, game)

    if is_done do
      PlayerHand.process(game)
    else
      game
    end
  end
end

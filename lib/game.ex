defmodule Blackjack.Game do
  defstruct num_decks: 1,
            money: 10000,
            current_bet: 500,
            dealer_hand: nil,
            player_hands: [],
            current_player_hand_index: 0,
            max_player_hands: 7,
            shoe: nil,
            min_bet: 500,
            max_bet: 10000000,
            save_file: "bj.txt",
            deck_type: 1

  alias Blackjack.{DealerHand, Game, Hand, PlayerHand, Shoe}

  def run(_args \\ []) do
    {:ok, Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])}

    game = Game.load_game!(%Game{})
    shoe = Shoe.new_regular(game.num_decks)

    %Game{game | shoe: shoe}
    |> Game.deal_new_hand
  end

  def current_player_hand(game) do
    Enum.at(game.player_hands, game.current_player_hand_index)
  end

  def update_current_player_hand!(game, player_hand) do
    player_hands = List.replace_at(game.player_hands, game.current_player_hand_index, player_hand)
    %Game{game | player_hands: player_hands}
  end

  def all_bets(game) do
    Enum.reduce(
      game.player_hands,
      0,
      fn player_hand, total ->
        total + player_hand.bet
      end
    )
  end

  def more_hands_to_play?(game) do
    game.current_player_hand_index < length(game.player_hands) - 1
  end

  def needs_to_play_dealer_hand?(game) do
    Enum.reduce(
      game.player_hands,
      [],
      fn (player_hand, acc) ->
        result = !(PlayerHand.is_busted?(player_hand) || Hand.is_blackjack?(player_hand.hand))
        if result,
           do: acc ++ [result],
           else: acc
      end
    )
    |> length > 0
  end

  def normalize_current_bet!(game) do
    if game.current_bet < game.min_bet do
      %Game{game | current_bet: game.min_bet}
    else
      if game.current_bet > game.max_bet do
        %Game{game | current_bet: game.max_bet}
      else
        if game.current_bet > game.money do
          %Game{game | current_bet: game.money}
        else
          game
        end
      end
    end
  end

  def normalize_num_decks!(game) do
    if game.num_decks < 1 do
      %Game{game | num_decks: 1}
    else
      if game.num_decks > 8 do
        %Game{game | num_decks: 8}
      else
        game
      end
    end
  end

  def normalize_deck_type!(game) do
    if game.deck_type < 1 do
      %Game{game | deck_type: 1}
    else
      if game.deck_type > 6 do
        %Game{game | deck_type: 1}
      else
        game
      end
    end
  end

  def save_game!(game) do
    data = "#{game.num_decks}|#{game.money}|#{game.current_bet}"
    File.write(game.save_file, data)
    game
  end

  def load_game!(game) do
    [num_decks, money, current_bet] = File.read!(game.save_file)
                                      |> String.split("|")
    %Game{
      game |
      num_decks: String.to_integer(num_decks),
      money: String.to_integer(money),
      current_bet: String.to_integer(current_bet)
    }
  end

  def pay_player_hands!(game) do
    dhv = DealerHand.get_value(game.dealer_hand, :soft)
    dhb = DealerHand.is_busted?(game.dealer_hand)

    results = Enum.reduce(
      game.player_hands,
      [],
      fn (player_hand, acc) ->
        acc ++ [PlayerHand.pay!(player_hand, dhv, dhb)]
      end
    )

    money = Enum.reduce(
      results,
      0,
      fn ({_, result}, acc) ->
        acc + result
      end
    )

    player_hands = Enum.reduce(
      results,
      [],
      fn ({player_hand, _}, acc) ->
        acc ++ [player_hand]
      end
    )

    %Game{game | money: game.money + money, player_hands: player_hands}
    |> Game.normalize_current_bet!
    |> Game.save_game!
  end

  def unhide_dealer_down_card!(game) do
    if Hand.is_blackjack?(game.dealer_hand.hand)
       || Game.needs_to_play_dealer_hand?(game) do
      dealer_hand = %DealerHand{game.dealer_hand | hide_down_card: false}
      %Game{game | dealer_hand: dealer_hand}
    else
      game
    end
  end

  def deal_dealer_cards!(game) do
    soft_count = DealerHand.get_value(game.dealer_hand, :soft)
    hard_count = DealerHand.get_value(game.dealer_hand, :hard)

    if soft_count < 18 && hard_count < 17 do
      game = DealerHand.deal_card!(game)
      Game.deal_dealer_cards!(game)
    else
      game
    end
  end

  def play_dealer_hand!(game) do
    game = Game.unhide_dealer_down_card!(game)

    if Game.needs_to_play_dealer_hand?(game) do
      Game.deal_dealer_cards!(game)
      |> Game.pay_player_hands!
    else
      Game.pay_player_hands!(game)
    end
  end

  def clear(game) do
    # \e[H - reset
    # \e[2J - clear
    IO.write("\e[H\e[2J")
    game
  end

  def to_s(game) do
    dh = DealerHand.to_s(game.dealer_hand)
    phs = Enum.with_index(game.player_hands)
          |> Enum.reduce(
               "",
               fn ({player_hand, index}, acc) ->
                 acc <> PlayerHand.to_s(player_hand, index, game)
               end
             )
    money = Game.format_money(game.money / 100.0)

    "\r\n Dealer:\r\n#{dh}\r\n\r\n Player $#{money}:\r\n#{phs}\r\n"
  end

  def draw_hands(game) do
    game
    |> Game.clear
    |> Game.to_s
    |> IO.write

    game
  end

  def format_money(value) do
    :io_lib.format("~.2f", [value])
    |> to_string()
  end

  def shuffle(game) do
    if Shoe.needs_to_shuffle?(game.shoe, game) do
      shoe = Shoe.new_regular(game.num_decks)
      %Game{game | shoe: shoe}
    else
      game
    end
  end

  def needs_to_offer_insurance?(dealer_hand, player_hand) do
    DealerHand.up_card_is_ace?(dealer_hand) && !Hand.is_blackjack?(player_hand.hand)
  end

  def insure_hand(game) do
    player_hand = Game.current_player_hand(game)
    bet = player_hand.bet / 2
    player_hand = %PlayerHand{player_hand | bet: bet, played: true, payed: true, status: :lost}

    money = game.money - player_hand.bet
    game = Game.update_current_player_hand!(game, player_hand)

    %Game{game | money: money}
  end

  def no_insurance(game) do
    if Hand.is_blackjack?(game.dealer_hand.hand) do
      dealer_hand = %DealerHand{game.dealer_hand | hide_down_card: false}
      %Game{game | dealer_hand: dealer_hand}
      |> Game.pay_player_hands!
      |> Game.draw_hands
      |> Game.draw_bet_options
    else
      player_hand = Game.current_player_hand(game)
      {is_done, player_hand, game} = PlayerHand.is_done?(player_hand, game)

      if is_done do
        Game.play_dealer_hand!(game)
        |> Game.draw_hands
        |> Game.draw_bet_options
      else
        Game.draw_hands(game)
        |> PlayerHand.get_action(player_hand)
      end
    end
  end

  def ask_insurance(game) do
    IO.write " Insurance?  (Y) Yes  (N) No\r\n"

    char = Game.get_input()
    cond do
      char == "y" ->
        Game.insure_hand(game)
        |> Game.draw_hands
        |> Game.draw_bet_options
      char == "n" ->
        Game.no_insurance(game)
      true ->
        Game.clear(game)
        |> Game.draw_hands
        |> Game.ask_insurance
    end
  end

  def deal_new_hand(game) do
    game = Game.shuffle(game)
    shoe = game.shoe

    player_hand = %PlayerHand{hand: %Hand{}, bet: game.current_bet}
    dealer_hand = %DealerHand{hand: %Hand{}}

    {hand, shoe} = Hand.deal_card!(player_hand.hand, shoe)
    player_hand = %PlayerHand{player_hand | hand: hand}

    {hand, shoe} = Hand.deal_card!(dealer_hand.hand, shoe)
    dealer_hand = %DealerHand{dealer_hand | hand: hand}

    {hand, shoe} = Hand.deal_card!(player_hand.hand, shoe)
    player_hand = %PlayerHand{player_hand | hand: hand}

    {hand, shoe} = Hand.deal_card!(dealer_hand.hand, shoe)
    dealer_hand = %DealerHand{dealer_hand | hand: hand}

    game = %Game{
      game |
      shoe: shoe,
      dealer_hand: dealer_hand,
      player_hands: [player_hand],
      current_player_hand_index: 0
    }

    if Game.needs_to_offer_insurance?(dealer_hand, player_hand) do
      Game.draw_hands(game)
      |> Game.ask_insurance
    else
      {is_done, player_hand, game} = PlayerHand.is_done?(player_hand, game)
      if is_done do
        dealer_hand = %DealerHand{game.dealer_hand | hide_down_card: false}
        %Game{game | dealer_hand: dealer_hand}
        |> Game.pay_player_hands!
        |> Game.draw_hands
        |> Game.draw_bet_options
      else
        Game.draw_hands(game)
        |> PlayerHand.get_action(player_hand)
        |> Game.save_game!
      end
    end
  end

  def get_input do
    receive do
      {_port, {:data, data}} ->
        data
    end
  end

  def draw_bet_options(game) do
    IO.write " (D) Deal Hand  (B) Change Bet  (O) Options  (Q) Quit\r\n"

    char = Game.get_input()
    cond do
      char == "d" ->
        Game.deal_new_hand(game)
      char == "b" ->
        Game.get_new_bet(game)
      char == "o" ->
        Game.draw_game_options(game)
      char == "q" ->
        Game.clear(game)
      true ->
        Game.clear(game)
        |> Game.draw_hands
        |> Game.draw_bet_options
    end
  end

  def draw_game_options(game) do
    Game.clear(game)
    |> Game.draw_hands

    IO.write " (N) Number of Decks  (T) Deck Type  (B) Back\r\n"

    char = Game.get_input()
    cond do
      char == "n" ->
        Game.get_new_num_decks(game)
      char == "t" ->
        Game.get_new_shoe(game)
      char == "b" ->
        Game.clear(game)
        |> Game.draw_hands
        |> Game.draw_bet_options
      true ->
        Game.clear(game)
        |> Game.draw_hands
        |> Game.draw_game_options
    end
  end

  def get_shoe(game) do
    Game.clear(game)
    |> Game.draw_hands

    IO.write " (1) Regular  (2) Aces  (3) Jacks  (4) Aces & Jacks  (5) Sevens  (6) Eights\r\n"

    input = Game.get_input()
    cond do
      input == "1" ->
        Shoe.new_regular(game.num_decks)
      input == "2" ->
        Shoe.new_aces(game.num_decks)
      input == "3" ->
        Shoe.new_jacks(game.num_decks)
      input == "4" ->
        Shoe.new_aces_jacks(game.num_decks)
      input == "5" ->
        Shoe.new_sevens(game.num_decks)
      input == "6" ->
        Shoe.new_eights(game.num_decks)
      true ->
        Game.get_shoe(game)
    end
  end

  def get_new_shoe(game) do
    shoe = Game.get_shoe(game)

    %Game{game | shoe: shoe}
    |> Game.normalize_deck_type!
    |> Game.draw_game_options
  end

  def get_num_decks(game) do
    Game.clear(game)
    |> Game.draw_hands

    IO.write "  Number Of Decks: #{game.num_decks}\r\n"
    IO.write "  Enter New Number Of Decks (1-8):\r\n"

    input = Game.get_input()

    case Integer.parse(input) do
      {num_decks, _remainder} ->
        num_decks
      :error ->
        Game.get_num_decks(game)
    end
  end

  def get_new_num_decks(game) do
    decks = Game.get_num_decks(game)

    game = %Game{game | num_decks: decks}
    |> Game.normalize_num_decks!
    |> Game.save_game!

    shoe = Shoe.new_regular(game.num_decks)
    %Game{game | shoe: shoe}
    |> Game.draw_game_options
  end

  def get_bet(game) do
    Game.clear(game)
    |> Game.draw_hands

    IO.write "  Current Bet: $#{Game.format_money(game.current_bet / 100.0)}\r\n"
    IO.write "  Use (u)p/(d)own then press \"b\"\r\n"

    input = Game.get_input()

    cond do
      input == "\e[A" || input == "u" ->
        %Game{game | current_bet: game.current_bet + 100}
        |> Game.normalize_current_bet!
        |> Game.get_bet
      input == "\e[B" || input == "d" ->
        %Game{game | current_bet: game.current_bet - 100}
        |> Game.normalize_current_bet!
        |> Game.get_bet
      input == "b" ->
        game
      true ->
        Game.get_bet(game)
    end
  end

  def get_new_bet(game) do
    Game.get_bet(game)
    |> Game.save_game!
    |> Game.deal_new_hand
  end

  def play_more_hands!(game) do
    game = %Game{game | current_player_hand_index: game.current_player_hand_index + 1}
    player_hand = Game.current_player_hand(game)
    {player_hand, game} = PlayerHand.deal_card!(player_hand, game)

    {is_done, player_hand, game} = PlayerHand.is_done?(player_hand, game)
    if is_done do
      PlayerHand.process(game)
    else
      Game.draw_hands(game)
      |> PlayerHand.get_action(player_hand)
    end
  end

  def split_current_hand(game) do
    current_hand = Game.current_player_hand(game)

    if PlayerHand.can_split?(current_hand, game) do
      player_hand = %PlayerHand{bet: current_hand.bet, hand: %Hand{}}
      player_hands = List.insert_at(game.player_hands, game.current_player_hand_index + 1, player_hand)

      game = %Game{game | player_hands: player_hands}

      this_player_hand = Enum.at(game.player_hands, game.current_player_hand_index)
      split_player_hand = Enum.at(game.player_hands, game.current_player_hand_index + 1)

      {card, cards} = List.pop_at(this_player_hand.hand.cards, 1)

      this_hand = %Hand{this_player_hand.hand | cards: cards}
      this_player_hand = %PlayerHand{this_player_hand | hand: this_hand}
      player_hands = List.replace_at(game.player_hands, game.current_player_hand_index, this_player_hand)
      game = %Game{game | player_hands: player_hands}

      split_hand = %Hand{split_player_hand.hand | cards: [card]}
      split_player_hand = %PlayerHand{split_player_hand | hand: split_hand}
      player_hands = List.replace_at(game.player_hands, game.current_player_hand_index + 1, split_player_hand)
      game = %Game{game | player_hands: player_hands}

      player_hand = Game.current_player_hand(game)
      {player_hand, game} = PlayerHand.deal_card!(player_hand, game)

      {is_done, player_hand, game} = PlayerHand.is_done?(player_hand, game)

      if is_done do
        PlayerHand.process(game)
      else
        Game.draw_hands(game)
        |> PlayerHand.get_action(player_hand)
      end
    else
      Game.draw_hands(game)
      |> PlayerHand.get_action(current_hand)
    end
  end
end
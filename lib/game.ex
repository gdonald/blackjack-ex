defmodule Blackjack.Game do
  defstruct num_decks: 1,
            money: 10000,
            current_bet: 500,
            dealer_hand: nil,
            player_hands: [],
            current_player_hand: 0,
            max_player_hands: 7,
            shoe: nil,
            min_bet: 500,
            max_bet: 10000000,
            save_file: "bj.txt",
            deck_type: 1

  alias Blackjack.{DealerHand, Game, Hand, PlayerHand, Shoe}

  def run(_args \\ []) do
    game = %Game{}
    shoe = Shoe.new(game.num_decks)

    %Game{game | shoe: shoe}
    |> Game.deal_new_hand
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
    game.current_player_hand < length(game.player_hands) - 1
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
    game
    |> Game.unhide_dealer_down_card!
    |> Game.deal_dealer_cards!
    |> Game.pay_player_hands!
  end

  def clear(game) do
    # \e[H - reset
    # \e[2J - clear
    IO.puts("\e[H\e[2J")
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

    " Dealer:\n#{dh}\n\n Player $#{money}:\n#{phs}"
  end

  def draw_hands(game) do
    game
    |> Game.clear
    |> Game.to_s
    |> IO.puts

    game
  end

  def format_money(value) do
    :io_lib.format("~.2f", [value])
    |> to_string()
  end

  def shuffle(game) do
    if Shoe.needs_to_shuffle?(game.shoe, game) do
      shoe = Shoe.new(game.num_decks)
      %Game{game | shoe: shoe}
    else
      game
    end
  end

  def needs_to_offer_insurance?(dealer_hand, player_hand) do
    DealerHand.up_card_is_ace?(dealer_hand) && !Hand.is_blackjack?(player_hand.hand)
  end

  def ask_insurance(game) do

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
      current_player_hand: 0
    }

    if Game.needs_to_offer_insurance?(dealer_hand, player_hand) do
      Game.draw_hands(game)
      |> Game.ask_insurance
    else
      if PlayerHand.is_done?(player_hand, game) do
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

  def draw_bet_options(game) do
    IO.puts " (D) Deal Hand  (B) Change Bet  (O) Options  (Q) Quit"

    char = IO.getn("", 1)
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
    IO.puts " (N) Number of Decks  (T) Deck Type  (B) Back"

    char = IO.getn("", 1)
    cond do
      char == "n" ->
        Game.get_new_num_decks(game)
      char == "t" ->
        Game.get_new_deck_type(game)
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

  def get_deck_type(game) do
    Game.clear(game)
    |> Game.draw_hands

    IO.puts " (1) Regular  (2) Aces  (3) Jacks  (4) Aces & Jacks  (5) Sevens  (6) Eights"
    deck_type = IO.gets("")

    cond do
      is_integer(deck_type) ->
        deck_type
      true ->
        Game.get_deck_type(game)
    end
  end

  def get_new_deck_type(game) do
    deck_type = Game.get_deck_type(game)

    %Game{game | deck_type: deck_type}
    |> Game.normalize_deck_type!
    |> Game.draw_bet_options
  end

  def get_num_decks(game) do
    Game.clear(game)
    |> Game.draw_hands

    IO.puts "  Number Of Decks: #{game.num_decks}"
    num_decks = IO.gets("  Enter New Number Of Decks: ")

    cond do
      is_integer(num_decks) ->
        num_decks
      true ->
        Game.get_num_decks(game)
    end
  end

  def get_new_num_decks(game) do
    decks = Game.get_num_decks(game)

    %Game{game | num_decks: decks}
    |> Game.normalize_num_decks!
    |> Game.draw_game_options
  end

  def get_bet(game) do
    Game.clear(game)
    |> Game.draw_hands

    IO.puts "  Current Bet: $#{Game.format_money(game.current_bet / 100.0)}"
    bet = IO.gets("  Enter New Bet: $")

    cond do
      is_float(bet) ->
        trunc(bet)
      is_integer(bet) ->
        bet
      true ->
        Game.get_bet(game)
    end
  end

  def get_new_bet(game) do
    bet = Game.get_bet(game)

    %Game{game | current_bet: bet * 100}
    |> Game.normalize_current_bet!
    |> Game.deal_new_hand
  end

  def play_more_hands!(game) do
    game = %Game{game | current_player_hand: game.current_player_hand + 1}

    player_hand = game.player_hands
                  |> elem(game.current_player_hand)

    {hand, shoe} = Hand.deal_card!(player_hand, game.shoe)
    player_hand = %PlayerHand{player_hand | hand: hand}
    player_hands = List.replace_at(game.player_hands, game.current_player_hand, player_hand)

    game = %Game{game | shoe: shoe, player_hands: player_hands}

    if PlayerHand.is_done?(player_hand, game) do
      PlayerHand.process(game)
    else
      Game.draw_hands(game)
      |> PlayerHand.get_action(player_hand)
    end
  end
end
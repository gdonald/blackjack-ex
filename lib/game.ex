defmodule Blackjack.Game do
  defstruct num_decks: 1,
            money: 10000,
            current_bet: 500,
            dealer_hand: nil,
            player_hands: [],
            current_player_hand: 0,
            shoe: nil,
            min_bet: 500,
            max_bet: 10000000,
            save_file: "bj.txt"

  alias Blackjack.{DealerHand, Game, Hand, PlayerHand}

  def run(_args \\ []) do
    # game = %Game{}
  end

  def max_player_hands do
    7
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

  def draw_hands(game) do
    Game.clear(game)

    IO.puts("\n Dealer:\n")
    DealerHand.to_s(game.dealer_hand)

    IO.puts("\n Player $#{game.money / 100.0}:\n")
    IO.puts(
      Enum.reduce(
        game.player_hands,
        "",
        fn (player_hand, acc) ->
          acc <> PlayerHand.to_s(player_hand)
        end
      )
    )

    game
  end

  #  def draw_bet_options(game) do
  #    IO.puts " (D) Deal Hand  (B) Change Bet  (O) Options  (Q) Quit"
  #
  #    char = IO.getn("", 1)
  #    cond do
  #      char == "d" ->
  #        Game.deal_new_hand(game)
  #      char == "b" ->
  #        Game.get_new_bet(game)
  #      char == "o" ->
  #        Game.draw_game_options(game)
  #      char == "q" ->
  #        Game.clear(game)
  #      true ->
  #        Game.clear(game)
  #        |> Game.draw_hands
  #        |> Game.draw_bet_options
  #    end
  #  end

  #  def play_more_hands!(game) do
  #    game = %Game{game | current_player_hand: game.current_player_hand + 1}
  #
  #    player_hand = game.player_hands
  #                  |> elem(game.current_player_hand)
  #
  #    {hand, shoe} = Hand.deal_card!(player_hand, game.shoe)
  #    player_hand = %PlayerHand{player_hand | hand: hand}
  #    player_hands = List.replace_at(game.player_hands, game.current_player_hand, player_hand)
  #
  #    game = %Game{game | shoe: shoe, player_hands: player_hands}
  #
  #    if PlayerHand.is_done?(player_hand) do
  #      PlayerHand.process!(player_hand, game)
  #    else
  #      Game.draw_hands(game)
  #      PlayerHand.get_action(player_hand)
  #    end
  #  end
end
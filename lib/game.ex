defmodule Blackjack.Game do
  defstruct num_decks: 1,
            money: 10000,
            current_bet: 500,
            dealer_hand: nil,
            player_hands: [],
            current_player_hand: 0,
            shoe: nil,
            min_bet: 500,
            max_bet: 10000000

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

  def unhide_dealer_down_card!(game) do
    dealer_hand = %DealerHand{game.dealer_hand | hide_down_card: false}
    %Game{game | dealer_hand: dealer_hand}
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

  #  def pay_hands!(game) do
  #    dealer_hand_value = DealerHand.get_value(game.dealer_hand, :soft)
  #    dealer_hand_busted = DealerHand.is_busted?(game.dealer_hand)
  #
  #    player_hands = Enum.reduce(
  #      game.player_hands,
  #      [],
  #      fn player_hand ->
  #        if !player_hand.payed do
  #          player_hand = %PlayerHand{player_hand | payed: true}
  #          player_hand_value = PlayerHand.get_value(player_hand, :soft)
  #
  #          cond do
  #            dealer_hand_busted || player_hand_value > dealer_hand_value ->
  #              if Hand.is_blackjack?(player_hand.hand) do
  #                player_hand = %PlayerHand{player_hand | bet: player_hand.bet * 1.5}
  #              end
  #
  #              game = %Game{game | money: game.money + player_hand.bet}
  #              player_hand = %PlayerHand{player_hand | status: :won}
  #
  #            player_hand_value < dealer_hand_value ->
  #              game = %Game{game | money: game.money - player_hand.bet}
  #              player_hand = %PlayerHand{player_hand | status: :lost}
  #
  #            true ->
  #              player_hand = %PlayerHand{player_hand | status: :push}
  #          end
  #        end
  #      end
  #    )
  #
  #    game = %Game{game | player_hands: player_hands}
  #    game = Game.normalize_current_bet!(game)
  #
  #    Game.save_game!(game)
  #  end

  #  def play_dealer_hand!(game) do
  #    if Hand.is_blackjack?(game.dealer_hand.hand) do
  #      game = Game.unhide_dealer_down_card(game)
  #    else
  #      if Game.needs_to_play_dealer_hand?(game) do
  #        game = Game.unhide_dealer_down_card(game)
  #        game = Game.deal_dealer_cards!(game)
  #      end
  #    end
  #
  #    dealer_hand = %DealerHand{game.dealer_hand | played: true}
  #    game = %Game{game | dealer_hand: dealer_hand}
  #
  #    Game.pay_hands!(game)
  #  end

  #  def play_more_hands!(game) do
  #
  #  end

  #  def to_s(game) do
  #
  #  end

  #  def draw_hands(game) do
  #
  #  end

  #  def draw_bet_options(game) do
  #
  #  end

end
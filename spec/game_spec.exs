defmodule GameSpec do
  use ESpec
  alias Blackjack.{Card, DealerHand, Game, Hand, PlayerHand, Shoe}

  let :ace, do: %Card{value: 0}
  let :two, do: %Card{value: 1}
  let :six, do: %Card{value: 5}
  let :seven, do: %Card{value: 6}
  let :eight, do: %Card{value: 7}
  let :nine, do: %Card{value: 8}
  let :ten, do: %Card{value: 9}

  let :hand_A_A, do: %Hand{cards: [ace(), ace()]}
  let :hand_A_6, do: %Hand{cards: [ace(), six()]}
  let :hand_A_10, do: %Hand{cards: [ace(), ten()]}
  let :hand_7_7, do: %Hand{cards: [seven(), seven()]}
  let :hand_10_2, do: %Hand{cards: [ten(), two()]}
  let :hand_10_6, do: %Hand{cards: [ten(), six()]}
  let :hand_10_7, do: %Hand{cards: [ten(), seven()]}
  let :hand_10_8, do: %Hand{cards: [eight(), ten()]}
  let :hand_10_9, do: %Hand{cards: [nine(), ten()]}

  let :hand_10_2_10, do: %Hand{cards: [ten(), two(), ten()]}
  let :hand_10_10_10, do: %Hand{cards: [ten(), ten(), ten()]}

  let :player_hand_7_7, do: %PlayerHand{hand: hand_7_7()}
  let :player_hand_A_10, do: %PlayerHand{hand: hand_A_10()}
  let :player_hand_10_2, do: %PlayerHand{hand: hand_10_2()}
  let :player_hand_10_7, do: %PlayerHand{hand: hand_10_7()}
  let :player_hand_10_9, do: %PlayerHand{hand: hand_10_9()}

  let :player_hand_10_2_10, do: %PlayerHand{hand: hand_10_2_10(), paid: true}
  let :player_hand_10_10_10, do: %PlayerHand{hand: hand_10_10_10(), paid: true}

  let :dealer_hand_A_6, do: %DealerHand{hand: hand_A_6(), hide_down_card: false}
  let :dealer_hand_10_8, do: %DealerHand{hand: hand_10_8(), hide_down_card: false}
  let :dealer_hand_10_6, do: %DealerHand{hand: hand_10_6(), hide_down_card: false}
  let :dealer_hand_10_7, do: %DealerHand{hand: hand_10_7(), hide_down_card: false}

  let :dealer_hand_10_2_10, do: %DealerHand{hand: hand_10_2_10(), hide_down_card: false}

  describe "Game.insure_hand!/1" do
    let :player_hand, do: %PlayerHand{hand: hand_7_7()}
    let :game, do: %Game{player_hands: [player_hand()]}

    it "returns false" do
      [player_hand] = Game.insure_hand!(game()).player_hands
      expect player_hand.bet
             |> to(eq 250)
      expect player_hand.paid
             |> to(be_true())
      expect player_hand.played
             |> to(be_true())
      expect player_hand.status
             |> to(eq :lost)
    end
  end

  describe "Game.needs_to_offer_insurance?/1" do
    context "when dealer up card is an ace and player hand is not blackjack" do
      let :dealer_hand, do: %DealerHand{hand: hand_A_6()}
      let :player_hand, do: %PlayerHand{hand: hand_7_7()}

      it "returns true" do
        expect Game.needs_to_offer_insurance?(dealer_hand(), player_hand())
               |> to(be_true())
      end
    end

    context "when dealer up card is an ace and player hand is blackjack" do
      let :dealer_hand, do: %DealerHand{hand: hand_A_A()}
      let :player_hand, do: %PlayerHand{hand: hand_A_10()}

      it "returns false" do
        expect Game.needs_to_offer_insurance?(dealer_hand(), player_hand())
               |> to(be_false())
      end
    end

    context "when dealer up card is not an ace" do
      let :dealer_hand, do: %DealerHand{hand: hand_7_7()}
      let :player_hand, do: %PlayerHand{hand: hand_7_7()}

      it "returns false" do
        expect Game.needs_to_offer_insurance?(dealer_hand(), player_hand())
               |> to(be_false())
      end
    end
  end

  describe "Game.shuffle/1" do
    context "needs to shuffle" do
      let :game,
          do: %Game{
            shoe: %Shoe{
              cards: []
            }
          }

      it "shuffles the shoe" do
        game = Game.shuffle(game())

        expect length(game.shoe.cards)
               |> to(eq 52)
      end
    end

    context "does not need to shuffle" do
      let :shoe, do: Shoe.new_regular(1)
      let :game, do: %Game{shoe: shoe()}

      it "does not shuffle the shoe" do
        game = Game.shuffle(game())

        expect length(game.shoe.cards)
               |> to(eq 52)
      end
    end
  end

  describe "Game.normalize_deck_type!/1" do
    context "deck type is too high" do
      let :game, do: %Game{deck_type: 7}

      it "normalizes the deck type to regular" do
        game = Game.normalize_deck_type!(game())
        expect game.deck_type
               |> to(eq 1)
      end
    end

    context "deck type is too low" do
      let :game, do: %Game{deck_type: 0}

      it "normalizes the deck type to regular" do
        game = Game.normalize_deck_type!(game())
        expect game.deck_type
               |> to(eq 1)
      end
    end

    context "deck type is already normal" do
      let :game, do: %Game{deck_type: 1}

      it "does not change the deck type" do
        game = Game.normalize_deck_type!(game())
        expect game.deck_type
               |> to(eq 1)
      end
    end
  end

  describe "Game.normalize_num_decks!/1" do
    context "deck count is too high" do
      let :game, do: %Game{num_decks: 9}

      it "normalizes the number of decks to 8" do
        game = Game.normalize_num_decks!(game())
        expect game.num_decks
               |> to(eq 8)
      end
    end

    context "deck count is too low" do
      let :game, do: %Game{num_decks: 0}

      it "normalizes the number of decks to 1" do
        game = Game.normalize_num_decks!(game())
        expect game.num_decks
               |> to(eq 1)
      end
    end

    context "deck count is already normal" do
      let :game, do: %Game{num_decks: 1}

      it "does not change the number of decks" do
        game = Game.normalize_num_decks!(game())
        expect game.num_decks
               |> to(eq 1)
      end
    end
  end

  describe "Game.current_player_hand/1" do
    let :player_hand, do: %PlayerHand{}
    let :game, do: %Game{player_hands: [player_hand(), player_hand_7_7()]}

    it "returns the current player hand" do
      expect Game.current_player_hand(game())
             |> to(eq player_hand())
    end
  end

  describe "Game.all_bets/1" do
    let :player_hand, do: %PlayerHand{bet: 1000}
    let :game, do: %Game{player_hands: [player_hand(), player_hand_7_7()]}

    it "returns 1000" do
      expect Game.all_bets(game())
             |> to(eq 1500)
    end
  end

  describe "Game.more_hands_to_play?/1" do
    context "one player hand" do
      let :game, do: %Game{current_player_hand_index: 0, player_hands: [%PlayerHand{}]}

      it "returns false" do
        expect Game.more_hands_to_play?(game())
               |> to(be_false())
      end
    end

    context "two player hands, currently on the first hand" do
      let :game, do: %Game{current_player_hand_index: 0, player_hands: [%PlayerHand{}, %PlayerHand{}]}

      it "returns true" do
        expect Game.more_hands_to_play?(game())
               |> to(be_true())
      end
    end

    context "two player hands, currently on the second hand" do
      let :game, do: %Game{current_player_hand_index: 1, player_hands: [%PlayerHand{}, %PlayerHand{}]}

      it "returns false" do
        expect Game.more_hands_to_play?(game())
               |> to(be_false())
      end
    end
  end

  describe "Game.needs_to_play_dealer_hand?/1" do
    context "one non-busted, non-blackjack hand" do
      let :game, do: %Game{player_hands: [player_hand_7_7()]}

      it "returns true" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_true())
      end
    end

    context "one non-busted, non-blackjack hand and a busted hand" do
      let :game, do: %Game{player_hands: [player_hand_7_7(), player_hand_10_10_10()]}

      it "returns true" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_true())
      end
    end

    context "one non-busted, non-blackjack hand and a blackjack hand" do
      let :game, do: %Game{player_hands: [player_hand_7_7(), player_hand_A_10()]}

      it "returns true" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_true())
      end
    end

    context "one busted hand" do
      let :game, do: %Game{player_hands: [player_hand_10_10_10()]}

      it "returns false" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_false())
      end
    end

    context "one blackjack hand" do
      let :game, do: %Game{player_hands: [player_hand_A_10()]}

      it "returns false" do
        expect Game.needs_to_play_dealer_hand?(game())
               |> to(be_false())
      end
    end
  end

  describe "Game.unhide_dealer_down_card!/1" do
    let :dealer_hand, do: %DealerHand{hand: hand_A_10(), hide_down_card: true}
    let :game, do: %Game{dealer_hand: dealer_hand()}

    context "dealer hand is blackjack" do
      it "flips dealer down card" do
        expect game().dealer_hand.hide_down_card
               |> to(be_true())
        game = Game.unhide_dealer_down_card!(game())
        expect game.dealer_hand.hide_down_card
               |> to(be_false())
      end
    end

    context "dealer hand needs to be played" do
      let :dealer_hand, do: %DealerHand{hand: hand_10_6(), hide_down_card: true}
      let :game, do: %Game{dealer_hand: dealer_hand(), player_hands: [player_hand_7_7()]}

      it "flips dealer down card" do
        expect game().dealer_hand.hide_down_card
               |> to(be_true())
        game = Game.unhide_dealer_down_card!(game())
        expect game.dealer_hand.hide_down_card
               |> to(be_false())
      end
    end

    context "dealer hand does not need to be played and not blackjack" do
      let :dealer_hand, do: %DealerHand{hand: hand_10_8(), hide_down_card: true}
      let :game, do: %Game{dealer_hand: dealer_hand(), player_hands: [player_hand_10_10_10()]}

      it "does not flip dealer down card" do
        expect game().dealer_hand.hide_down_card
               |> to(be_true())
        game = Game.unhide_dealer_down_card!(game())
        expect game.dealer_hand.hide_down_card
               |> to(be_true())
      end
    end
  end

  describe "Game.deal_dealer_cards!/1" do
    let :shoe, do: %Shoe{cards: [ace()]}

    context "soft 17" do
      let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand_A_6()}

      it "takes a card" do
        expect length(game().dealer_hand.hand.cards)
               |> to(eq 2)
        game = Game.deal_dealer_cards!(game())
        expect length(game.dealer_hand.hand.cards)
               |> to(eq 3)
      end
    end

    context "soft 18" do
      let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand_10_7()}

      it "takes no cards" do
        expect length(game().dealer_hand.hand.cards)
               |> to(eq 2)
        game = Game.deal_dealer_cards!(game())
        expect length(game.dealer_hand.hand.cards)
               |> to(eq 2)
      end
    end

    context "hard 16" do
      let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand_10_6()}

      it "takes a card" do
        expect length(game().dealer_hand.hand.cards)
               |> to(eq 2)
        game = Game.deal_dealer_cards!(game())
        expect length(game.dealer_hand.hand.cards)
               |> to(eq 3)
      end
    end

    context "hard 17" do
      let :game, do: %Game{shoe: shoe(), dealer_hand: dealer_hand_10_7()}

      it "takes no cards" do
        expect length(game().dealer_hand.hand.cards)
               |> to(eq 2)
        game = Game.deal_dealer_cards!(game())
        expect length(game.dealer_hand.hand.cards)
               |> to(eq 2)
      end
    end
  end

  describe "Game.normalize_current_bet!/1" do
    context "current bet has sufficient money and is in range" do
      let :game, do: %Game{current_bet: 500}

      it "does not alter the current bet" do
        game = Game.normalize_current_bet!(game())
        expect game.current_bet
               |> to(eq 500)
      end
    end

    context "current bet has insufficient money" do
      let :game, do: %Game{current_bet: 10500}

      it "alters the current bet" do
        game = Game.normalize_current_bet!(game())
        expect game.current_bet
               |> to(eq 10000)
      end
    end

    context "current bet is more than max bet" do
      let :game, do: %Game{money: 10000000, current_bet: 10000500}

      it "alters the current bet" do
        game = Game.normalize_current_bet!(game())
        expect game.current_bet
               |> to(eq 10000000)
      end
    end

    context "current bet is less than min bet" do
      let :game, do: %Game{current_bet: 499}

      it "alters the current bet" do
        game = Game.normalize_current_bet!(game())
        expect game.current_bet
               |> to(eq 500)
      end
    end
  end

  describe "Game.save_game!/1" do
    let :game, do: %Game{}

    it "persists a save game file to disk" do
      Game.save_game!(game())
      expect File.read!("bj.txt")
             |> to(eq "1|10000|500")
    end
  end

  describe "Game.load_game!/1" do
    let :game, do: %Game{num_decks: 0, money: 0, current_bet: 0}

    it "reads a persisted game file from disk" do
      File.write(game().save_file, "1|10000|500")
      game = Game.load_game!(game())
      expect game.num_decks
             |> to(eq 1)
      expect game.money
             |> to(eq 10000)
      expect game.current_bet
             |> to(eq 500)
    end
  end

  describe "Game.pay_player_hands!/1" do
    context "dealer: 18, player: [19]" do
      let :game, do: %Game{dealer_hand: dealer_hand_10_8(),
        player_hands: [player_hand_10_9()]}

      it "pays one player hand" do
        game = Game.pay_player_hands!(game())
        expect game.money
               |> to(eq 10500)
      end
    end

    context "dealer: 18, player: [17, 19, 22]" do
      let :game, do: %Game{dealer_hand: dealer_hand_10_8(),
        player_hands: [player_hand_10_7(), player_hand_10_9(), player_hand_10_2_10()]}

      it "pays one player hand" do
        game = Game.pay_player_hands!(game())
        expect game.money
               |> to(eq 10000)
      end
    end

    context "dealer: 22, player: [17, 19, 22]" do
      let :game, do: %Game{dealer_hand: dealer_hand_10_2_10(),
        player_hands: [player_hand_10_7(), player_hand_10_9(), player_hand_10_2_10()]}

      it "pays two player hands" do
        game = Game.pay_player_hands!(game())
        expect game.money
               |> to(eq 11000)
      end
    end
  end

  describe "Game.play_dealer_hand!/1" do
    let :shoe, do: %Shoe{cards: [ace()]}

    context "needs to play the dealer hand" do
      let :game, do: %Game{shoe: shoe(),
        dealer_hand: dealer_hand_10_6(),
        player_hands: [player_hand_10_9()]}

      it "plays the dealer hand" do
        game = Game.play_dealer_hand!(game())
        expect game.money
               |> to(eq 10500)
      end
    end

    context "does not need to play the dealer hand" do
      let :game, do: %Game{shoe: shoe(),
        dealer_hand: dealer_hand_10_8(),
        player_hands: [player_hand_10_10_10()]}

      it "does not play the dealer hand, player hand is busted and already paid" do
        game = Game.play_dealer_hand!(game())
        expect game.money
               |> to(eq 10000)
      end
    end
  end

  describe "Game.clear/1" do
    it "outputs escape sequences to clear terminal" do
    end
  end

  describe "Game.format_money/1" do
    it "outputs money as a formatted string" do
      expect Game.format_money(1.0)
             |> to(eq "1.00")
    end

    it "outputs money as a formatted string" do
      expect Game.format_money(1.5)
             |> to(eq "1.50")
    end

    it "outputs money as a formatted string" do
      expect Game.format_money(1.75)
             |> to(eq "1.75")
    end

    it "outputs money as a formatted string" do
      expect Game.format_money(1.234)
             |> to(eq "1.23")
    end
  end

  describe "Game.to_s/1" do
    let :game, do: %Game{
      dealer_hand: dealer_hand_10_6(),
      player_hands: [player_hand_10_9(), player_hand_A_10()]}

    it "returns game as a string" do
      expected = "\r\n Dealer:\r\n 🂪 🂦 ⇒  16\r\n\r\n Player $100.00:\r\n 🂩 🂪 ⇒  19  $5.00 ⇐  \r\n 🂡 🂪 ⇒  21  $5.00  \r\n\r\n"
      expect Game.to_s(game())
             |> to(eq expected)
    end
  end

  describe "Game.draw_hands/1" do
    let :game, do: %Game{
      dealer_hand: dealer_hand_10_6(),
      player_hands: [player_hand_10_9(), player_hand_A_10()]}

    it "draws the game as a string" do
      expected = "\e[H\e[2J\r\n Dealer:\r\n 🂪 🂦 ⇒  16\r\n\r\n Player $100.00:\r\n 🂩 🂪 ⇒  19  $5.00 ⇐  \r\n 🂡 🂪 ⇒  21  $5.00  \r\n\r\n"
      expect capture_io(fn -> Game.draw_hands(game()) end)
             |> to(eq expected)
    end
  end

  #  describe "Game.draw_bet_options/1" do
  #    let :game, do: %Game{
  #      dealer_hand: dealer_hand_10_6(),
  #      player_hands: [player_hand_10_9()]}
  #
  #    it "draws bet options" do
  #      expect IO.puts "d"
  #                     |> capture_io(
  #                          fn ->
  #                            Game.draw_bet_options(game())
  #                          end
  #                        )
  #                     |> to(eq "")
  #    end
  #  end
end

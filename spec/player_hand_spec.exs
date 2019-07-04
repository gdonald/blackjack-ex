defmodule PlayerHandSpec do
  use ESpec
  alias Blackjack.{Card, Game, Hand, PlayerHand}

  let :game, do: %Game{}
  let :ace, do: %Card{value: 0}
  let :ten, do: %Card{value: 9}
  let :seven, do: %Card{value: 6}
  let :eight, do: %Card{value: 7}

  let :hand_A_A, do: %Hand{cards: [ace(), ace()]}
  let :hand_A_8, do: %Hand{cards: [ace(), eight()]}
  let :hand_A_10, do: %Hand{cards: [ace(), ten()]}
  let :hand_8_8, do: %Hand{cards: [eight(), eight()]}
  let :hand_10_7, do: %Hand{cards: [ten(), seven()]}
  let :hand_10_8, do: %Hand{cards: [ten(), eight()]}
  let :hand_10_10, do: %Hand{cards: [ten(), ten()]}

  let :hand_A_A_10, do: %Hand{cards: [ace(), ace(), ten()]}
  let :hand_A_10_10, do: %Hand{cards: [ace(), ten(), ten()]}
  let :hand_7_7_7, do: %Hand{cards: [seven(), seven(), seven()]}
  let :hand_8_8_8, do: %Hand{cards: [eight(), eight(), eight()]}
  let :hand_10_10_10, do: %Hand{cards: [ten(), ten(), ten()]}

  let :player_hand_A_A, do: %PlayerHand{hand: hand_A_A()}
  let :player_hand_A_8, do: %PlayerHand{hand: hand_A_8()}
  let :player_hand_A_10, do: %PlayerHand{hand: hand_A_10()}
  let :player_hand_8_8, do: %PlayerHand{hand: hand_8_8()}
  let :player_hand_10_7, do: %PlayerHand{hand: hand_10_7()}
  let :player_hand_10_8, do: %PlayerHand{hand: hand_10_8()}
  let :player_hand_10_10, do: %PlayerHand{hand: hand_10_10()}

  let :player_hand_A_A_10, do: %PlayerHand{hand: hand_A_A_10()}
  let :player_hand_A_10_10, do: %PlayerHand{hand: hand_A_10_10()}
  let :player_hand_7_7_7, do: %PlayerHand{hand: hand_7_7_7()}
  let :player_hand_8_8_8, do: %PlayerHand{hand: hand_8_8_8()}
  let :player_hand_10_10_10, do: %PlayerHand{hand: hand_10_10_10()}

  describe "PlayerHand.pay!/3" do
    context "payed hand" do
      let :player_hand, do: %PlayerHand{payed: true}

      it "returns the hand" do
        expect PlayerHand.pay!(player_hand(), false, 21)
               |> to(eq {player_hand(), 0})
      end
    end

    context "unpayed, tied hands" do
      it "returns {player_hand, 0}" do
        {player_hand, money} = PlayerHand.pay!(player_hand_10_8(), 18, false)
        expect player_hand.payed
               |> to(be_true())
        expect player_hand.status
               |> to(eq :push)
        expect money
               |> to(eq 0)
      end
    end

    context "unpayed, player has 12, dealer busted" do
      let :player_hand,
          do: %PlayerHand{
            hand: %Hand{
              cards: [ace(), ace()]
            }
          }

      it "returns {player_hand, 500}" do
        {player_hand, money} = PlayerHand.pay!(player_hand_A_A(), 22, true)
        expect player_hand.payed
               |> to(be_true())
        expect player_hand.status
               |> to(eq :won)
        expect money
               |> to(eq 500)
      end
    end

    context "unpayed, player has blackjack, dealer has 20" do
      it "returns {player_hand, 750}" do
        {player_hand, money} = PlayerHand.pay!(player_hand_A_10(), 20, false)
        expect player_hand.payed
               |> to(be_true())
        expect player_hand.status
               |> to(eq :won)
        expect money
               |> to(eq 750)
      end
    end

    context "unpayed, player has 20, dealer has 19" do
      it "returns {player_hand, 500}" do
        {player_hand, money} = PlayerHand.pay!(player_hand_10_10(), 19, false)
        expect player_hand.payed
               |> to(be_true())
        expect player_hand.status
               |> to(eq :won)
        expect money
               |> to(eq 500)
      end
    end

    context "unpayed, player has 18, dealer has 20" do
      it "returns {player_hand, -500}" do
        {player_hand, money} = PlayerHand.pay!(player_hand_10_8(), 20, false)
        expect player_hand.payed
               |> to(be_true())
        expect player_hand.status
               |> to(eq :lost)
        expect money
               |> to(eq -500)
      end
    end
  end

  describe "PlayerHand.promoted_bet/1" do
    context "blackjack" do
      it "is promoted" do
        expect PlayerHand.promoted_bet(player_hand_A_10())
               |> to(eq 750)
      end
    end

    context "non-blackjack" do
      it "is not promoted" do
        expect PlayerHand.promoted_bet(player_hand_10_7())
               |> to(eq 500)
      end
    end
  end

  describe "PlayerHand.get_value/2" do
    it "a soft count with [🂡, 🂫] returns 21" do
      expect PlayerHand.get_value(player_hand_A_10(), :soft)
             |> to(eq 21)
    end

    it "a hard count with [🂡, 🂫] returns 11" do
      expect PlayerHand.get_value(player_hand_A_10(), :hard)
             |> to(eq 11)
    end

    context "force hard count" do
      it "a soft count with [🂡, 🂡, 🂫] returns 12" do
        expect PlayerHand.get_value(player_hand_A_A_10(), :soft)
               |> to(eq 12)
      end
    end
  end

  describe "PlayerHand.is_busted?/1" do
    let :eight, do: %Card{value: 7}

    it "returns true" do
      expect PlayerHand.is_busted?(player_hand_8_8_8())
             |> to(be_true())
    end

    it "returns false" do
      expect PlayerHand.is_busted?(player_hand_8_8())
             |> to(be_false())
    end
  end

  describe "PlayerHand.is_played?/1" do
    it "returns true for played hand" do
      player_hand = %PlayerHand{played: true}
      expect PlayerHand.is_played?(player_hand)
             |> to(be_true())
    end

    it "returns true for stood hand" do
      player_hand = %PlayerHand{stood: true}
      expect PlayerHand.is_played?(player_hand)
             |> to(be_true())
    end

    it "returns true for blackjack" do
      expect PlayerHand.is_played?(player_hand_A_10())
             |> to(be_true())
    end

    it "returns true for soft 21" do
      expect PlayerHand.is_played?(player_hand_7_7_7())
             |> to(be_true())
    end

    it "returns true for hard 21" do
      expect PlayerHand.is_played?(player_hand_A_10_10())
             |> to(be_true())
    end

    it "returns true for busted hand" do
      expect PlayerHand.is_played?(player_hand_8_8_8())
             |> to(be_true())
    end
  end

  describe "PlayerHand.handle_busted_hand!/2" do
    context "busted hand" do
      it "returns updated player_hand and game" do
        expect {player_hand, game} = PlayerHand.handle_busted_hand!(player_hand_8_8_8(), game())
        expect player_hand.payed
               |> to(be_true())
        expect player_hand.status
               |> to(eq :lost)
        expect game.money
               |> to(eq 9500)
      end
    end

    context "not busted hand" do
      it "returns updated player_hand and game" do
        expect {player_hand, game} = PlayerHand.handle_busted_hand!(player_hand_8_8(), game())
        expect player_hand.payed
               |> to(be_false())
        expect player_hand.status
               |> to(eq :unknown)
        expect game.money
               |> to(eq 10000)
      end
    end
  end

  describe "PlayerHand.is_done?/2" do
    it "returns true" do
      player_hand = %PlayerHand{hand: hand_8_8(), played: true}
      {result, player_hand, _game} = PlayerHand.is_done?(player_hand, %Game{})
      expect result
             |> to(be_true())
      expect player_hand.played
             |> to(be_true())
    end

    it "returns false" do
      {result, player_hand, _game} = PlayerHand.is_done?(player_hand_8_8(), %Game{})
      expect result
             |> to(be_false())
      expect player_hand.played
             |> to(be_false())
    end
  end

  describe "PlayerHand.to_s/1" do
    it "returns face for second card" do
      expect PlayerHand.to_s(player_hand_A_10())
             |> to(eq " 🂡 🂪 ⇒  21")
    end
  end

  describe "PlayerHand.can_split?/2" do
    context "a stood hand" do
      let :player_hand, do: %PlayerHand{stood: true}

      it "cannot split" do
        expect PlayerHand.can_split?(player_hand(), %Game{})
               |> to(be_false())
      end
    end

    context "cannot split more than 7 hands" do
      let :game, do: %Game{player_hands: (for _ <- 1..7, do: %PlayerHand{})}

      it "returns false" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_split?(player_hand, game())
               |> to(be_false())
      end
    end

    context "cannot split without enough money" do
      let :game, do: %Game{money: 1499, player_hands: (for _ <- 1..2, do: player_hand_10_10())}

      it "returns false" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_split?(player_hand, game())
               |> to(be_false())
      end
    end

    context "cannot split a hand with different card values" do
      it "returns false" do
        expect PlayerHand.can_split?(player_hand_A_10(), %Game{})
               |> to(be_false())
      end
    end

    context "cannot split a hand with more than 2 cards" do
      it "returns false" do
        expect PlayerHand.can_split?(player_hand_A_A_10(), %Game{})
               |> to(be_false())
      end
    end

    context "can split a hand with matching card values" do
      it "returns true" do
        expect PlayerHand.can_split?(player_hand_10_10(), %Game{})
               |> to(be_true())
      end
    end
  end

  describe "PlayerHand.can_double?/2" do
    context "a stood hand" do
      let :player_hand, do: %PlayerHand{stood: true}

      it "cannot double" do
        expect PlayerHand.can_double?(player_hand(), %Game{})
               |> to(be_false())
      end
    end

    context "cannot double a hand with more than 2 cards" do
      let :game, do: %Game{player_hands: [player_hand_A_A_10()]}

      it "returns false" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_double?(player_hand, game())
               |> to(be_false())
      end
    end

    context "cannot double a blackjack" do
      let :game, do: %Game{player_hands: [player_hand_A_10()]}

      it "returns false" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_double?(player_hand, game())
               |> to(be_false())
      end
    end

    context "cannot double without enough money" do
      let :game, do: %Game{money: 1499, player_hands: (for _ <- 1..2, do: player_hand_A_8())}

      it "returns false" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_double?(player_hand, game())
               |> to(be_false())
      end
    end

    context "can double" do
      let :game, do: %Game{money: 1500, player_hands: (for _ <- 1..2, do: player_hand_A_8())}

      it "returns true" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_double?(player_hand, game())
               |> to(be_true())
      end
    end
  end

  describe "PlayerHand.can_stand?/1" do
    context "a non-stood hand" do
      it "can stand" do
        expect PlayerHand.can_stand?(player_hand_10_10())
               |> to(be_true())
      end
    end

    context "a stood hand" do
      let :player_hand, do: %PlayerHand{stood: true}

      it "cannot stand" do
        expect PlayerHand.can_stand?(player_hand())
               |> to(be_false())
      end
    end

    context "a busted hand" do
      it "returns false" do
        expect PlayerHand.can_stand?(player_hand_10_10_10())
               |> to(be_false())
      end
    end

    context "a blackjack" do
      it "returns false" do
        expect PlayerHand.can_stand?(player_hand_A_10())
               |> to(be_false())
      end
    end
  end

  describe "PlayerHand.can_hit?/1" do
    context "a non-stood hand" do
      it "can stand" do
        expect PlayerHand.can_hit?(player_hand_10_10())
               |> to(be_true())
      end
    end

    context "a stood hand" do
      let :player_hand, do: %PlayerHand{stood: true}

      it "cannot stand" do
        expect PlayerHand.can_hit?(player_hand())
               |> to(be_false())
      end
    end

    context "a played hand" do
      let :player_hand, do: %PlayerHand{played: true}

      it "cannot stand" do
        expect PlayerHand.can_hit?(player_hand())
               |> to(be_false())
      end
    end

    context "a hard 21" do
      it "returns false" do
        expect PlayerHand.can_hit?(player_hand_A_10_10())
               |> to(be_false())
      end
    end

    context "a blackjack" do
      it "returns false" do
        expect PlayerHand.can_hit?(player_hand_A_10())
               |> to(be_false())
      end
    end

    context "a busted hand" do
      it "returns false" do
        expect PlayerHand.can_hit?(player_hand_10_10_10())
               |> to(be_false())
      end
    end
  end
end

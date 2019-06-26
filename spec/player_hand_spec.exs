defmodule PlayerHandSpec do
  use ESpec
  alias Blackjack.{Card, Game, Hand, PlayerHand}

  let :game, do: %Game{}
  let :ace, do: %Card{value: 0}
  let :ten, do: %Card{value: 9}
  let :seven, do: %Card{value: 6}
  let :eight, do: %Card{value: 7}
  let :player_hand,
      do: %PlayerHand{
        hand: %Hand{
          cards: [ace(), ten()]
        }
      }

  describe "PlayerHand.get_value/2" do
    it "a soft count with [🂡, 🂫] returns 21" do
      expect PlayerHand.get_value(player_hand(), :soft)
             |> to(eq 21)
    end

    it "a hard count with [🂡, 🂫] returns 11" do
      expect PlayerHand.get_value(player_hand(), :hard)
             |> to(eq 11)
    end

    context "force hard count" do
      let :player_hand,
          do: %PlayerHand{
            hand: %Hand{
              cards: [ace(), ace(), ten()]
            }
          }

      it "a soft count with [🂡, 🂡, 🂫] returns 12" do
        expect PlayerHand.get_value(player_hand(), :soft)
               |> to(eq 12)
      end
    end
  end

  describe "PlayerHand.is_busted?/1" do
    let :eight, do: %Card{value: 7}

    it "returns true" do
      player_hand = %PlayerHand{
        hand: %Hand{
          cards: [eight(), eight(), eight()]
        }
      }
      expect PlayerHand.is_busted?(player_hand)
             |> to(be_true())
    end

    it "returns false" do
      player_hand = %PlayerHand{
        hand: %Hand{
          cards: [eight(), eight()]
        }
      }
      expect PlayerHand.is_busted?(player_hand)
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
      expect PlayerHand.is_played?(player_hand())
             |> to(be_true())
    end

    it "returns true for soft 21" do
      player_hand = %PlayerHand{
        hand: %Hand{
          cards: [seven(), seven(), seven()]
        }
      }
      expect PlayerHand.is_played?(player_hand)
             |> to(be_true())
    end

    it "returns true for hard 21" do
      player_hand = %PlayerHand{
        hand: %Hand{
          cards: [ace(), ten(), ten()]
        }
      }
      expect PlayerHand.is_played?(player_hand)
             |> to(be_true())
    end

    it "returns true for busted hand" do
      player_hand = %PlayerHand{
        hand: %Hand{
          cards: [eight(), eight(), eight()]
        }
      }
      expect PlayerHand.is_played?(player_hand)
             |> to(be_true())
    end
  end

  describe "PlayerHand.handle_busted_hand!/2" do
    context "busted hand" do
      let :hand, do: %Hand{cards: [eight(), eight(), eight()]}
      let :player_hand, do: %PlayerHand{hand: hand()}

      it "returns updated player_hand and game" do
        expect {player_hand, game} = PlayerHand.handle_busted_hand!(player_hand(), game())
        expect player_hand.payed
               |> to(be_true())
        expect player_hand.status
               |> to(eq :lost)
        expect game.money
               |> to(eq 9500)
      end
    end

    context "not busted hand" do
      let :hand, do: %Hand{cards: [eight(), eight()]}
      let :player_hand, do: %PlayerHand{hand: hand()}

      it "returns updated player_hand and game" do
        expect {player_hand, game} = PlayerHand.handle_busted_hand!(player_hand(), game())
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
      hand = %Hand{cards: [eight(), eight()]}
      player_hand = %PlayerHand{hand: hand, played: true}
      {result, player_hand, _game} = PlayerHand.is_done?(player_hand, game())
      expect result
             |> to(be_true())
      expect player_hand.played
             |> to(be_true())
    end

    it "returns false" do
      hand = %Hand{cards: [eight(), eight()]}
      player_hand = %PlayerHand{hand: hand, played: false}
      {result, player_hand, _game} = PlayerHand.is_done?(player_hand, game())
      expect result
             |> to(be_false())
      expect player_hand.played
             |> to(be_false())
    end
  end

  describe "PlayerHand.to_s/1" do
    it "returns face for second card" do
      expect PlayerHand.to_s(player_hand())
             |> to(eq " 🂡 🂪 ⇒  21")
    end
  end

  describe "PlayerHand.can_split?/2" do
    context "a stood hand" do
      let :player_hand, do: %PlayerHand{stood: true}

      it "cannot split" do
        expect PlayerHand.can_split?(player_hand(), game())
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
      let :game, do: %Game{money: 1499, player_hands: (for _ <- 1..2, do: %PlayerHand{hand: %Hand{
        cards: [ten(), ten()]
      }})}

      it "returns false" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_split?(player_hand, game())
               |> to(be_false())
      end
    end

    context "cannot split a hand with different card values" do
      let :game,
          do: %Game{
            player_hands: [
              %PlayerHand{
                hand: %Hand{
                  cards: [ace(), ten()]
                }
              }
            ]
          }

      it "returns false" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_split?(player_hand, game())
               |> to(be_false())
      end
    end

    context "cannot split a hand with more than 2 cards" do
      let :game,
          do: %Game{
            player_hands: [
              %PlayerHand{
                hand: %Hand{
                  cards: [ace(), ace(), ten()]
                }
              }
            ]
          }

      it "returns false" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_split?(player_hand, game())
               |> to(be_false())
      end
    end

    context "can split a hand with matching card values" do
      let :game,
          do: %Game{
            player_hands: [
              %PlayerHand{
                hand: %Hand{
                  cards: [ten(), ten()]
                }
              }
            ]
          }

      it "returns true" do
        [player_hand | _rest] = game().player_hands
        expect PlayerHand.can_split?(player_hand, game())
               |> to(be_true())
      end
    end
  end
end

defmodule HandSpec do
  use ESpec
  alias Blackjack.{Card, Hand}

  describe "Hand.is_blackjack?/1" do
    let :ace, do: %Card{value: 0}
    let :ten, do: %Card{value: 9}
    let :hand_1, do: %Hand{cards: [ace(), ten()]}
    let :hand_2, do: %Hand{cards: [ten(), ace()]}
    let :hand_3, do: %Hand{cards: [ten()]}
    let :hand_4, do: %Hand{cards: [ten(), ace(), ten()]}

    it "[🂡, 🂫] returns true" do
      expect(Hand.is_blackjack?(hand_1()))
      |> to(be_true())
    end

    it "[🂫, 🂡] returns true" do
      expect(Hand.is_blackjack?(hand_2()))
      |> to(be_true())
    end

    it "[🂫] returns false" do
      expect(Hand.is_blackjack?(hand_3()))
      |> to(be_false())
    end

    it "[🂫, 🂡, 🂫] returns false" do
      expect(Hand.is_blackjack?(hand_4()))
      |> to(be_false())
    end
  end

  describe "Hand.final_count/2" do
    let :values, do: [1, 10]

    it "a soft count with [1, 10] returns 21" do
      expect Hand.final_count(values(), :soft)
             |> to(eq 21)
    end

    it "a hard count with [1, 10] returns 11" do
      expect Hand.final_count(values(), :hard)
             |> to(eq 11)
    end
  end
end

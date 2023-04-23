class Card
  attr_reader :value, :suit

  def initialize(value, suit)
    @value = value
    @suit = suit
  end

  def to_s
    "#{suit}の#{value}"
  end

  def point
    case value
    when 'A' then 11
    when 'K', 'Q', 'J' then 10
    else value.to_i
    end
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = build_deck
  end

  def build_deck
    suits = %w[ハート ダイヤ クラブ スペード]
    values = %w[A 2 3 4 5 6 7 8 9 10 J Q K]

    suits.product(values).map { |suit, value| Card.new(value, suit) }.shuffle
  end

  def draw
    cards.pop
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def add_card(card)
    cards << card
  end

  def points
    aces = 0

    total = cards.inject(0) do |sum, card|
      aces += 1 if card.value == 'A'
      sum + card.point
    end

    aces.times { total -= 10 if total > 21 }
    total
  end

  def busted?
    points > 21
  end
end

class Player
  attr_reader :hand

  def initialize
    @hand = Hand.new
  end

  def hit(card)
    hand.add_card(card)
  end
end

class Dealer < Player
  def show_one_card
    hand.cards.first
  end
end

class Game
  attr_reader :player, :dealer, :deck

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def deal_initial_cards
    2.times do
      player.hit(deck.draw)
      dealer.hit(deck.draw)
    end
  end

  def play
    puts 'ブラックジャックを開始します。'
    deal_initial_cards

    puts "あなたの引いたカードは#{player.hand.cards[0]}です。"
    puts "あなたの引いたカードは#{player.hand.cards[1]}です。"
    puts "ディーラーの引いたカードは#{dealer.show_one_card}です。"
    puts 'ディーラーの引いた2枚目のカードはわかりません。'

    loop do
      puts "あなたの現在の得点は#{player.hand.points}です。カードを引きますか？（Y/N）"
      decision = gets.chomp.downcase
      break if decision == 'n'

      next unless decision == 'y'

      card = deck.draw
      player.hit(card)
      puts "あなたの引いたカードは#{card}です。"
      break if player.hand.busted?
    end

    if player.hand.busted?
      puts "あなたの現在の得点は#{player.hand.points}です。"
      puts 'バーストしました、あなたの負けです...'
    else
      puts "ディーラーの引いた2枚目のカードは#{dealer.hand.cards[1]}でした。"
      puts "ディーラーの現在の得点は#{dealer.hand.points}です。"

      while dealer.hand.points < 17
        card = deck.draw
        dealer.hit(card)
        puts "ディーラーの引いたカードは#{card}です。"
        puts "ディーラーの現在の得点は#{dealer.hand.points}です。"
      end

      if dealer.hand.busted?
        puts "ディーラーの得点は#{dealer.hand.points}です。あなたの勝ちです！"
      elsif player.hand.points > dealer.hand.points
        puts "あなたの得点は#{player.hand.points}です。"
        puts "ディーラーの得点は#{dealer.hand.points}です。あなたの勝ちです！"
      elsif player.hand.points < dealer.hand.points
        puts "あなたの得点は#{player.hand.points}です。"
        puts "ディーラーの得点は#{dealer.hand.points}です。あなたの負けです..."
      else
        puts '引き分けです。'
      end
      puts 'ブラックジャックを終了します。'
    end
  end
end

Game.new.play

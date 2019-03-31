class Game < ApplicationRecord
  has_many :users
  belongs_to :card_tzar, class_name: 'User',  foreign_key: "card_tzar_id", optional: true

  has_many :black_deck, -> { Card.joins(:card_template).where(card_templates: {color: "black"}, status: "deck").order(sequence: :desc) }, class_name: 'Card', dependent: :destroy
  has_many :white_deck, -> { Card.joins(:card_template).where(card_templates: {color: "white"}, status: "deck").order(sequence: :desc) }, class_name: 'Card', dependent: :destroy
  has_many :white_played, -> { Card.joins(:card_template).where(card_templates: {color: "white"}, status: "played").order(sequence: :desc) }, class_name: 'Card', dependent: :destroy
  has_one :active_black_card, -> { Card.joins(:card_template).where(card_templates: {color: "black"}, status: "played") }, class_name: 'Card', dependent: :destroy

  def setup
    CardTemplate.where(color: "black").order('random()').all.each_with_index do |card, order|
      self.black_deck.create!(card_template: card, status: "deck", face: "down", sequence: order)
    end

    CardTemplate.where(color: "white").order('random()').all.each_with_index do |card, order|
      self.black_deck.create!(card_template: card, status: "deck", face: "down", sequence: order)
    end
  end

  def reset
    Card.where(game: self).destroy_all
    self.users.delete_all
    self.update_attributes(card_tzar: nil)
  end

  def deal_cards
    self.users.each do |player|
      cards = self.white_deck.limit(7)
      cards.update_all(user_id: player.id, status: "hand")
    end
  end

  def draw_black_card
    self.active_black_card&.update_attributes(status: "used")
    card = self.black_deck.limit(1).first
    card.update_attributes(status: "played")
    return card
  end

  def next_card_tzar
    if self.card_tzar == nil
      next_tzar = self.users.order(join_order: :asc).first
    else
      next_tzar = self.users.order(join_order: :asc).where("join_order > ?", self.card_tzar.join_order)&.first
      if(next_tzar == nil)
        next_tzar = self.users.order(join_order: :asc).first
      end
    end
    self.update_attributes(card_tzar: next_tzar)
    return self.card_tzar
  end

  def get_join_order(current_user)
    if self.users.include?(current_user)
      return current_user.join_order
    else
      return self.users.order(join_order: :asc).last.join_order + 1
    end
  end

  def add_active_card(card)
    return false if (self.white_played.where(user: card.user).count > 0)
    card.update_attributes(status: "played")
    return true
  end

  def all_played?
    self.white_played.count == (self.users.count - 1)
  end

  def flip_played_cards
    self.white_played.update_all(face: "up")
  end

  def winning_card(card)
    winner = card.user
    winner.update_attributes(game_points: winner.game_points + 1, total_points: winner.total_points + 1)
  end

  def clear_played_cards
    self.white_played.update_all(status: "used")
  end

  def refill_hands
    self.users.each do |player|
      if player.cards.count < 7
        self.white_deck.first.update_attributes(user: player, status: "hand")
      end
    end
  end

  def add_user(user)
    if !self.users.include?(user)
      user.leave_game()
      user.update_attributes(join_order: self.get_join_order(user), game_points: 0)
      self.users << user

      #Deal them a hand if the game has already started when they join
      if self.state == "playing"
        cards = self.white_deck.limit(7)
        cards.update_all(user_id: user.id, status: "hand")
      end
    end
  end

  def winner
    self.users.each do |player|
      if player.game_points >= self.max_points
        return player
      end
    end
    return false
  end

  def remove_user(player)
    player.update_attributes(game: nil)

    if self.users.count == 0
      self.destroy
      return true
    end

    if self.card_tzar == player
      next_card_tzar
    end
    ActionCable.server.broadcast("game_#{self.id}", {
      type: "PLAYER_LEFT",
      params: {
        id: player.id,
        cardTzar: self.card_tzar.id
      }
    })
  end
end

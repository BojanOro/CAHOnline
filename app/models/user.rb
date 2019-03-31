class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :game, optional: true
  has_many :cards, -> { Card.joins(:card_template).where(card_templates: {color: "white"}, status: "hand") }

  def add_card_to_hand(card_template)
    self.cards.create(card_template: card_template, face: "down", game: self.game, status: "hand")
  end

  def leave_game
    if self.game
      self.game.remove_user(self)
    end
    self.update_attributes(game: nil, game_points: 0, join_order: 0)
    self.cards.destroy_all
  end

  def get_played_card
    self.game.white_played.where(user: self).first
  end

  def played_card?
    self.get_played_card != nil
  end

  def get_name
    self.name || self.email
  end

  def as_json(options)
    {
      email: self.email,
      name: self.get_name,
      points: self.game_points,
      id: self.id,
      order: self.join_order,
      played: self.played_card?
    }
  end
end

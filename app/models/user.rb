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
end

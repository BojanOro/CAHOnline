class Game < ApplicationRecord
    has_many :users
    belongs_to :card_tzar, class_name: 'User',  foreign_key: "card_tzar_id"

    has_many :black_deck, -> { Card.joins(:card_template).where(card_templates: {color: "black"}, status: "deck") }, class_name: 'Card'
    has_many :white_deck, -> { Card.joins(:card_template).where(card_templates: {color: "white"}, status: "deck") }, class_name: 'Card'
    has_many :white_played, -> { Card.joins(:card_template).where(card_templates: {color: "white"}, status: "played") }, class_name: 'Card'
    has_one :active_black_card, -> { Card.joins(:card_template).where(card_templates: {color: "black"}, status: "played") }, class_name: 'Card'
end

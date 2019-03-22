class Card < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :game
  belongs_to :card_template

  def text
    self.card_template.text
  end

  def color
    self.card_template.color
  end
end

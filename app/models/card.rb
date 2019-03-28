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

  def as_json(options)
    {
      id: self.id,
      card_template: self.card_template,
      face: self.face,
      sequence: self.sequence
    }
  end
end

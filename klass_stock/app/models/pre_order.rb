class PreOrder < ActiveRecord::Base
  validates :symbol, :side, :volume, :price, presence: true

  scope :active, -> { where(active: true).order(:symbol, :side, :price) }
end

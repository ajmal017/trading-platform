class Stock < ActiveRecord::Base
  belongs_to :company

  scope :active, -> { where active: true }
  scope :set, -> { where(market: 'SET', active: true).order(:symbol) }
  scope :mai, -> { where(market: 'mai', active: true).order(:symbol) }
  scope :set50, -> { where(set50: true).order(:symbol) }
  scope :set100, -> { where(set100: true).order(:symbol) }
  scope :sethd, -> { where(sethd: true).order(:symbol) }
end

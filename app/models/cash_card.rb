# frozen_string_literal: true

class CashCard < ApplicationRecord
  has_paper_trail
  has_one_attached :receipt
end

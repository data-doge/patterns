# frozen_string_literal: true

# should be renamed to pool...
class Cart < ActiveRecord::Base
  belongs_to :user

  has_many :carts_people, dependent: :destroy
  has_many :carts_users, dependent: :destroy

  has_many :users, through: :carts_users, dependent: :destroy
  has_many :people, through: :carts_people, dependent: :destroy

  has_many :comments, as: :commentable, dependent: :destroy

  # example validation, the before_save obviates this.
  # validate :uniqueness_of_people_ids
  # before_save :dedupe_people_ids

  validates :name, uniqueness: true

  def owner
    user
  end

end

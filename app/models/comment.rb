# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text(65535)
#  user_id          :integer
#  commentable_type :string(255)
#  commentable_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  created_by       :integer
#

class Comment < ApplicationRecord
  has_paper_trail
  validates :content, presence: true
  belongs_to :commentable, polymorphic: true, touch: true
end

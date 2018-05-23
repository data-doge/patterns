

# frozen_string_literal: true

class ActiveRecord::Base

  def with_user(user)
    self.created_by = user.id if respond_to?(:created_by) && new_record?
    self.updated_by = user.id if respond_to?(:updated_by) && persisted?
    self
  end

  def creator
    if respond_to?(:created_by) && self.created_by.present?
      User.find self.created_by
    end
  end

  def last_updator
    if respond_to?(:updated_by) && self.updated_by.present?
      User.find self.updated_by
    end
  end
end

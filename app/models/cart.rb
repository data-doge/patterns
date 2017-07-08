# frozen_string_literal: true

class Cart < ActiveRecord::Base # should be renamed to pool...
  belongs_to :user
  # generally speaking, this is not the right way to do things
  # however, I *think* it makes sense in the context.
  # perhaps store is better than serialize, not sure.
  serialize :people_ids, JSON # it's a string, so 255 char max

  # example validation, the before_save obviates this.
  # validate :uniqueness_of_people_ids
  before_save :dedupe_people_ids

  validates :name, uniqueness: { scope: :user_id,
                                 message: 'Pools must have a unique name' }

  private

    def dedupe_people_ids
      people_ids.uniq!
    end

    def uniqueness_of_people_ids
      if people_ids.detect { |e| people_ids.rindex(e) != people_ids.index(e) }
        errors.add(:people_ids, 'duplicate person in pool')
      end
    end
end

# frozen_string_literal: true
# this was only used for migrating our tags from the old style
# to acts as taggable. see /lib/tasks/tag_migration.rake
# rubocop:disable Style/StructInheritance
class TagPersonJob < Struct.new(:id, :tags)

  def enqueue(job)
    Rails.logger.info '[TagPerson] job enqueued'
    job.save!
  end

  def perform
    person = Person.find(id)
    person.tag_list.add(tags)
    person.save
  end

  def max_attempts
    1
  end
end
# rubocop:enable Style/StructInheritance

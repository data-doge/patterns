# frozen_string_literal: true

class DashboardController < ApplicationController

  # New people that aren’t “verified”,
  # Total # of verified dig members
  # Recent participants
  # Recent sessions
  # Upcoming Sessions
  # Newest tags
  # Most popular tags with numbers
  # Recent activity stream-> sessions, people edits, pool edits

  def index
    @new_unverified_people = Person.not_verified.where('signup_at > :startdate', { startdate: 1.month.ago })
    @new_verified_people   = Person.verified.order('created_at DESC').where('signup_at > :startdate', { startdate: 1.month.ago })

    @verified_count = Person.verified.size
    @unverified_count = Person.not_verified.size
    @deactivated_count    = Person.unscoped.where(active: false).where('deactivated_at > ?', 1.month.ago).size
    @deactivated_people = Person.unscoped.where(active: false).order('deactivated_at DESC').limit(10)

    @last_logins = User.approved.all
    @one_month_gc = GiftCard.where('created_at > ?', 1.month.ago).sum(&:amount)
    @six_month_gc = GiftCard.where('created_at > ?', 6.months.ago).sum(&:amount)
    @twelve_month_gc = GiftCard.where('created_at > ?', 1.year.ago).sum(&:amount)

    @one_month_people = GiftCard.select('distinct person_id').where('created_at > ?', 1.month.ago).size
    @six_month_people = GiftCard.select('distinct person_id').where('created_at > ?', 6.months.ago).size
    @twelve_month_people = GiftCard.select('distinct person_id').where('created_at > ?', 1.year.ago).size

    @popular_tags   = ActsAsTaggableOn::Tag.most_used(10)
    @new_tags       = ActsAsTaggableOn::Tag.order('id desc').limit(10)

    @recent_participants   = ResearchSession.order('created_at DESC').limit(10).map(&:people).flatten.uniq
    @recent_sessions   = ResearchSession.order('created_at DESC').limit(10)

    @upcoming_participants = ResearchSession.where('start_datetime between NOW() and ?', 1.week.from_now).map(&:people).flatten.uniq
    @upcoming_sessions = ResearchSession.where('start_datetime between NOW() and ?', 1.week.from_now)
    @cart_people = CartsPerson.includes(:cart,:person).all.limit(20)
  end

end

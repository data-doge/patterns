# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_05_23_165026) do

  create_table "activation_calls", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "card_activation_id"
    t.string "sid"
    t.text "transcript"
    t.string "audio_url"
    t.string "call_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "call_status", default: "created"
    t.string "token"
    t.index ["token"], name: "index_activation_calls_on_token", unique: true
  end

  create_table "activities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "trackable_id"
    t.string "trackable_type"
    t.integer "owner_id"
    t.string "owner_type"
    t.string "key"
    t.text "parameters"
    t.integer "recipient_id"
    t.string "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
  end

  create_table "applications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url"
    t.string "source_url"
    t.string "creator_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "program_id"
    t.integer "created_by"
    t.integer "updated_by"
  end

  create_table "card_activations", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "full_card_number"
    t.string "expiration_date"
    t.string "sequence_number"
    t.string "secure_code"
    t.string "batch_id"
    t.string "status", default: "created"
    t.integer "user_id"
    t.integer "gift_card_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "created_by"
  end

  create_table "carts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", default: "default"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "people_count", default: 0
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "carts_people", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "person_id", null: false
    t.index ["cart_id", "person_id"], name: "index_carts_people_on_cart_id_and_person_id"
    t.index ["person_id", "cart_id"], name: "index_carts_people_on_person_id_and_cart_id"
  end

  create_table "carts_users", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "user_id", null: false
    t.boolean "current_cart", default: false
    t.index ["cart_id", "user_id"], name: "index_carts_users_on_cart_id_and_user_id"
    t.index ["user_id", "cart_id"], name: "index_carts_users_on_user_id_and_cart_id"
  end

  create_table "comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "content"
    t.integer "user_id"
    t.string "commentable_type"
    t.integer "commentable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "delayed_reference_id"
    t.string "delayed_reference_type"
    t.index ["delayed_reference_type"], name: "delayed_jobs_delayed_reference_type"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    t.index ["queue"], name: "delayed_jobs_queue"
  end

  create_table "events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.text "location"
    t.text "address"
    t.integer "capacity"
    t.integer "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by"
    t.integer "updated_by"
  end

  create_table "gift_cards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "gift_card_number"
    t.string "expiration_date"
    t.integer "person_id"
    t.string "notes"
    t.integer "created_by"
    t.integer "reason"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "giftable_id"
    t.string "giftable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "batch_id"
    t.integer "sequence_number"
    t.boolean "active", default: false
    t.string "secure_code"
    t.bigint "team_id"
    t.string "finance_code"
    t.index ["giftable_type", "giftable_id"], name: "index_gift_cards_on_giftable_type_and_giftable_id"
    t.index ["reason"], name: "gift_reason_index"
  end

  create_table "invitation_invitees_join_table", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "person_id"
    t.integer "event_invitation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invitations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "research_session_id"
    t.string "aasm_state"
    t.index ["person_id"], name: "index_invitations_on_person_id"
    t.index ["research_session_id"], name: "index_invitations_on_research_session_id"
  end

  create_table "mailchimp_exports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "body"
    t.integer "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailchimp_updates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "raw_content"
    t.string "email"
    t.string "update_type"
    t.string "reason"
    t.datetime "fired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "old_taggings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "taggable_type"
    t.integer "taggable_id"
    t.integer "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tag_id"
  end

  create_table "old_tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0, null: false
  end

  create_table "people", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email_address"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.integer "geography_id"
    t.integer "primary_device_id"
    t.string "primary_device_description"
    t.integer "secondary_device_id"
    t.string "secondary_device_description"
    t.integer "primary_connection_id"
    t.string "primary_connection_description"
    t.string "phone_number"
    t.string "participation_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "signup_ip"
    t.datetime "signup_at"
    t.string "voted"
    t.string "called_311"
    t.integer "secondary_connection_id"
    t.string "secondary_connection_description"
    t.string "verified"
    t.string "preferred_contact_method"
    t.string "token"
    t.boolean "active", default: true
    t.datetime "deactivated_at"
    t.string "deactivated_method"
    t.string "neighborhood"
    t.string "referred_by"
    t.boolean "low_income"
    t.string "rapidpro_uuid"
    t.string "landline"
  end

  create_table "programs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by"
    t.integer "updated_by"
  end

  create_table "research_sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "description"
    t.integer "buffer", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "title"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.string "sms_description"
    t.integer "session_type", default: 1
    t.string "location"
    t.integer "duration", default: 60
    t.index ["user_id"], name: "index_research_sessions_on_user_id"
  end

  create_table "reservations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "person_id"
    t.integer "event_id"
    t.datetime "confirmed_at"
    t.integer "created_by"
    t.datetime "attended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "updated_by"
  end

  create_table "submissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "raw_content"
    t.integer "person_id"
    t.string "ip_addr"
    t.string "entry_id"
    t.text "form_structure"
    t.text "field_structure"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "form_id"
    t.integer "form_type", default: 0
  end

  create_table "taggings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "teams", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "finance_code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "twilio_messages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "message_sid"
    t.datetime "date_created"
    t.datetime "date_updated"
    t.datetime "date_sent"
    t.string "account_sid"
    t.string "from"
    t.string "to"
    t.text "body"
    t.string "status"
    t.string "error_code"
    t.string "error_message"
    t.string "direction"
    t.string "from_city"
    t.string "from_state"
    t.string "from_zip"
    t.string "wufoo_formid"
    t.integer "conversation_count"
    t.string "signup_verify"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "twilio_wufoos", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "wufoo_formid"
    t.string "twilio_keyword"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "status", default: false, null: false
    t.string "end_message"
    t.string "form_type"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "password_salt"
    t.string "invitation_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "approved", default: false, null: false
    t.string "name"
    t.string "token"
    t.string "phone_number"
    t.boolean "new_person_notification", default: false
    t.bigint "team_id"
    t.index ["team_id"], name: "fk_rails_b2bbf87303"
  end

  create_table "versions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 4294967295
    t.datetime "created_at"
    t.text "object_changes", limit: 4294967295
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "users", "teams"
end

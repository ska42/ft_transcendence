# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_08_025211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "bans", force: :cascade do |t|
    t.string "login"
    t.string "reason"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_bans_on_user_id"
  end

  create_table "dm_messages", force: :cascade do |t|
    t.bigint "dm_id", null: false
    t.bigint "user_id", null: false
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dm_id"], name: "index_dm_messages_on_dm_id"
    t.index ["user_id"], name: "index_dm_messages_on_user_id"
  end

  create_table "dms", force: :cascade do |t|
    t.bigint "user1_id"
    t.bigint "user2_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user1_id"], name: "index_dms_on_user1_id"
    t.index ["user2_id"], name: "index_dms_on_user2_id"
  end

  create_table "friendships", id: false, force: :cascade do |t|
    t.bigint "friend_a_id"
    t.bigint "friend_b_id"
    t.index ["friend_a_id"], name: "index_friendships_on_friend_a_id"
    t.index ["friend_b_id"], name: "index_friendships_on_friend_b_id"
  end

  create_table "game_rules", force: :cascade do |t|
    t.integer "canvas_width", default: 600
    t.integer "canvas_height", default: 400
    t.integer "ball_radius", default: 10
    t.integer "ball_speed", default: 4
    t.integer "max_points", default: 5
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "games", force: :cascade do |t|
    t.bigint "player1_id"
    t.bigint "player2_id"
    t.string "status"
    t.integer "player1_pts", default: 0
    t.integer "player2_pts", default: 0
    t.bigint "winner_id"
    t.string "mode"
    t.bigint "tournament_id"
    t.datetime "start_time"
    t.bigint "game_rule_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "game_rules_id"
    t.index ["game_rule_id"], name: "index_games_on_game_rule_id"
    t.index ["game_rules_id"], name: "index_games_on_game_rules_id"
    t.index ["player1_id"], name: "index_games_on_player1_id"
    t.index ["player2_id"], name: "index_games_on_player2_id"
    t.index ["tournament_id"], name: "index_games_on_tournament_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "guild_invit_members", force: :cascade do |t|
    t.bigint "guild_id"
    t.bigint "by_id"
    t.bigint "user_id"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["by_id"], name: "index_guild_invit_members_on_by_id"
    t.index ["guild_id"], name: "index_guild_invit_members_on_guild_id"
    t.index ["user_id"], name: "index_guild_invit_members_on_user_id"
  end

  create_table "guild_link_officers", id: false, force: :cascade do |t|
    t.bigint "guild_id"
    t.bigint "user_id"
    t.index ["guild_id"], name: "index_guild_link_officers_on_guild_id"
    t.index ["user_id"], name: "index_guild_link_officers_on_user_id"
  end

  create_table "guilds", force: :cascade do |t|
    t.string "name"
    t.integer "points"
    t.string "anagram"
    t.bigint "owner_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["anagram"], name: "index_guilds_on_anagram", unique: true
    t.index ["name"], name: "index_guilds_on_name", unique: true
    t.index ["owner_id"], name: "index_guilds_on_owner_id"
  end

  create_table "muteships", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "muted_id"
    t.index ["muted_id"], name: "index_muteships_on_muted_id"
    t.index ["user_id"], name: "index_muteships_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "message"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
    t.boolean "readed"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "room_bans", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "by_id"
    t.bigint "room_id"
    t.datetime "end_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["by_id"], name: "index_room_bans_on_by_id"
    t.index ["room_id"], name: "index_room_bans_on_room_id"
    t.index ["user_id"], name: "index_room_bans_on_user_id"
  end

  create_table "room_link_admins", id: false, force: :cascade do |t|
    t.bigint "room_id"
    t.bigint "user_id"
    t.index ["room_id"], name: "index_room_link_admins_on_room_id"
    t.index ["user_id"], name: "index_room_link_admins_on_user_id"
  end

  create_table "room_link_members", id: false, force: :cascade do |t|
    t.bigint "room_id"
    t.bigint "user_id"
    t.index ["room_id"], name: "index_room_link_members_on_room_id"
    t.index ["user_id"], name: "index_room_link_members_on_user_id"
  end

  create_table "room_messages", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "user_id", null: false
    t.text "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["room_id"], name: "index_room_messages_on_room_id"
    t.index ["user_id"], name: "index_room_messages_on_user_id"
  end

  create_table "room_mutes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "room_id"
    t.bigint "by_id"
    t.datetime "end_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["by_id"], name: "index_room_mutes_on_by_id"
    t.index ["room_id"], name: "index_room_mutes_on_room_id"
    t.index ["user_id"], name: "index_room_mutes_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.string "privacy"
    t.string "password"
    t.bigint "owner_id"
    t.boolean "dm"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_rooms_on_name", unique: true
    t.index ["owner_id"], name: "index_rooms_on_owner_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "mode"
    t.integer "max_player"
    t.integer "points_award"
    t.datetime "start_time"
    t.bigint "winner_id"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["winner_id"], name: "index_tournaments_on_winner_id"
  end

  create_table "tournaments_users", id: false, force: :cascade do |t|
    t.bigint "tournament_id"
    t.bigint "user_id"
    t.index ["tournament_id"], name: "index_tournaments_users_on_tournament_id"
    t.index ["user_id"], name: "index_tournaments_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "guild_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "login"
    t.string "provider"
    t.string "uid"
    t.string "nickname"
    t.string "state", default: "offline"
    t.boolean "staff", default: false
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.boolean "otp_accepted"
    t.integer "rank", default: 5
    t.integer "mmr", default: 1000
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guild_id"], name: "index_users_on_guild_id"
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "war_link_games", force: :cascade do |t|
    t.bigint "war_id"
    t.bigint "game_id"
    t.index ["game_id"], name: "index_war_link_games_on_game_id"
    t.index ["war_id"], name: "index_war_link_games_on_war_id"
  end

  create_table "war_time_link_games", force: :cascade do |t|
    t.bigint "war_time_id"
    t.bigint "game_id"
    t.index ["game_id"], name: "index_war_time_link_games_on_game_id"
    t.index ["war_time_id"], name: "index_war_time_link_games_on_war_time_id"
  end

  create_table "war_times", force: :cascade do |t|
    t.bigint "war_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "unanswered"
    t.integer "max_unanswered"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["war_id"], name: "index_war_times_on_war_id"
  end

  create_table "wars", force: :cascade do |t|
    t.bigint "guild1_id"
    t.bigint "guild2_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "points_to_win"
    t.integer "points1"
    t.integer "points2"
    t.string "state"
    t.boolean "all_match"
    t.bigint "winner_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["guild1_id"], name: "index_wars_on_guild1_id"
    t.index ["guild2_id"], name: "index_wars_on_guild2_id"
    t.index ["winner_id"], name: "index_wars_on_winner_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "friendships", "users", column: "friend_a_id"
  add_foreign_key "friendships", "users", column: "friend_b_id"
  add_foreign_key "guild_invit_members", "users", column: "by_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "room_bans", "users", column: "by_id"
  add_foreign_key "room_messages", "rooms"
  add_foreign_key "room_messages", "users"
  add_foreign_key "room_mutes", "users", column: "by_id"
end

# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130214171318) do

  create_table "attendees", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "avatars", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blogs", :force => true do |t|
    t.string   "title",       :limit => 128, :null => false
    t.text     "description"
    t.integer  "user_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name",       :limit => 128,                :null => false
    t.string   "short",      :limit => 32,                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering",                  :default => 1, :null => false
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment",                        :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "events", :force => true do |t|
    t.string   "title",       :limit => 128,                :null => false
    t.text     "description"
    t.datetime "date_start",                                :null => false
    t.datetime "date_end"
    t.integer  "user_id",                                   :null => false
    t.integer  "location_id",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.integer  "popularity",                 :default => 0, :null => false
    t.string   "scrapingid"
  end

  create_table "locations", :force => true do |t|
    t.string   "name",        :limit => 128,                                 :null => false
    t.string   "street",      :limit => 128
    t.string   "zip",         :limit => 10
    t.string   "url"
    t.string   "email"
    t.text     "description"
    t.string   "phone",       :limit => 128
    t.integer  "metro_id",                                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "lat",                        :precision => 15, :scale => 10
    t.decimal  "lng",                        :precision => 15, :scale => 10
  end

  create_table "metros", :force => true do |t|
    t.string   "name",       :limit => 128, :null => false
    t.string   "state",      :limit => 128, :null => false
    t.string   "country",    :limit => 128, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope",          :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "slugs", ["name", "sluggable_type", "scope", "sequence"], :name => "index_slugs_on_name_and_sluggable_type_and_scope_and_sequence", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "users", :force => true do |t|
    t.string   "login",            :limit => 80,                     :null => false
    t.string   "password",         :limit => 40,                     :null => false
    t.string   "firstname",        :limit => 128
    t.string   "name",             :limit => 128
    t.string   "email",                                              :null => false
    t.string   "url"
    t.string   "avatar_url"
    t.datetime "last_login"
    t.integer  "number_of_logins", :limit => 11,                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",        :limit => 128, :default => "UTC", :null => false
    t.integer  "fb_user_id"
    t.string   "email_hash"
  end

end

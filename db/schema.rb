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

ActiveRecord::Schema.define(:version => 20090105154539) do

  create_table "attendees", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
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
    t.datetime "created_at",                 :null => false
    t.datetime "modified_at"
    t.integer  "user_id",                    :null => false
  end

  create_table "categories", :force => true do |t|
    t.string  "name",     :limit => 128, :null => false
    t.string  "short",    :limit => 32,  :null => false
    t.integer "ordering",                :null => false
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.string   "comment",                        :default => ""
    t.datetime "created_at",                                     :null => false
    t.integer  "commentable_id",                 :default => 0,  :null => false
    t.string   "commentable_type", :limit => 15, :default => "", :null => false
    t.integer  "user_id",                        :default => 0,  :null => false
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "events", :force => true do |t|
    t.string   "title",         :limit => 128,                :null => false
    t.text     "description"
    t.datetime "date_start",                                  :null => false
    t.datetime "date_end"
    t.datetime "date_created",                                :null => false
    t.datetime "date_modified"
    t.integer  "user_id",                                     :null => false
    t.integer  "location_id",                                 :null => false
    t.integer  "category_id"
    t.integer  "popularity",                   :default => 0, :null => false
  end

  create_table "globalize_countries", :force => true do |t|
    t.string "code",                   :limit => 2
    t.string "english_name"
    t.string "date_format"
    t.string "currency_format"
    t.string "currency_code",          :limit => 3
    t.string "thousands_sep",          :limit => 2
    t.string "decimal_sep",            :limit => 2
    t.string "currency_decimal_sep",   :limit => 2
    t.string "number_grouping_scheme"
  end

  add_index "globalize_countries", ["code"], :name => "index_globalize_countries_on_code"

  create_table "globalize_languages", :force => true do |t|
    t.string  "iso_639_1",             :limit => 2
    t.string  "iso_639_2",             :limit => 3
    t.string  "iso_639_3",             :limit => 3
    t.string  "rfc_3066"
    t.string  "english_name"
    t.string  "english_name_locale"
    t.string  "english_name_modifier"
    t.string  "native_name"
    t.string  "native_name_locale"
    t.string  "native_name_modifier"
    t.boolean "macro_language"
    t.string  "direction"
    t.string  "pluralization"
    t.string  "scope",                 :limit => 1
  end

  add_index "globalize_languages", ["iso_639_1"], :name => "index_globalize_languages_on_iso_639_1"
  add_index "globalize_languages", ["iso_639_2"], :name => "index_globalize_languages_on_iso_639_2"
  add_index "globalize_languages", ["iso_639_3"], :name => "index_globalize_languages_on_iso_639_3"
  add_index "globalize_languages", ["rfc_3066"], :name => "index_globalize_languages_on_rfc_3066"

  create_table "globalize_translations", :force => true do |t|
    t.string  "type"
    t.string  "tr_key"
    t.string  "table_name"
    t.integer "item_id"
    t.string  "facet"
    t.boolean "built_in",            :default => true
    t.integer "language_id"
    t.integer "pluralization_index"
    t.text    "text"
    t.string  "namespace"
  end

  add_index "globalize_translations", ["tr_key", "language_id"], :name => "index_globalize_translations_on_tr_key_and_language_id"
  add_index "globalize_translations", ["table_name", "item_id", "language_id"], :name => "globalize_translations_table_name_and_item_and_language"

  create_table "locations", :force => true do |t|
    t.string  "name",        :limit => 128,                                 :null => false
    t.string  "street",      :limit => 128
    t.string  "zip",         :limit => 10
    t.string  "url"
    t.string  "email"
    t.text    "description"
    t.string  "phone",       :limit => 128
    t.integer "metro_id",                                                   :null => false
    t.decimal "lat",                        :precision => 15, :scale => 10
    t.decimal "lng",                        :precision => 15, :scale => 10
  end

  create_table "metros", :force => true do |t|
    t.string "name",    :limit => 128, :null => false
    t.string "state",   :limit => 128, :null => false
    t.string "country", :limit => 128, :null => false
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope",          :limit => 40
    t.datetime "created_at"
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
    t.datetime "date_created",                                       :null => false
    t.datetime "last_login",                                         :null => false
    t.integer  "number_of_logins",                                   :null => false
    t.string   "time_zone",        :limit => 128, :default => "UTC", :null => false
  end

end

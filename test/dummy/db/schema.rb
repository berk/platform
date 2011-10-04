# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111004075531) do

  create_table "admins", :force => true do |t|
    t.integer  "user_id"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["user_id"], :name => "index_admins_on_user_id"

  create_table "platform_admins", :force => true do |t|
    t.integer  "user_id"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_admins", ["user_id"], :name => "index_platform_admins_on_user_id"

  create_table "platform_application_categories", :force => true do |t|
    t.integer  "category_id",    :null => false
    t.integer  "application_id", :null => false
    t.integer  "position"
    t.boolean  "featured"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_application_categories", ["category_id", "application_id"], :name => "pacca"
  add_index "platform_application_categories", ["category_id"], :name => "pacc"

  create_table "platform_application_developers", :force => true do |t|
    t.integer  "application_id"
    t.integer  "developer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_application_developers", ["application_id"], :name => "index_platform_application_developers_on_application_id"
  add_index "platform_application_developers", ["developer_id"], :name => "index_platform_application_developers_on_developer_id"

  create_table "platform_application_logs", :force => true do |t|
    t.integer  "application_id"
    t.integer  "user_id"
    t.string   "event"
    t.string   "controller"
    t.string   "action"
    t.string   "request_method"
    t.text     "data"
    t.string   "user_agent"
    t.integer  "duration"
    t.string   "host"
    t.string   "country"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_application_logs", ["application_id", "created_at"], :name => "index_platform_application_logs_on_application_id_and_created_at"

  create_table "platform_application_metrics", :force => true do |t|
    t.string   "type"
    t.datetime "interval"
    t.integer  "application_id"
    t.integer  "active_user_count"
    t.integer  "new_user_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_application_metrics", ["application_id", "interval"], :name => "pamai"

  create_table "platform_application_permissions", :force => true do |t|
    t.integer  "application_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_application_permissions", ["application_id"], :name => "index_platform_application_permissions_on_application_id"

  create_table "platform_application_usage_metrics", :force => true do |t|
    t.string   "type"
    t.datetime "interval"
    t.integer  "application_id"
    t.string   "event"
    t.integer  "count"
    t.integer  "avg_response_time"
    t.integer  "error_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_application_usage_metrics", ["application_id", "interval"], :name => "paumai"

  create_table "platform_application_users", :force => true do |t|
    t.integer  "application_id", :null => false
    t.integer  "user_id",        :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_application_users", ["application_id"], :name => "index_platform_application_users_on_application_id"
  add_index "platform_application_users", ["user_id"], :name => "index_platform_application_users_on_user_id"

  create_table "platform_applications", :force => true do |t|
    t.integer  "developer_id"
    t.string   "name"
    t.text     "description"
    t.string   "state",                    :default => "new"
    t.string   "locale"
    t.string   "url"
    t.string   "site_domain"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "contact_email"
    t.string   "privacy_policy_url"
    t.string   "terms_of_service_url"
    t.string   "permissions"
    t.string   "key"
    t.string   "secret"
    t.integer  "icon_id"
    t.integer  "logo_id"
    t.string   "canvas_name"
    t.string   "canvas_url"
    t.boolean  "auto_resize"
    t.boolean  "auto_login"
    t.string   "mobile_application_type"
    t.string   "ios_bundle_id"
    t.string   "itunes_app_store_id"
    t.string   "android_key_hash"
    t.integer  "rank"
    t.boolean  "auto_signin"
    t.string   "deauthorize_callback_url"
    t.string   "version"
    t.string   "api_version"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_applications", ["developer_id"], :name => "index_platform_applications_on_developer_id"
  add_index "platform_applications", ["key"], :name => "index_platform_applications_on_key", :unique => true
  add_index "platform_applications", ["parent_id"], :name => "index_platform_applications_on_parent_id"

  create_table "platform_categories", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "keyword"
    t.integer  "position"
    t.date     "enable_on"
    t.date     "disable_on"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_categories", ["parent_id"], :name => "index_platform_categories_on_parent_id"

  create_table "platform_developers", :force => true do |t|
    t.integer  "user_id",    :limit => 8, :null => false
    t.string   "name",                    :null => false
    t.text     "about"
    t.string   "url"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_developers", ["user_id"], :name => "index_platform_developers_on_user_id"

  create_table "platform_forum_messages", :force => true do |t|
    t.integer  "forum_topic_id", :null => false
    t.integer  "user_id",        :null => false
    t.text     "message",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_forum_messages", ["forum_topic_id"], :name => "index_platform_forum_messages_on_forum_topic_id"
  add_index "platform_forum_messages", ["user_id"], :name => "index_platform_forum_messages_on_user_id"

  create_table "platform_forum_topics", :force => true do |t|
    t.string   "subject_type"
    t.integer  "subject_id"
    t.integer  "user_id",      :null => false
    t.text     "topic",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_forum_topics", ["subject_type", "subject_id"], :name => "pftss"
  add_index "platform_forum_topics", ["user_id"], :name => "pftu"

  create_table "platform_logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "server"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.text     "session"
    t.binary   "cause"
    t.integer  "user_id"
    t.integer  "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "platform_media", :force => true do |t|
    t.string   "type"
    t.string   "file_location"
    t.string   "content_type"
    t.string   "file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "platform_oauth_tokens", :force => true do |t|
    t.string   "type",           :limit => 20
    t.integer  "user_id",        :limit => 8
    t.integer  "application_id"
    t.string   "token",          :limit => 50
    t.string   "secret",         :limit => 50
    t.string   "verifier",       :limit => 20
    t.string   "callback_url"
    t.string   "scope"
    t.datetime "valid_to"
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_oauth_tokens", ["token"], :name => "index_platform_oauth_tokens_on_token", :unique => true

  create_table "platform_permissions", :force => true do |t|
    t.string   "keyword",     :null => false
    t.text     "description", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_permissions", ["keyword"], :name => "index_platform_permissions_on_keyword"

  create_table "platform_ratings", :force => true do |t|
    t.integer  "user_id",     :limit => 8, :null => false
    t.string   "object_type"
    t.integer  "object_id"
    t.integer  "value"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_ratings", ["object_type", "object_id"], :name => "index_platform_ratings_on_object_type_and_object_id"
  add_index "platform_ratings", ["user_id"], :name => "index_platform_ratings_on_user_id"

  create_table "platform_rollup_logs", :force => true do |t|
    t.datetime "interval"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_rollup_logs", ["interval"], :name => "index_platform_rollup_logs_on_interval"

  create_table "platform_users", :force => true do |t|
    t.string   "name"
    t.string   "gender"
    t.string   "email"
    t.string   "password"
    t.string   "mugshot"
    t.string   "link"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_users", ["email", "password"], :name => "index_platform_users_on_email_and_password"
  add_index "platform_users", ["email"], :name => "index_platform_users_on_email"

  create_table "tr8n_glossary", :force => true do |t|
    t.string   "keyword"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_glossary", ["keyword"], :name => "index_tr8n_glossary_on_keyword"

  create_table "tr8n_ip_locations", :force => true do |t|
    t.integer  "low",        :limit => 8
    t.integer  "high",       :limit => 8
    t.string   "registry",   :limit => 20
    t.date     "assigned"
    t.string   "ctry",       :limit => 2
    t.string   "cntry",      :limit => 3
    t.string   "country",    :limit => 80
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_ip_locations", ["high"], :name => "index_tr8n_ip_locations_on_high"
  add_index "tr8n_ip_locations", ["low"], :name => "index_tr8n_ip_locations_on_low"

  create_table "tr8n_language_case_rules", :force => true do |t|
    t.integer  "language_case_id", :null => false
    t.integer  "language_id"
    t.integer  "translator_id"
    t.text     "definition",       :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_case_rules", ["language_case_id"], :name => "tr8n_lcr_case_id"
  add_index "tr8n_language_case_rules", ["language_id"], :name => "tr8n_lcr_lang_id"
  add_index "tr8n_language_case_rules", ["translator_id"], :name => "tr8n_lcr_translator_id"

  create_table "tr8n_language_case_value_maps", :force => true do |t|
    t.string   "keyword",       :null => false
    t.integer  "language_id",   :null => false
    t.integer  "translator_id"
    t.text     "map"
    t.boolean  "reported"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_case_value_maps", ["keyword", "language_id"], :name => "index_tr8n_language_case_value_maps_on_keyword_and_language_id"
  add_index "tr8n_language_case_value_maps", ["translator_id"], :name => "index_tr8n_language_case_value_maps_on_translator_id"

  create_table "tr8n_language_cases", :force => true do |t|
    t.integer  "language_id",   :null => false
    t.integer  "translator_id"
    t.string   "keyword"
    t.string   "latin_name"
    t.string   "native_name"
    t.text     "description"
    t.string   "application"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_cases", ["language_id", "keyword"], :name => "index_tr8n_language_cases_on_language_id_and_keyword"
  add_index "tr8n_language_cases", ["language_id", "translator_id"], :name => "index_tr8n_language_cases_on_language_id_and_translator_id"
  add_index "tr8n_language_cases", ["language_id"], :name => "index_tr8n_language_cases_on_language_id"

  create_table "tr8n_language_forum_abuse_reports", :force => true do |t|
    t.integer  "language_id",               :null => false
    t.integer  "translator_id",             :null => false
    t.integer  "language_forum_message_id", :null => false
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_forum_abuse_reports", ["language_forum_message_id"], :name => "tr8n_forum_reports_message_id"
  add_index "tr8n_language_forum_abuse_reports", ["language_id", "translator_id"], :name => "tr8n_forum_reports_lang_id_translator_id"
  add_index "tr8n_language_forum_abuse_reports", ["language_id"], :name => "tr8n_forum_reports_lang_id"

  create_table "tr8n_language_forum_messages", :force => true do |t|
    t.integer  "language_id",             :null => false
    t.integer  "language_forum_topic_id", :null => false
    t.integer  "translator_id",           :null => false
    t.text     "message",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_forum_messages", ["language_id", "language_forum_topic_id"], :name => "tr8n_forum_msgs_lang_id_topic_id"
  add_index "tr8n_language_forum_messages", ["language_id"], :name => "tr8n_forum_msgs_lang_id"
  add_index "tr8n_language_forum_messages", ["translator_id"], :name => "tr8n_forums_msgs_translator_id"

  create_table "tr8n_language_forum_topics", :force => true do |t|
    t.integer  "translator_id", :null => false
    t.integer  "language_id"
    t.text     "topic",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_forum_topics", ["language_id"], :name => "tr8n_forum_topics_lang_id"
  add_index "tr8n_language_forum_topics", ["translator_id"], :name => "tr8n_forum_topics_translator_id"

  create_table "tr8n_language_metrics", :force => true do |t|
    t.string   "type"
    t.integer  "language_id",                         :null => false
    t.date     "metric_date"
    t.integer  "user_count",           :default => 0
    t.integer  "translator_count",     :default => 0
    t.integer  "translation_count",    :default => 0
    t.integer  "key_count",            :default => 0
    t.integer  "locked_key_count",     :default => 0
    t.integer  "translated_key_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_metrics", ["created_at"], :name => "index_tr8n_language_metrics_on_created_at"
  add_index "tr8n_language_metrics", ["language_id"], :name => "index_tr8n_language_metrics_on_language_id"

  create_table "tr8n_language_rules", :force => true do |t|
    t.integer  "language_id",   :null => false
    t.integer  "translator_id"
    t.string   "type"
    t.text     "definition"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_rules", ["language_id", "translator_id"], :name => "index_tr8n_language_rules_on_language_id_and_translator_id"
  add_index "tr8n_language_rules", ["language_id"], :name => "index_tr8n_language_rules_on_language_id"

  create_table "tr8n_language_users", :force => true do |t|
    t.integer  "language_id",                      :null => false
    t.integer  "user_id",                          :null => false
    t.integer  "translator_id"
    t.boolean  "manager",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_users", ["created_at"], :name => "index_tr8n_language_users_on_created_at"
  add_index "tr8n_language_users", ["language_id", "translator_id"], :name => "index_tr8n_language_users_on_language_id_and_translator_id"
  add_index "tr8n_language_users", ["language_id", "user_id"], :name => "index_tr8n_language_users_on_language_id_and_user_id"
  add_index "tr8n_language_users", ["updated_at"], :name => "index_tr8n_language_users_on_updated_at"
  add_index "tr8n_language_users", ["user_id"], :name => "index_tr8n_language_users_on_user_id"

  create_table "tr8n_languages", :force => true do |t|
    t.string   "locale",                              :null => false
    t.string   "english_name",                        :null => false
    t.string   "native_name"
    t.boolean  "enabled"
    t.boolean  "right_to_left"
    t.integer  "completeness"
    t.integer  "fallback_language_id"
    t.text     "curse_words"
    t.integer  "featured_index",       :default => 0
    t.string   "google_key"
    t.string   "facebook_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_languages", ["locale"], :name => "index_tr8n_languages_on_locale"

  create_table "tr8n_translation_domains", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "source_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_domains", ["name"], :name => "index_tr8n_translation_domains_on_name", :unique => true

  create_table "tr8n_translation_key_comments", :force => true do |t|
    t.integer  "language_id",        :null => false
    t.integer  "translation_key_id", :null => false
    t.integer  "translator_id",      :null => false
    t.text     "message",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_key_comments", ["language_id", "translation_key_id"], :name => "tr8n_tkey_msgs_lang_id_tkey_id"
  add_index "tr8n_translation_key_comments", ["language_id"], :name => "tr8n_tkey_msgs_lang_id"
  add_index "tr8n_translation_key_comments", ["translator_id"], :name => "tr8n_tkey_msgs_translator_id"

  create_table "tr8n_translation_key_locks", :force => true do |t|
    t.integer  "translation_key_id",                    :null => false
    t.integer  "language_id",                           :null => false
    t.integer  "translator_id"
    t.boolean  "locked",             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_key_locks", ["translation_key_id", "language_id"], :name => "tr8n_locks_key_id_lang_id"

  create_table "tr8n_translation_key_sources", :force => true do |t|
    t.integer  "translation_key_id",    :null => false
    t.integer  "translation_source_id", :null => false
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_key_sources", ["translation_key_id"], :name => "tr8n_trans_keys_key_id"
  add_index "tr8n_translation_key_sources", ["translation_source_id"], :name => "tr8n_trans_keys_source_id"

  create_table "tr8n_translation_keys", :force => true do |t|
    t.string   "type"
    t.string   "key",                              :null => false
    t.text     "label",                            :null => false
    t.text     "description"
    t.datetime "verified_at"
    t.integer  "translation_count"
    t.boolean  "admin"
    t.string   "locale"
    t.integer  "level",             :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_keys", ["key"], :name => "index_tr8n_translation_keys_on_key", :unique => true

  create_table "tr8n_translation_sources", :force => true do |t|
    t.string   "source"
    t.integer  "translation_domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_sources", ["source"], :name => "tr8n_sources_source"

  create_table "tr8n_translation_votes", :force => true do |t|
    t.integer  "translation_id", :null => false
    t.integer  "translator_id",  :null => false
    t.integer  "vote",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_votes", ["translation_id", "translator_id"], :name => "tr8n_trans_votes_trans_id_translator_id"
  add_index "tr8n_translation_votes", ["translator_id"], :name => "tr8n_trans_votes_translator_id"

  create_table "tr8n_translations", :force => true do |t|
    t.integer  "translation_key_id",                             :null => false
    t.integer  "language_id",                                    :null => false
    t.integer  "translator_id",                                  :null => false
    t.text     "label",                                          :null => false
    t.integer  "rank",                            :default => 0
    t.integer  "approved_by_id",     :limit => 8
    t.text     "rules"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translations", ["created_at"], :name => "tr8n_trans_created_at"
  add_index "tr8n_translations", ["translation_key_id", "translator_id", "language_id"], :name => "tr8n_trans_key_id_translator_id_lang_id"
  add_index "tr8n_translations", ["translator_id"], :name => "r8n_trans_translator_id"

  create_table "tr8n_translator_following", :force => true do |t|
    t.integer  "translator_id"
    t.integer  "object_id"
    t.string   "object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translator_following", ["translator_id"], :name => "index_tr8n_translator_following_on_translator_id"

  create_table "tr8n_translator_logs", :force => true do |t|
    t.integer  "translator_id"
    t.integer  "user_id",       :limit => 8
    t.string   "action"
    t.integer  "action_level"
    t.string   "reason"
    t.string   "reference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translator_logs", ["created_at"], :name => "index_tr8n_translator_logs_on_created_at"
  add_index "tr8n_translator_logs", ["translator_id"], :name => "index_tr8n_translator_logs_on_translator_id"
  add_index "tr8n_translator_logs", ["user_id"], :name => "index_tr8n_translator_logs_on_user_id"

  create_table "tr8n_translator_metrics", :force => true do |t|
    t.integer  "translator_id",                        :null => false
    t.integer  "language_id"
    t.integer  "total_translations",    :default => 0
    t.integer  "total_votes",           :default => 0
    t.integer  "positive_votes",        :default => 0
    t.integer  "negative_votes",        :default => 0
    t.integer  "accepted_translations", :default => 0
    t.integer  "rejected_translations", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translator_metrics", ["created_at"], :name => "index_tr8n_translator_metrics_on_created_at"
  add_index "tr8n_translator_metrics", ["translator_id", "language_id"], :name => "index_tr8n_translator_metrics_on_translator_id_and_language_id"
  add_index "tr8n_translator_metrics", ["translator_id"], :name => "index_tr8n_translator_metrics_on_translator_id"

  create_table "tr8n_translator_reports", :force => true do |t|
    t.integer  "translator_id"
    t.string   "state"
    t.integer  "object_id"
    t.string   "object_type"
    t.string   "reason"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translator_reports", ["translator_id"], :name => "index_tr8n_translator_reports_on_translator_id"

  create_table "tr8n_translators", :force => true do |t|
    t.integer  "user_id",                                 :null => false
    t.boolean  "inline_mode",          :default => false
    t.boolean  "blocked",              :default => false
    t.boolean  "reported",             :default => false
    t.integer  "fallback_language_id"
    t.integer  "rank",                 :default => 0
    t.string   "name"
    t.string   "gender"
    t.string   "email"
    t.string   "password"
    t.string   "mugshot"
    t.string   "link"
    t.string   "locale"
    t.integer  "level",                :default => 0
    t.integer  "manager"
    t.string   "last_ip"
    t.string   "country_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translators", ["created_at"], :name => "index_tr8n_translators_on_created_at"
  add_index "tr8n_translators", ["email", "password"], :name => "index_tr8n_translators_on_email_and_password"
  add_index "tr8n_translators", ["email"], :name => "index_tr8n_translators_on_email"
  add_index "tr8n_translators", ["user_id"], :name => "index_tr8n_translators_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "mugshot"
    t.string   "locale"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email", "password"], :name => "index_users_on_email_and_password"
  add_index "users", ["email"], :name => "index_users_on_email"

  create_table "will_filter_filters", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "data"
    t.integer  "user_id"
    t.string   "model_class_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "will_filter_filters", ["user_id"], :name => "index_will_filter_filters_on_user_id"

end

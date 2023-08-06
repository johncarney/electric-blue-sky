# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_05_224847) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "matched_terms", force: :cascade do |t|
    t.bigint "text_id", null: false
    t.bigint "term_id", null: false
    t.string "matched_text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id"], name: "index_matched_terms_on_term_id"
    t.index ["text_id", "term_id", "matched_text"], name: "index_matched_terms_on_text_id_and_term_id_and_matched_text", unique: true
    t.index ["text_id"], name: "index_matched_terms_on_text_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "uri", null: false
    t.string "repo", null: false
    t.jsonb "record", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record"], name: "index_posts_on_record", opclass: :jsonb_path_ops, using: :gin
    t.index ["repo"], name: "index_posts_on_repo"
    t.index ["uri"], name: "index_posts_on_uri", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.citext "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "terms", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.string "pattern", null: false
    t.boolean "ambiguous", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pattern"], name: "index_terms_on_pattern", unique: true
    t.index ["topic_id"], name: "index_terms_on_topic_id"
  end

  create_table "texts", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.string "text_type", null: false
    t.citext "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_texts_on_post_id"
    t.index ["text"], name: "index_texts_on_text", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "topic_tags", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_topic_tags_on_tag_id"
    t.index ["topic_id", "tag_id"], name: "index_topic_tags_on_topic_id_and_tag_id", unique: true
    t.index ["topic_id"], name: "index_topic_tags_on_topic_id"
  end

  create_table "topics", force: :cascade do |t|
    t.citext "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_topics_on_name", unique: true
  end

  add_foreign_key "matched_terms", "terms"
  add_foreign_key "matched_terms", "texts"
  add_foreign_key "terms", "topics"
  add_foreign_key "texts", "posts"
  add_foreign_key "topic_tags", "tags"
  add_foreign_key "topic_tags", "topics"
end

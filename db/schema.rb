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

ActiveRecord::Schema[7.1].define(version: 2025_10_23_024755) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "endorsements", force: :cascade do |t|
    t.bigint "policy_id", null: false
    t.date "issue_date", null: false
    t.integer "endorsement_type", null: false
    t.decimal "new_sum_insured", precision: 15, scale: 2
    t.date "new_start_date"
    t.date "new_end_date"
    t.bigint "canceled_endorsement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canceled_endorsement_id"], name: "index_endorsements_on_canceled_endorsement_id"
    t.index ["policy_id"], name: "index_endorsements_on_policy_id"
  end

  create_table "policies", force: :cascade do |t|
    t.string "number", null: false
    t.date "issue_date", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.decimal "sum_insured", precision: 15, scale: 2, null: false
    t.decimal "lmg", precision: 15, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_policies_on_number", unique: true
  end

  add_foreign_key "endorsements", "endorsements", column: "canceled_endorsement_id"
  add_foreign_key "endorsements", "policies"
end

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

ActiveRecord::Schema[7.2].define(version: 2020_03_17_145540) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "atoms", force: :cascade do |t|
    t.string "stuff_w_props_type"
    t.integer "stuff_w_props_id"
    t.integer "satisfies_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "satisfies_type"
    t.index ["satisfies_id"], name: "index_atoms_on_satisfies_id"
    t.index ["satisfies_type", "satisfies_id"], name: "index_atoms_on_satisfies_type_and_satisfies_id"
    t.index ["stuff_w_props_type", "stuff_w_props_id"], name: "index_atoms_on_stuff_w_props_type_and_stuff_w_props_id"
  end

  create_table "axioms", force: :cascade do |t|
    t.integer "structure_id"
    t.integer "atom_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "value", default: true
    t.index ["atom_id"], name: "index_axioms_on_atom_id"
    t.index ["structure_id"], name: "index_axioms_on_structure_id"
  end

  create_table "building_block_realizations", force: :cascade do |t|
    t.integer "example_id"
    t.integer "building_block_id"
    t.integer "realization_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["building_block_id"], name: "index_building_block_realizations_on_building_block_id"
    t.index ["example_id"], name: "index_building_block_realizations_on_example_id"
    t.index ["realization_id"], name: "index_building_block_realizations_on_realization_id"
  end

  create_table "building_block_translations", force: :cascade do |t|
    t.integer "building_block_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.text "definition"
    t.index ["building_block_id"], name: "index_building_block_translations_on_building_block_id"
    t.index ["locale"], name: "index_building_block_translations_on_locale"
  end

  create_table "building_blocks", force: :cascade do |t|
    t.integer "explained_structure_id"
    t.integer "structure_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["explained_structure_id"], name: "index_building_blocks_on_explained_structure_id"
    t.index ["structure_id"], name: "index_building_blocks_on_structure_id"
  end

  create_table "example_facts", force: :cascade do |t|
    t.integer "example_id"
    t.integer "property_id"
    t.boolean "satisfied"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["example_id"], name: "index_example_facts_on_example_id"
    t.index ["property_id"], name: "index_example_facts_on_property_id"
  end

  create_table "example_translations", force: :cascade do |t|
    t.integer "example_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description"
    t.index ["example_id"], name: "index_example_translations_on_example_id"
    t.index ["locale"], name: "index_example_translations_on_locale"
  end

  create_table "examples", force: :cascade do |t|
    t.integer "structure_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["structure_id"], name: "index_examples_on_structure_id"
  end

  create_table "explanation_translations", force: :cascade do |t|
    t.integer "explanation_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "text"
    t.index ["explanation_id"], name: "index_explanation_translations_on_explanation_id"
    t.index ["locale"], name: "index_explanation_translations_on_locale"
  end

  create_table "explanations", force: :cascade do |t|
    t.string "explainable_type"
    t.integer "explainable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["explainable_type", "explainable_id"], name: "index_explanations_on_explainable_type_and_explainable_id"
  end

  create_table "implications", force: :cascade do |t|
    t.integer "implies_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "implies_value", default: true
    t.integer "parent_implication_id"
    t.integer "structure_id"
    t.index ["implies_id"], name: "index_implications_on_implies_id"
  end

  create_table "premises", force: :cascade do |t|
    t.integer "atom_id"
    t.integer "implication_id"
    t.boolean "value", default: true
    t.index ["atom_id"], name: "index_premises_on_atom_id"
    t.index ["implication_id"], name: "index_premises_on_implication_id"
  end

  create_table "properties", force: :cascade do |t|
    t.integer "structure_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "stackstag"
    t.index ["structure_id"], name: "index_properties_on_structure_id"
  end

  create_table "property_translations", force: :cascade do |t|
    t.integer "property_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.text "definition"
    t.index ["locale"], name: "index_property_translations_on_locale"
    t.index ["property_id"], name: "index_property_translations_on_property_id"
  end

  create_table "structure_translations", force: :cascade do |t|
    t.integer "structure_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.text "definition"
    t.index ["locale"], name: "index_structure_translations_on_locale"
    t.index ["structure_id"], name: "index_structure_translations_on_structure_id"
  end

  create_table "structures", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "derives_from_id"
    t.index ["derives_from_id"], name: "index_structures_on_derives_from_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "name"
    t.text "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end

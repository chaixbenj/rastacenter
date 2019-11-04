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

ActiveRecord::Schema.define(version: 20180516085150) do

  create_table "actions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 60, null: false
    t.text "description"
    t.string "parameters", limit: 1024
    t.text "code"
    t.integer "callable_in_proc", limit: 1, default: 1, null: false
    t.bigint "version_id"
    t.bigint "action_admin_id"
    t.integer "is_modifiable", limit: 1, default: 1, null: false
    t.integer "nb_used", limit: 2, default: 0, null: false
    t.bigint "current_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_admin_id"], name: "fk_rails_0cb5f8393e"
    t.index ["domaine_id", "version_id", "callable_in_proc"], name: "idx_actions_1"
    t.index ["domaine_id", "version_id", "is_modifiable", "callable_in_proc", "name"], name: "idx_actions_3"
    t.index ["domaine_id", "version_id", "name"], name: "idx_actions_2"
    t.index ["version_id"], name: "fk_rails_d560053c96"
  end

  create_table "appium_cap_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "init_value_id"
    t.bigint "appium_cap_id"
    t.string "name", limit: 50, null: false
    t.text "description"
    t.string "value"
    t.integer "is_numeric", limit: 1
    t.integer "is_boolean", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appium_cap_id"], name: "fk_rails_deb6cf5f6d"
    t.index ["domaine_id", "appium_cap_id", "init_value_id"], name: "idx_appium_cap_values_1"
    t.index ["init_value_id"], name: "fk_rails_20a1e603b3"
  end

  create_table "appium_caps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "version_id"
    t.string "name", limit: 60, null: false
    t.text "description"
    t.bigint "current_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "version_id", "name"], name: "idx_appium_caps_1"
    t.index ["version_id"], name: "fk_rails_39e8c0783e"
  end

  create_table "campain_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "campain_id", null: false
    t.bigint "variable_id", null: false
    t.string "variable_value", limit: 150, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campain_id"], name: "fk_rails_46fc1fcb0a"
    t.index ["domaine_id", "campain_id", "variable_id"], name: "idx_campain_configs_1"
    t.index ["variable_id"], name: "fk_rails_5472a3375b"
  end

  create_table "campain_test_suite_forced_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "campain_test_suite_id", null: false
    t.bigint "variable_id", null: false
    t.string "variable_value", limit: 150
    t.integer "updated", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campain_test_suite_id"], name: "fk_rails_4058045098"
    t.index ["domaine_id", "campain_test_suite_id", "variable_id"], name: "idx_campain_test_suites_forced_config_1", unique: true
    t.index ["variable_id"], name: "fk_rails_585c0b2aef"
  end

  create_table "campain_test_suites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "campain_id", null: false
    t.bigint "sheet_id", null: false
    t.integer "sequence", limit: 2, null: false
    t.integer "forced_config", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campain_id"], name: "fk_rails_1b8d972526"
    t.index ["domaine_id", "campain_id", "sequence"], name: "idx_campain_test_suites_1"
    t.index ["sheet_id"], name: "fk_rails_5d5ba955ed"
  end

  create_table "campains", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 250, null: false
    t.text "description"
    t.bigint "cycle_id", null: false
    t.integer "private", limit: 1, default: 0, null: false
    t.bigint "owner_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cycle_id"], name: "fk_rails_62158c76f5"
    t.index ["domaine_id", "cycle_id", "owner_user_id", "private"], name: "idx_campains_1"
  end

  create_table "computer_last_gets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "hostrequest", limit: 50, null: false
    t.string "object_type", limit: 50, null: false
    t.bigint "version_id"
    t.integer "get", limit: 1, default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "hostrequest", "object_type", "version_id"], name: "idx_computer_last_gets_1"
    t.index ["version_id"], name: "fk_rails_8f44172e26"
  end

  create_table "computers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "hostrequest", limit: 50, null: false
    t.string "guid", limit: 40, null: false
    t.datetime "last_connexion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "hostrequest", "guid"], name: "idx_computers_2"
    t.index ["domaine_id", "hostrequest"], name: "idx_computers_1", unique: true
    t.index ["guid"], name: "idx_computers_3", unique: true
  end

  create_table "configuration_variable_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "configuration_variable_id", null: false
    t.string "value", limit: 150, null: false
    t.integer "is_modifiable", limit: 1, default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["configuration_variable_id"], name: "fk_rails_8d32e82a7f"
    t.index ["domaine_id", "configuration_variable_id"], name: "idx_configuration_variable_values_1"
  end

  create_table "configuration_variables", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 50, null: false
    t.text "description"
    t.integer "is_deletable", limit: 1, default: 1, null: false
    t.integer "no_value", limit: 1, default: 0, null: false
    t.integer "is_numeric", limit: 1
    t.integer "is_boolean", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "name"], name: "idx_configuration_variables_1"
  end

  create_table "cycles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 250, null: false
    t.text "description"
    t.bigint "release_id", null: false
    t.string "string1", limit: 100
    t.string "string2", limit: 100
    t.string "string3", limit: 100
    t.string "string4", limit: 100
    t.string "string5", limit: 100
    t.string "string6", limit: 100
    t.string "string7", limit: 100
    t.string "string8", limit: 100
    t.string "string9", limit: 100
    t.string "string10", limit: 100
    t.string "value1", limit: 100
    t.string "value2", limit: 100
    t.string "value3", limit: 100
    t.string "value4", limit: 100
    t.string "value5", limit: 100
    t.string "value6", limit: 100
    t.string "value7", limit: 100
    t.string "value8", limit: 100
    t.string "value9", limit: 100
    t.string "value10", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "release_id"], name: "idx_cycles_1"
    t.index ["release_id"], name: "fk_rails_636fd72433"
  end

  create_table "data_set_variables", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "init_variable_id"
    t.bigint "project_id", null: false
    t.bigint "data_set_id"
    t.string "name", limit: 50, null: false
    t.text "description"
    t.string "value"
    t.integer "is_numeric", limit: 1
    t.integer "is_boolean", limit: 1
    t.integer "is_used", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_set_id"], name: "fk_rails_2d609247f0"
    t.index ["domaine_id", "data_set_id", "init_variable_id"], name: "idx_data_set_variables_1"
    t.index ["domaine_id", "project_id", "data_set_id"], name: "idx_data_set_variables_2"
    t.index ["init_variable_id"], name: "fk_rails_a2dee143b8"
    t.index ["project_id"], name: "fk_rails_e2390fb72d"
  end

  create_table "data_sets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "version_id"
    t.string "name", limit: 60, null: false
    t.text "description"
    t.bigint "current_id"
    t.integer "is_default", limit: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "version_id", "name"], name: "idx_data_sets_1"
    t.index ["version_id"], name: "fk_rails_e8afdcc593"
  end

  create_table "default_user_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "user_id", null: false
    t.bigint "variable_id", null: false
    t.string "variable_value", limit: 150, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "user_id", "variable_id"], name: "idx_default_user_configs_1"
    t.index ["user_id"], name: "fk_rails_63c4bff9b9"
    t.index ["variable_id"], name: "fk_rails_574ce9ae23"
  end

  create_table "domaines", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "guid", limit: 40, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "domelements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "funcandscreen_id", null: false
    t.bigint "version_id"
    t.string "name", limit: 50, null: false
    t.text "description"
    t.string "strategie", limit: 20, null: false
    t.string "path", limit: 500, null: false
    t.integer "is_used", limit: 2, default: 0, null: false
    t.bigint "current_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "funcandscreen_id", "version_id"], name: "idx_domelements_1"
    t.index ["funcandscreen_id"], name: "fk_rails_6f40ccddff"
    t.index ["version_id"], name: "fk_rails_1463ba777e"
  end

  create_table "environnement_variables", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "init_variable_id"
    t.bigint "project_id", null: false
    t.bigint "environnement_id"
    t.string "name", limit: 50, null: false
    t.text "description"
    t.string "value"
    t.integer "is_used", limit: 1, default: 0, null: false
    t.integer "is_numeric", limit: 1
    t.integer "is_boolean", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "environnement_id", "init_variable_id"], name: "idx_environnement_variables_1"
    t.index ["domaine_id", "project_id", "environnement_id"], name: "idx_environnement_variables_2"
    t.index ["environnement_id"], name: "fk_rails_c1c384e876"
    t.index ["init_variable_id"], name: "fk_rails_e6ff92580b"
    t.index ["project_id"], name: "fk_rails_7d15088b4c"
  end

  create_table "environnements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "version_id"
    t.string "name", limit: 60, null: false
    t.text "description"
    t.bigint "current_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "version_id", "name"], name: "idx_environnements_1"
    t.index ["version_id"], name: "fk_rails_7a6bc6ed11"
  end

  create_table "fiche_custo_fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "fiche_id", null: false
    t.string "ucf_id", limit: 5, null: false
    t.string "ucf_name", limit: 250, null: false
    t.bigint "field_id", null: false
    t.text "field_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "fiche_id", "ucf_id"], name: "idx_fiche_custo_fields_1"
    t.index ["fiche_id"], name: "fk_rails_cc72605ee9"
  end

  create_table "fiche_downloads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "fiche_id", null: false
    t.string "name", null: false
    t.string "guid", limit: 40, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "fiche_id", "name"], name: "idx_fiche_downloads_1"
    t.index ["fiche_id"], name: "fk_rails_45ffc96b9d"
  end

  create_table "fiche_histos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "fiche_id", null: false
    t.string "status", limit: 50, null: false
    t.text "comment"
    t.text "jsondesc"
    t.string "user_cre", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "fiche_id", "status"], name: "idx_fiche_histos_1"
    t.index ["fiche_id"], name: "fk_rails_9e2ec3bc11"
  end

  create_table "fiche_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "fiche_id", null: false
    t.bigint "fiche_linked_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "fiche_id"], name: "idx_fiche_links_1"
    t.index ["fiche_id"], name: "fk_rails_783eef3492"
  end

  create_table "fiches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "type_fiche_id", null: false
    t.string "name", limit: 250, null: false
    t.string "status", limit: 50, null: false
    t.text "description"
    t.string "user_cre", limit: 50, null: false
    t.string "user_maj", limit: 50
    t.string "lastresult", limit: 50
    t.bigint "status_id"
    t.bigint "user_assign_id"
    t.string "user_assign_name", limit: 50
    t.bigint "priority_id"
    t.string "priority_name", limit: 50
    t.bigint "cycle_id"
    t.bigint "project_id"
    t.bigint "test_id"
    t.bigint "proc_id"
    t.bigint "action_id"
    t.bigint "father_id"
    t.bigint "lignee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cycle_id"], name: "fk_rails_bff78f9d22"
    t.index ["domaine_id", "lignee_id"], name: "idx_fiches_4"
    t.index ["domaine_id", "project_id", "test_id", "proc_id", "action_id"], name: "idx_fiches_3"
    t.index ["domaine_id", "project_id", "type_fiche_id", "status_id"], name: "idx_fiches_2"
    t.index ["domaine_id", "type_fiche_id", "status"], name: "idx_fiches_1"
    t.index ["priority_id"], name: "fk_rails_0733f5c4e6"
    t.index ["project_id"], name: "fk_rails_952bfd5a04"
    t.index ["status_id"], name: "fk_rails_13a3e6c32c"
    t.index ["type_fiche_id"], name: "fk_rails_76afd1b9b8"
    t.index ["user_assign_id"], name: "fk_rails_62e95c4fbc"
  end

  create_table "findstrategies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id"], name: "idx_findstrategies_1"
  end

  create_table "funcandscreens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "project_id", null: false
    t.string "name", limit: 250
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "project_id"], name: "idx_funcandscreens_1"
    t.index ["project_id"], name: "fk_rails_abeb83fa41"
  end

  create_table "kanban_filters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "kanban_id", null: false
    t.string "field_name", limit: 250, null: false
    t.bigint "value_id", null: false
    t.string "value_name", limit: 50, null: false
    t.string "field_value", limit: 250
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "kanban_id"], name: "idx_kanban_filters_1"
    t.index ["kanban_id"], name: "fk_rails_2765e8431c"
  end

  create_table "kanban_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "kanban_id", null: false
    t.bigint "status_id", null: false
    t.string "status_name", limit: 50, null: false
    t.integer "status_order", limit: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "kanban_id", "status_order"], name: "idx_kanban_status_1"
    t.index ["kanban_id"], name: "fk_rails_1bed679d49"
  end

  create_table "kanban_type_fiches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "kanban_id", null: false
    t.bigint "type_fiche_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id"], name: "fk_rails_c32d03ca12"
    t.index ["kanban_id"], name: "fk_rails_4449545120"
    t.index ["type_fiche_id"], name: "fk_rails_03d41495b2"
  end

  create_table "kanbans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 250, null: false
    t.text "description"
    t.integer "is_active", limit: 1
    t.integer "private", limit: 1
    t.bigint "owner_user_id"
    t.bigint "father_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id"], name: "fk_rails_e3d8e4c0e9"
  end

  create_table "link_obj_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "obj_type", limit: 20, null: false
    t.bigint "obj_id", null: false
    t.bigint "obj_current_id", null: false
    t.bigint "version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "version_id", "obj_type", "obj_id"], name: "idx_link_obj_versions_1", unique: true
    t.index ["version_id"], name: "fk_rails_f98c59ed16"
  end

  create_table "links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "sheet_id", null: false
    t.string "id_externe", limit: 50, null: false
    t.bigint "node_father_id_fk", null: false
    t.bigint "node_son_id_fk", null: false
    t.integer "inflexion_x", limit: 2
    t.integer "inflexion_y", limit: 2
    t.integer "curved", limit: 1, default: 0, null: false
    t.integer "wait_link", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "sheet_id", "id_externe"], name: "idx_links_1"
    t.index ["domaine_id", "sheet_id", "node_father_id_fk"], name: "idx_links_2"
    t.index ["domaine_id", "sheet_id", "node_son_id_fk"], name: "idx_links_3"
    t.index ["sheet_id"], name: "fk_rails_41c5915ff4"
  end

  create_table "liste_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "liste_id", null: false
    t.string "value", limit: 100
    t.integer "is_modifiable", limit: 1, default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "liste_id"], name: "idx_liste_values_1"
    t.index ["liste_id"], name: "fk_rails_cc622e6bfc"
  end

  create_table "listes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "code", limit: 50
    t.string "name", limit: 250, null: false
    t.text "description"
    t.integer "is_deletable", limit: 1, default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "code"], name: "idx_listes_1"
  end

  create_table "lockobjects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "obj_type", limit: 30, null: false
    t.bigint "obj_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "obj_type", "obj_id"], name: "idx_lockobjects_2"
    t.index ["domaine_id", "user_id"], name: "idx_lockobjects_1"
    t.index ["user_id"], name: "fk_rails_dba0d6574e"
  end

  create_table "node_forced_computers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "node_id", null: false
    t.string "hostrequest", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "node_id"], name: "idx_node_forced_computers_1"
    t.index ["node_id"], name: "fk_rails_268da98afa"
  end

  create_table "node_forced_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "node_id", null: false
    t.bigint "variable_id", null: false
    t.string "variable_value", limit: 150
    t.integer "updated", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "node_id", "variable_id", "updated"], name: "idx_node_forced_configs_1"
    t.index ["node_id"], name: "fk_rails_2263d7208e"
    t.index ["variable_id"], name: "fk_rails_dbc469186a"
  end

  create_table "nodes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "sheet_id", null: false
    t.bigint "id_externe", null: false
    t.integer "x", limit: 2, null: false
    t.integer "y", limit: 2, null: false
    t.string "name", limit: 250, null: false
    t.string "type_node", limit: 20, null: false
    t.string "obj_type", limit: 20, null: false
    t.bigint "obj_id"
    t.integer "forced", limit: 1, default: 0, null: false
    t.string "force_type", limit: 20
    t.string "user_cre", limit: 50
    t.string "user_maj", limit: 50
    t.integer "new_thread", limit: 1
    t.integer "thread_number", limit: 1
    t.integer "hold", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "obj_id", "obj_type"], name: "idx_nodes_4"
    t.index ["domaine_id", "sheet_id", "obj_id"], name: "idx_nodes_2"
    t.index ["domaine_id", "sheet_id", "obj_type"], name: "idx_nodes_3"
    t.index ["domaine_id", "sheet_id"], name: "idx_nodes_1"
    t.index ["sheet_id"], name: "fk_rails_5b379f64b5"
  end

  create_table "procedure_actions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "procedure_id", null: false
    t.bigint "action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_id"], name: "fk_rails_c13b7663c3"
    t.index ["domaine_id", "action_id"], name: "idx_procedure_actions_1"
    t.index ["domaine_id", "procedure_id"], name: "idx_procedure_actions_2"
    t.index ["procedure_id"], name: "fk_rails_2d7881d8f8"
  end

  create_table "procedures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "funcandscreen_id", null: false
    t.string "name", limit: 250, null: false
    t.text "description"
    t.string "parameters", limit: 1024
    t.string "return_values", limit: 1024
    t.text "code"
    t.bigint "version_id"
    t.integer "is_used", limit: 2, default: 0, null: false
    t.bigint "current_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "version_id", "funcandscreen_id"], name: "idx_procedures_1"
    t.index ["funcandscreen_id"], name: "fk_rails_a57d83bf36"
    t.index ["version_id"], name: "fk_rails_0da3c6b1fd"
  end

  create_table "project_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "project_id", null: false
    t.bigint "version_id", null: false
    t.integer "locked", limit: 1, default: 1, null: false
    t.string "user_cre", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "project_id", "version_id"], name: "idx_project_versions_1"
    t.index ["project_id"], name: "fk_rails_eee5ff31fd"
    t.index ["version_id"], name: "fk_rails_0220f42d7c"
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 250, null: false
    t.text "description"
    t.string "user_cre", limit: 50, null: false
    t.string "user_maj", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "name"], name: "idx_projects_1"
  end

  create_table "ref_screenshots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 200, null: false
    t.string "location", limit: 200, null: false
    t.text "configstring"
    t.string "pngname", limit: 250
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "name", "location"], name: "idx_ref_screenshots_1"
  end

  create_table "releases", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 250, null: false
    t.text "description"
    t.bigint "project_id", null: false
    t.string "string1", limit: 100
    t.string "string2", limit: 100
    t.string "string3", limit: 100
    t.string "string4", limit: 100
    t.string "string5", limit: 100
    t.string "string6", limit: 100
    t.string "string7", limit: 100
    t.string "string8", limit: 100
    t.string "string9", limit: 100
    t.string "string10", limit: 100
    t.string "value1", limit: 100
    t.string "value2", limit: 100
    t.string "value3", limit: 100
    t.string "value4", limit: 100
    t.string "value5", limit: 100
    t.string "value6", limit: 100
    t.string "value7", limit: 100
    t.string "value8", limit: 100
    t.string "value9", limit: 100
    t.string "value10", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "project_id"], name: "idx_releases_1"
    t.index ["project_id"], name: "fk_rails_47fe2a0596"
  end

  create_table "required_gems", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "version_id"
    t.text "gems"
    t.bigint "current_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "version_id"], name: "idx_required_gems_1"
    t.index ["version_id"], name: "fk_rails_142cb61e68"
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id"
    t.string "name", limit: 50, null: false
    t.string "droits", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id"], name: "idx_roles_1"
  end

  create_table "run_authentications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "run_id", null: false
    t.bigint "user_id", null: false
    t.string "uuid", limit: 40
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id"], name: "fk_rails_2e870baee4"
    t.index ["run_id", "domaine_id"], name: "idx_run_athentications_1", unique: true
    t.index ["user_id"], name: "fk_rails_f1661a34e9"
  end

  create_table "run_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "run_id", null: false
    t.bigint "variable_id", null: false
    t.string "variable_value", limit: 150
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "run_id", "variable_id"], name: "idx_run_configs_1", unique: true
    t.index ["run_id"], name: "fk_rails_c2518a1ada"
    t.index ["variable_id"], name: "fk_rails_e5b98d055d"
  end

  create_table "run_ended_nodes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "run_id", null: false
    t.bigint "test_node_id_externe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "run_id", "test_node_id_externe"], name: "idx_run_ended_nodes_1"
    t.index ["run_id"], name: "fk_rails_77b34d8676"
  end

  create_table "run_screenshots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "guid", limit: 250, null: false
    t.bigint "domaine_id", null: false
    t.bigint "run_id", null: false
    t.string "name", limit: 200, null: false
    t.string "location"
    t.text "configstring"
    t.string "type_screenshot"
    t.string "pngname", limit: 250
    t.integer "prct_diff", limit: 2
    t.integer "has_diff", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "run_id", "guid", "has_diff"], name: "idx_run_screenshots_2"
    t.index ["domaine_id", "run_id", "guid", "type_screenshot"], name: "idx_run_screenshots_1", unique: true
    t.index ["run_id"], name: "fk_rails_28288951b4"
  end

  create_table "run_step_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "run_id", null: false
    t.bigint "suite_id"
    t.integer "suite_sequence", limit: 2
    t.bigint "test_id"
    t.bigint "test_node_id_externe"
    t.bigint "proc_id"
    t.integer "proc_sequence", limit: 2
    t.bigint "action_id"
    t.string "suite_name", limit: 250
    t.string "test_name", limit: 250
    t.string "proc_name", limit: 250
    t.string "action_name", limit: 60
    t.string "params", limit: 1024
    t.string "steplevel", limit: 20
    t.text "detail"
    t.text "expected"
    t.text "result_detail"
    t.string "result", limit: 50
    t.string "initial_result", limit: 50
    t.text "comment"
    t.text "histo"
    t.bigint "atdd_test_id"
    t.integer "atdd_sequence", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "run_id", "suite_id", "suite_sequence", "test_id", "test_node_id_externe", "proc_id", "proc_sequence", "steplevel", "result", "action_id"], name: "idx_run_step_results_1"
    t.index ["run_id"], name: "fk_rails_8d60f3e19d"
  end

  create_table "run_store_data", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "run_id", null: false
    t.string "key", limit: 120
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "run_id", "key"], name: "idx_run_store_data_1", unique: true
    t.index ["run_id"], name: "fk_rails_e1b1aa1cca"
  end

  create_table "run_suite_schemes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "run_id", null: false
    t.bigint "suite_id", null: false
    t.integer "sequence", limit: 2
    t.text "jsonnode"
    t.text "jsonlink"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "run_id", "suite_id", "sequence"], name: "idx_run_suite_schemes_1", unique: true
    t.index ["run_id"], name: "fk_rails_05cd42c657"
    t.index ["suite_id"], name: "fk_rails_76047f8dd9"
  end

  create_table "runs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "campain_id"
    t.bigint "user_id", null: false
    t.string "run_type", limit: 40, null: false
    t.bigint "test_id"
    t.bigint "suite_id"
    t.string "hostrequest", limit: 50, null: false
    t.string "status", limit: 15
    t.bigint "version_id"
    t.bigint "run_father_id"
    t.bigint "start_node_id"
    t.bigint "campain_test_suite_id"
    t.bigint "unlock_run_id"
    t.bigint "project_id"
    t.string "name", limit: 500
    t.integer "private", limit: 1
    t.integer "nbtest", default: 0, null: false
    t.integer "nbtestpass", default: 0, null: false
    t.integer "nbtestfail", default: 0, null: false
    t.integer "nbprocfail", default: 0, null: false
    t.text "conf_string"
    t.text "exec_code"
    t.integer "nb_screenshots_diffs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "hostrequest", "status", "campain_id"], name: "idx_runs_2"
    t.index ["domaine_id", "unlock_run_id"], name: "idx_runs_3"
    t.index ["domaine_id", "user_id"], name: "idx_runs_1"
    t.index ["run_father_id"], name: "fk_rails_067a333d44"
  end

  create_table "sheet_folders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "project_id"
    t.bigint "sheet_folder_father_id"
    t.string "name", limit: 250, null: false
    t.string "type_sheet", limit: 30
    t.integer "can_be_updated", limit: 1, default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "project_id", "sheet_folder_father_id"], name: "idx_sheet_folders_1"
    t.index ["domaine_id", "sheet_folder_father_id", "type_sheet"], name: "idx_sheet_folders_2"
    t.index ["project_id"], name: "fk_rails_12680ecec2"
    t.index ["sheet_folder_father_id"], name: "fk_rails_02f42403a6"
  end

  create_table "sheets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "sheet_folder_id", null: false
    t.string "name", limit: 250, null: false
    t.text "description"
    t.string "type_sheet", limit: 30
    t.integer "private", limit: 1, default: 1, null: false
    t.bigint "owner_user_id", null: false
    t.bigint "version_id"
    t.string "user_cre", limit: 50, null: false
    t.string "user_maj", limit: 50
    t.bigint "current_id"
    t.string "lastresult", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "sheet_folder_id", "version_id", "owner_user_id", "private"], name: "idx_sheets_2"
    t.index ["domaine_id", "type_sheet", "version_id", "owner_user_id", "private", "name"], name: "idx_sheets_1"
    t.index ["sheet_folder_id"], name: "fk_rails_94f27abd6c"
    t.index ["version_id"], name: "fk_rails_bbb2839171"
  end

  create_table "test_constantes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "project_id", null: false
    t.string "name", limit: 50, null: false
    t.string "description", limit: 250
    t.string "value", limit: 250
    t.integer "is_numeric", limit: 1
    t.integer "is_boolean", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "project_id", "name"], name: "idx_test_constantes_1"
    t.index ["project_id"], name: "fk_rails_54df1e487b"
  end

  create_table "test_folders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "project_id"
    t.bigint "test_folder_father_id"
    t.string "name", limit: 250, null: false
    t.integer "can_be_updated", limit: 1, default: 1, null: false
    t.integer "is_atdd", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "is_atdd"], name: "idx_test_folders_atdd"
    t.index ["domaine_id", "test_folder_father_id", "project_id"], name: "idx_test_folders_1"
    t.index ["project_id"], name: "fk_rails_70c338dce5"
    t.index ["test_folder_father_id"], name: "fk_rails_fad18306a6"
  end

  create_table "test_steps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "test_id", null: false
    t.integer "sequence", limit: 2, null: false
    t.bigint "sheet_id"
    t.bigint "funcandscreen_id"
    t.bigint "ext_node_id"
    t.bigint "procedure_id"
    t.text "parameters"
    t.string "user_maj", limit: 50
    t.bigint "atdd_test_id"
    t.text "code"
    t.string "type_code", limit: 10
    t.integer "temporary", limit: 1
    t.integer "hold", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["atdd_test_id"], name: "fk_rails_396150db4f"
    t.index ["domaine_id", "test_id", "sequence", "procedure_id"], name: "idx_test_steps_1"
    t.index ["funcandscreen_id"], name: "fk_rails_223fc9cfd8"
    t.index ["procedure_id"], name: "fk_rails_3bd7f0c7b0"
    t.index ["sheet_id"], name: "fk_rails_bb05e346b6"
    t.index ["test_id"], name: "fk_rails_ae95cbb0f9"
  end

  create_table "tests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "test_folder_id", null: false
    t.bigint "version_id"
    t.bigint "sheet_id"
    t.bigint "test_state_id"
    t.bigint "test_level_id"
    t.bigint "test_type_id"
    t.string "name", limit: 250, null: false
    t.text "description"
    t.integer "private", limit: 1, default: 1, null: false
    t.bigint "owner_user_id", null: false
    t.string "user_maj", limit: 50
    t.bigint "current_id"
    t.string "lastresult", limit: 50
    t.integer "has_real_step", limit: 1
    t.string "parameters"
    t.integer "is_atdd", limit: 1
    t.integer "is_valid", limit: 1
    t.bigint "fiche_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "is_atdd", "description"], name: "idx_tests_atdd_2", length: { description: 255 }
    t.index ["domaine_id", "is_atdd"], name: "idx_tests_atdd"
    t.index ["domaine_id", "test_folder_id", "version_id", "owner_user_id", "private", "test_type_id"], name: "idx_tests_2"
    t.index ["domaine_id", "version_id", "owner_user_id", "private", "name", "test_type_id", "test_state_id", "test_level_id"], name: "idx_tests_1"
    t.index ["fiche_id"], name: "fk_rails_a450d517d7"
    t.index ["sheet_id"], name: "fk_rails_880d2f164b"
    t.index ["test_folder_id"], name: "fk_rails_4883d02624"
    t.index ["test_level_id"], name: "fk_rails_1889391e8f"
    t.index ["test_state_id"], name: "fk_rails_37fa1b8022"
    t.index ["test_type_id"], name: "fk_rails_1a99ab3dcd"
    t.index ["version_id"], name: "fk_rails_2ffaba8731"
  end

  create_table "type_fiches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 250, null: false
    t.text "jsondesc"
    t.integer "is_system", limit: 1, default: 0, null: false
    t.bigint "sheet_id"
    t.string "color", limit: 7
    t.integer "is_gherkin", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "name"], name: "idx_type_fiches_1", unique: true
    t.index ["sheet_id"], name: "fk_rails_792af3f509"
  end

  create_table "user_notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "user_id", null: false
    t.string "sent_by", limit: 50
    t.text "message"
    t.integer "lu", limit: 1, default: 0, null: false
    t.bigint "sent_by_id"
    t.bigint "link_notif_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "user_id", "link_notif_id", "id", "lu"], name: "idx_user_notifications_2"
    t.index ["domaine_id", "user_id", "lu"], name: "idx_user_notifications_1"
    t.index ["user_id"], name: "fk_rails_cdbff2ee9e"
  end

  create_table "user_preferences", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "user_id", null: false
    t.text "jsonpref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "user_id"], name: "idx_user_preferences_1"
    t.index ["user_id"], name: "fk_rails_a69bfcfd81"
  end

  create_table "userprojects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "project_id", "user_id"], name: "idx_userprojects_2"
    t.index ["domaine_id", "user_id", "project_id"], name: "idx_userprojects_1"
    t.index ["project_id"], name: "fk_rails_4729443468"
    t.index ["role_id"], name: "fk_rails_aeb3c8a9a2"
    t.index ["user_id"], name: "fk_rails_c445826926"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id"
    t.string "login", limit: 50, null: false
    t.string "pwd", limit: 50, null: false
    t.string "username", limit: 50, null: false
    t.string "idnavigation", limit: 40
    t.bigint "project_id"
    t.integer "is_admin", limit: 1, default: 0, null: false
    t.datetime "dateidnavigation"
    t.string "preferences"
    t.string "email", limit: 254
    t.integer "locked", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "username", "login"], name: "idx_users_1"
    t.index ["login"], name: "idx_users_2", unique: true
    t.index ["project_id"], name: "fk_rails_fedc809cf8"
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "domaine_id", null: false
    t.string "name", limit: 250, null: false
    t.datetime "versioning_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domaine_id", "name"], name: "idx_versions_1"
  end

  add_foreign_key "actions", "domaines"
  add_foreign_key "actions", "users", column: "action_admin_id"
  add_foreign_key "actions", "versions"
  add_foreign_key "appium_cap_values", "appium_cap_values", column: "init_value_id"
  add_foreign_key "appium_cap_values", "appium_caps"
  add_foreign_key "appium_cap_values", "domaines"
  add_foreign_key "appium_caps", "domaines"
  add_foreign_key "appium_caps", "versions"
  add_foreign_key "campain_configs", "campains"
  add_foreign_key "campain_configs", "configuration_variables", column: "variable_id"
  add_foreign_key "campain_configs", "domaines"
  add_foreign_key "campain_test_suite_forced_configs", "campain_test_suites"
  add_foreign_key "campain_test_suite_forced_configs", "configuration_variables", column: "variable_id"
  add_foreign_key "campain_test_suite_forced_configs", "domaines"
  add_foreign_key "campain_test_suites", "campains"
  add_foreign_key "campain_test_suites", "domaines"
  add_foreign_key "campain_test_suites", "sheets"
  add_foreign_key "campains", "cycles"
  add_foreign_key "campains", "domaines"
  add_foreign_key "computer_last_gets", "domaines"
  add_foreign_key "computer_last_gets", "versions"
  add_foreign_key "computers", "domaines"
  add_foreign_key "configuration_variable_values", "configuration_variables"
  add_foreign_key "configuration_variable_values", "domaines"
  add_foreign_key "configuration_variables", "domaines"
  add_foreign_key "cycles", "domaines"
  add_foreign_key "cycles", "releases"
  add_foreign_key "data_set_variables", "data_set_variables", column: "init_variable_id"
  add_foreign_key "data_set_variables", "data_sets"
  add_foreign_key "data_set_variables", "domaines"
  add_foreign_key "data_set_variables", "projects"
  add_foreign_key "data_sets", "domaines"
  add_foreign_key "data_sets", "versions"
  add_foreign_key "default_user_configs", "configuration_variables", column: "variable_id"
  add_foreign_key "default_user_configs", "domaines"
  add_foreign_key "default_user_configs", "users"
  add_foreign_key "domelements", "domaines"
  add_foreign_key "domelements", "funcandscreens"
  add_foreign_key "domelements", "versions"
  add_foreign_key "environnement_variables", "domaines"
  add_foreign_key "environnement_variables", "environnement_variables", column: "init_variable_id"
  add_foreign_key "environnement_variables", "environnements"
  add_foreign_key "environnement_variables", "projects"
  add_foreign_key "environnements", "domaines"
  add_foreign_key "environnements", "versions"
  add_foreign_key "fiche_custo_fields", "domaines"
  add_foreign_key "fiche_custo_fields", "fiches", column: "fiche_id"
  add_foreign_key "fiche_downloads", "domaines"
  add_foreign_key "fiche_downloads", "fiches", column: "fiche_id"
  add_foreign_key "fiche_histos", "domaines"
  add_foreign_key "fiche_histos", "fiches", column: "fiche_id"
  add_foreign_key "fiche_links", "domaines"
  add_foreign_key "fiche_links", "fiches", column: "fiche_id"
  add_foreign_key "fiches", "cycles"
  add_foreign_key "fiches", "domaines"
  add_foreign_key "fiches", "liste_values", column: "priority_id"
  add_foreign_key "fiches", "liste_values", column: "status_id"
  add_foreign_key "fiches", "projects"
  add_foreign_key "fiches", "type_fiches", column: "type_fiche_id"
  add_foreign_key "fiches", "users", column: "user_assign_id"
  add_foreign_key "findstrategies", "domaines"
  add_foreign_key "funcandscreens", "domaines"
  add_foreign_key "funcandscreens", "projects"
  add_foreign_key "kanban_filters", "domaines"
  add_foreign_key "kanban_filters", "kanbans"
  add_foreign_key "kanban_statuses", "domaines"
  add_foreign_key "kanban_statuses", "kanbans"
  add_foreign_key "kanban_type_fiches", "domaines"
  add_foreign_key "kanban_type_fiches", "kanbans"
  add_foreign_key "kanban_type_fiches", "type_fiches", column: "type_fiche_id"
  add_foreign_key "kanbans", "domaines"
  add_foreign_key "link_obj_versions", "domaines"
  add_foreign_key "link_obj_versions", "versions"
  add_foreign_key "links", "domaines"
  add_foreign_key "links", "sheets"
  add_foreign_key "liste_values", "domaines"
  add_foreign_key "liste_values", "listes"
  add_foreign_key "listes", "domaines"
  add_foreign_key "lockobjects", "domaines"
  add_foreign_key "lockobjects", "users"
  add_foreign_key "node_forced_computers", "domaines"
  add_foreign_key "node_forced_computers", "nodes"
  add_foreign_key "node_forced_configs", "configuration_variables", column: "variable_id"
  add_foreign_key "node_forced_configs", "domaines"
  add_foreign_key "node_forced_configs", "nodes"
  add_foreign_key "nodes", "domaines"
  add_foreign_key "nodes", "sheets"
  add_foreign_key "procedure_actions", "actions"
  add_foreign_key "procedure_actions", "domaines"
  add_foreign_key "procedure_actions", "procedures"
  add_foreign_key "procedures", "domaines"
  add_foreign_key "procedures", "funcandscreens"
  add_foreign_key "procedures", "versions"
  add_foreign_key "project_versions", "domaines"
  add_foreign_key "project_versions", "projects"
  add_foreign_key "project_versions", "versions"
  add_foreign_key "projects", "domaines"
  add_foreign_key "ref_screenshots", "domaines"
  add_foreign_key "releases", "domaines"
  add_foreign_key "releases", "projects"
  add_foreign_key "required_gems", "domaines"
  add_foreign_key "required_gems", "versions"
  add_foreign_key "roles", "domaines"
  add_foreign_key "run_authentications", "domaines"
  add_foreign_key "run_authentications", "runs"
  add_foreign_key "run_authentications", "users"
  add_foreign_key "run_configs", "configuration_variables", column: "variable_id"
  add_foreign_key "run_configs", "domaines"
  add_foreign_key "run_configs", "runs"
  add_foreign_key "run_ended_nodes", "domaines"
  add_foreign_key "run_ended_nodes", "runs"
  add_foreign_key "run_screenshots", "domaines"
  add_foreign_key "run_screenshots", "runs"
  add_foreign_key "run_step_results", "domaines"
  add_foreign_key "run_step_results", "runs"
  add_foreign_key "run_store_data", "domaines"
  add_foreign_key "run_store_data", "runs"
  add_foreign_key "run_suite_schemes", "domaines"
  add_foreign_key "run_suite_schemes", "runs"
  add_foreign_key "run_suite_schemes", "sheets", column: "suite_id"
  add_foreign_key "runs", "domaines"
  add_foreign_key "runs", "runs", column: "run_father_id"
  add_foreign_key "sheet_folders", "domaines"
  add_foreign_key "sheet_folders", "projects"
  add_foreign_key "sheet_folders", "sheet_folders", column: "sheet_folder_father_id"
  add_foreign_key "sheets", "domaines"
  add_foreign_key "sheets", "sheet_folders"
  add_foreign_key "sheets", "versions"
  add_foreign_key "test_constantes", "domaines"
  add_foreign_key "test_constantes", "projects"
  add_foreign_key "test_folders", "domaines"
  add_foreign_key "test_folders", "projects"
  add_foreign_key "test_folders", "test_folders", column: "test_folder_father_id"
  add_foreign_key "test_steps", "domaines"
  add_foreign_key "test_steps", "funcandscreens"
  add_foreign_key "test_steps", "procedures"
  add_foreign_key "test_steps", "sheets"
  add_foreign_key "test_steps", "tests"
  add_foreign_key "test_steps", "tests", column: "atdd_test_id"
  add_foreign_key "tests", "domaines"
  add_foreign_key "tests", "fiches", column: "fiche_id"
  add_foreign_key "tests", "liste_values", column: "test_level_id"
  add_foreign_key "tests", "liste_values", column: "test_state_id"
  add_foreign_key "tests", "liste_values", column: "test_type_id"
  add_foreign_key "tests", "sheets"
  add_foreign_key "tests", "test_folders"
  add_foreign_key "tests", "versions"
  add_foreign_key "type_fiches", "domaines"
  add_foreign_key "type_fiches", "sheets"
  add_foreign_key "user_notifications", "domaines"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "user_preferences", "domaines"
  add_foreign_key "user_preferences", "users"
  add_foreign_key "userprojects", "domaines"
  add_foreign_key "userprojects", "projects"
  add_foreign_key "userprojects", "roles"
  add_foreign_key "userprojects", "users"
  add_foreign_key "users", "domaines"
  add_foreign_key "users", "projects"
  add_foreign_key "versions", "domaines"
end

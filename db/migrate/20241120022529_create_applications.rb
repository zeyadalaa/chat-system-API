class CreateApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :applications, id: :integer, charset: "utf8mb3", force: :cascade do |t|
      t.string :deviceName, null: false
      t.string :token, null: false
      t.string :password, null: false
      t.integer :chats_count, default: 0
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :applications, :token, unique: true, name: "index_applications_on_token"
  end
end

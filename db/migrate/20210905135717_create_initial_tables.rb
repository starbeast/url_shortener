class CreateInitialTables < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, limit: 512
      t.string :password_hash, null: false, limit: 60
      t.timestamps
    end

    add_index :users, :email, name: 'index_users_on_email', unique: true

    create_table :urls, id: false do |t|
      t.string :url, null: false
      t.string :shortened_url, null: false
      t.bigint :times_followed, default: 0
      t.references :user, foreign_key: true, index: true, null: true
      t.timestamps
    end

    add_index :urls, :shortened_url, name: 'index_urls_on_shortened_url', unique: true

    create_table :api_tokens do |t|
      t.references :user, foreign_key: true, index: true, null: false
      t.string :token, null: false, limit: 44
      t.string :alias, null: false
      t.datetime :expires_at, null: false
    end
  end
end

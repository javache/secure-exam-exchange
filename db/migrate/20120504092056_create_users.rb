class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :ugent_id
      t.string :gpg_public_key
      t.string :email
      t.string :name

      t.timestamps
    end
  end
end

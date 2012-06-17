class RemoveGpgAttribute < ActiveRecord::Migration
  def up
    remove_column :users, :gpg_public_key
  end

  def down
    add_column :users, :gpg_public_key
  end
end

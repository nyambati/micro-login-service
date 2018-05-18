class RenameMyTables < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :confirmation_token, :confirmation_token_digest
    rename_column :users, :access_token, :access_token_digest
  end
end

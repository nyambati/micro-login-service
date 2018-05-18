class AddForeignKeyToAssignments < ActiveRecord::Migration[5.2]
  def change
    remove_column :assignments, :user_id, :string
    add_column :assignments, :userid, :string
    add_foreign_key :assignments, :users, column: :userid, primary_key: :userid
    add_reference :assignments, :roles, foreign_key: true
  end
end

class RemoveRolesIdFromAssignments < ActiveRecord::Migration[5.2]
  def change
    remove_column :assignments, :roles_id, :integer
  end
end

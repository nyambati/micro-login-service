class RemoveIdColumnFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :id
  end
end

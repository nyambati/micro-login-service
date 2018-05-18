class AddPrimaryKeyToUsers < ActiveRecord::Migration[5.2]
  def up
    add_index :users, :userid
    execute 'ALTER TABLE users ADD PRIMARY KEY (userid);'
  end
  def down
    remove_index :users, :userid
    execute 'ALTER TABLE users DROP CONSTRAINT users_pkey;'
  end
end

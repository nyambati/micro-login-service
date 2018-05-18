class AddDomainToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :domain, :string
  end
end

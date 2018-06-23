class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :roles, :confirmed_at
end

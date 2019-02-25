class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :manager
end

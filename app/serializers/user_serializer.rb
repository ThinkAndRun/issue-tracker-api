class UserSerializer < ActiveModel::Serializer
  attributes :name, :email, :manager
end

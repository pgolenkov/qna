class LinkSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :gist?, :gist_raw, :created_at, :updated_at
end

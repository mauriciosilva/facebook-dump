class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uid, :type => String
  field :access_token, :type => String
end

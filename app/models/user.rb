class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :user_id,       :type => String
  field :oauth_token,   :type => String
  field :expires,       :type => String
  field :issues_at,     :type => String
  field :user
  field :registration
end

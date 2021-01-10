class User < ApplicationRecord
    validates :auth0_uid, presence: true
end

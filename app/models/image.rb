class Image < ApplicationRecord
    belongs_to :user

    validates :object_key, presence: true
    validates :filename, presence: true
    validates :filetype, presence: true
    validates :private, presence: true
end

class Ban < ApplicationRecord
	belongs_to :user, required: true

	validates :login, presence: true
end

class RoomMessage < ApplicationRecord
	belongs_to :user
	belongs_to :room, inverse_of: :room_messages

	validates	:message, presence: true

	validate	:check_rights

	def check_rights
		bans = self.user.receive_bans.where("room": self.room).where("end_at > ?", DateTime.now.utc)
		mutes = self.user.receive_mutes.where("room": self.room).where("end_at > ?", DateTime.now.utc)
		errors[:base] << "You are banned from this room until " if bans.exists?
		errors[:base] << "You are muted from this room until " if mutes.exists?
	end
end

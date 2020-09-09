class RoomBan < ApplicationRecord
	belongs_to	:user, inverse_of: :receive_bans
	belongs_to	:by, class_name: 'User', inverse_of: :send_bans
	belongs_to	:room

	validates	:end_at, presence: true

	validate	:not_in_past

	after_create	:notif_create

	def not_in_past
		errors.add(:nickname, "In the past") if self.end_at.past?
	end

	def notif_create
		room = Room.find(self.room.id)
		output = {"type": "update", "content": {"id": self.room.id}}
		RoomChannel.broadcast_to room, output
	end
end

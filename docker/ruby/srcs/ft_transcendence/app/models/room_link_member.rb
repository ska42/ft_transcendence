class RoomLinkMember < ApplicationRecord
	belongs_to :room
	belongs_to :user

	after_destroy	:notif_destroy

	def notif_destroy
		room = Room.find(self.room.id)
		output = {"type": "update", "content": {"id": self.room.id}}
		RoomChannel.broadcast_to room, output
	end
end

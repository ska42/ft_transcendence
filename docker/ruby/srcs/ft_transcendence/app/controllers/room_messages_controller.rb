class RoomMessagesController < ApplicationController
	before_action :load_entities

	def create
		@room_message = RoomMessage.create(user: current_user, room: @room, message: params.dig(:room_message, :message))
		unless @room_message.errors.any?
			@room_message = @room_message.as_json
			@room_message[:pic] = url_for(current_user.profile_pic)
			@room_message[:link_profile] = profile_path(current_user)
			@room_message[:name] = {'nick': current_user.nickname, 'display': ''}
			@room_message[:name][:display] += "#{current_user.guild.anagram} | " if current_user.guild
			@room_message[:name][:display] += @room_message[:name][:nick]
			datetime = @room_message['updated_at'].in_time_zone('Europe/Paris')
			@room_message[:date] = {'format': datetime.strftime("%F %T"), 'human': datetime.strftime("%H:%M:%S\n%d/%m/%Y")}
			output = {"type": "message", "content": @room_message}
			RoomChannel.broadcast_to @room, output
		else
			errors = @room_message.errors.full_messages
			@room_message = @room_message.as_json
			@room_message[:errors] = errors
		end
	end

	protected

	def load_entities
		@room = Room.find params.dig(:room_message, :room_id)
	end
end

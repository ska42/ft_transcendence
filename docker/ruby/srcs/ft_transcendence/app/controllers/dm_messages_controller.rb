class DmMessagesController < ApplicationController
	before_action :load_entities

	def create
		@dm_message = DmMessage.create(user: current_user, dm: @dm, message: params.dig(:dm_message, :message))
		unless @dm_message.errors.any?
			@dm_message = @dm_message.as_json
			@dm_message[:pic] = url_for(current_user.profile_pic)
			@dm_message[:link_profile] = profile_path(current_user)
			@dm_message[:name] = {'nick': current_user.nickname, 'display': ''}
			@dm_message[:name][:display] += "#{current_user.guild.anagram} | " if current_user.guild
			@dm_message[:name][:display] += @dm_message[:name][:nick]
			datetime = @dm_message['updated_at'].in_time_zone('Europe/Paris')
			@dm_message[:date] = {'format': datetime.strftime("%F %T"), 'human': datetime.strftime("%H:%M:%S\n%d/%m/%Y")}
			output = {"type": "message", "content": @dm_message}
			UserChannel.broadcast_to @dm.user1, output
			UserChannel.broadcast_to @dm.user2, output unless @dm.user1 == @dm.user2
		else
			errors = @dm_message.errors.full_messages
			@dm_message = @dm_message.as_json
			@dm_message[:errors] = errors
		end
	end

	protected
		def load_entities
			begin
				@dm = Dm.find(params.dig(:dm_message, :dm_id))
			rescue
				redirect_to dms_path, :alert => "Dm not found" and return
			end
		end
end

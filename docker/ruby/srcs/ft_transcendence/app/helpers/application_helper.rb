module ApplicationHelper
	def create_alert(message)
		raw("<div name='toast-alert' class='toast' role='alert' aria-live='assertive' aria-atomic='true' data-delay='10000'>
			<div class='toast-body'>
				" + message + "
			</div>
		</div>")
	end

	def room_rebalance_rights(room)
		room.admins << room.owner unless room.admins.include?(room.owner)
		room.admins.each do |user|
			room.members << user unless room.members.include?(user)
		end
	end

	def guild_rebalance_rights(guild)
		guild.officers << guild.owner unless guild.officers.include?(guild.owner)
		guild.officers.each do |user|
			guild.members << user unless guild.members.include?(user)
		end
	end

	def create_timeago(datetime)
		datetime = datetime.in_time_zone('Europe/Paris')
		encoded = datetime.strftime("%F %T")
		human = datetime.strftime("%H:%M:%S\n%d/%m/%Y")
		raw("<time class='timeago' datetime='#{encoded}'>#{human}</time>")
	end

	def is_winner_bold(data, player, winner)
		if player == winner
			raw("<b>#{data}</b>")
		else
			data
		end
	end

	def create_user_link(user, played=true)
		out = link_to user.nickname, profile_path(user)
		game = Game.where("status = ? AND (player1_id = ? OR player2_id = ?)", "running", user, user)
		if played and user.state == "online" and game.empty? == false
			out += " | "
			out += link_to 'Playing!', game_path(game.last)
		end
		out
	end
end

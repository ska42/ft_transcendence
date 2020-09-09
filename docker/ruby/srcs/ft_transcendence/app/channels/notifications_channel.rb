class NotificationsChannel < ApplicationCable::Channel
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def subscribed
		current_user.reload
		stream_for current_user
		# stream_from "notifications_channel"
	end

	def send_notif(data)
		valfrom_user = current_user
		if data["type"] == "play_casual"
			if GameLogic.check_rules(data)
				valto_user = User.find_by(nickname: data["to"])
				if valfrom_user != valto_user && valto_user
					valgame_rules = GameRule.create(canvas_width: data["canvas"]["width"].to_i, canvas_height: data["canvas"]["height"].to_i, ball_radius: data["ball"]["radius"].to_i, max_points: data["max_points"].to_i)
					valgame = Game.create(player1: valfrom_user, player2: valto_user, status: "waiting", mode: "casual", game_rules: valgame_rules)
					valmessage = valfrom_user.nickname + " invited you to play."
					NotificationsChannel.broadcast_to(valto_user, {
						type: "invitation",
						game:
						{
							id: valgame.id
						},
						message: valmessage
					})
#					Notification.create(user: valto_user, title: 'Invitation to play', message: "#{<%= link_to valfrom_user.nickname, profile_path(valfrom_user)} invited you to play a game!<br>Join #{link_to 'here', game_path(valgame)}")
					NotificationsChannel.broadcast_to(valfrom_user, {
						type: "redirect",
						game:
						{
							id: valgame.id
						}
					})
				end
			end
		end
		if data["type"] == "play_matchmaking"
			valmessage = "Waiting for matchmaking"
			NotificationsChannel.broadcast_to(valfrom_user, {
				type: "in_queue",
				message: valmessage
			});
		end
	end

	def unsubscribed
	# Any cleanup needed when channel is unsubscribed
	end

end

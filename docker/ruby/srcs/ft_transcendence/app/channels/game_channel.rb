class GameChannel < ApplicationCable::Channel

	@@subscribers = Hash.new

	def subscribed
		stream_from "game_#{params[:game]}"
		@gameLogic = GameLogic.create(params[:game])
		@game = @gameLogic.game
		@@subscribers[@game.id] ||= Array.new
		@@subscribers[@game.id].push(current_user.id)
		if @game.start_time && @game.start_time.future?
			return
		end
		if @game.player1 && @game.player2 && current_user != @game.player1 && current_user != @game.player2
			@gameLogic.addSpec
		end
		@gameLogic.send_config
	end

	def getCurrentPlayerNumber
        if current_user == @game.player1
			return 1
		elsif current_user == @game.player2
			return 2
		end
	end

	def input(data)
		if current_user == @game.player1 || current_user == @game.player2
			@gameLogic.addInput(data["type"], data["id"], getCurrentPlayerNumber)
		end
	end

	def space
		if @game.status == "waiting"
			if current_user == @game.player1 && !@gameLogic.player_ready[0]
				@gameLogic.player_ready[0] = true
			elsif current_user == @game.player2 && !@gameLogic.player_ready[1]
				@gameLogic.player_ready[1] = true
			end
            if @gameLogic.player_ready[0] && @gameLogic.player_ready[1]
                @game.status = "running"
                @game.save
            end
		elsif @game.status == "running" && @gameLogic.state == "pause"
			if current_user == @game.player1 && @gameLogic.last_loser == 1
				@gameLogic.start(1)
			elsif current_user == @game.player2 && @gameLogic.last_loser == 2
				@gameLogic.start(2)
			end
		end
	end

	def receive(data)

	end

	def unsubscribed
		if @game && @game.status != "finished" && (@game.player1 == current_user || @game.player2 == current_user) 
			if @game.status == "running"
				if @game.player1 == current_user
					@game.winner = @game.player2
				elsif @game.player2 == current_user
					@game.winner = @game.player1
				end
				@game.status = "finished"
			end
			if @game.mode != "tournament"
				@game.status = "finished"
				@game.player1_pts = @gameLogic.player_scores[0]
				@game.player2_pts = @gameLogic.player_scores[1]
			end
			@game.save	
			@gameLogic.attribute_points
		else
			@gameLogic.removeSpec
		end
		@@subscribers[@game.id].delete(current_user.id)
		if @@subscribers[@game.id].length == 0
			@@subscribers.delete(@game.id)
			GameLogic.delete(@game.id)
		end
	end

end

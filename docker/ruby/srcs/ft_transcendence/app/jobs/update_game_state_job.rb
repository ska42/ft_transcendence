class UpdateGameStateJob < ApplicationJob
	queue_as :default

 	def perform(id)
		@gameLogic = GameLogic.search(id)
		if @gameLogic
			@game = @gameLogic.game
		end
   		vali = 0
		while @gameLogic
			if vali >= 100
				Thread.new { @game.reload(lock: true) }
				vali = 0
			end
			if @game.status == "running"
				process_inputs(@gameLogic)
			  	if @gameLogic.state == "play"
					@gameLogic.updateBallPos
				end
			end
			send_game_state(@gameLogic, @game)
			if @game.status == "finished"
				GameLogic.delete(id)
				if (!@game.winner && ["tournament", "war"].exclude?(@game.mode))
					Game.delete(id)
				end
            end
		  	@gameLogic = GameLogic.search(id)
			vali += 10
			sleep(1.0/20.0)
		end
	end

	def process_inputs(gameLogic)
		input = gameLogic.getFrontInput
		while input
			if input[:type] == "paddle_up"
				gameLogic.paddle_up(input[:player])
			elsif input[:type] == "paddle_down"
				gameLogic.paddle_down(input[:player])
			end
			gameLogic.addProcessed(input[:player], input[:id])
			input = gameLogic.getFrontInput
		end	
	end

	def send_game_state(gameLogic, game)
		if (@gameLogic.player_nicknames[0] == nil && @game.player1)
			@gameLogic.player_nicknames[0] = @game.player1.nickname
		end
		if (@gameLogic.player_nicknames[1] == nil && @game.player2)
			@gameLogic.player_nicknames[1] = @game.player2.nickname
		end
		if (@game.status == "waiting")
			if (@game.player2 == nil)
				valstatus = "waiting for a player to join...<br>"
			else
				valstatus = "waiting for both players to be ready...<br>"
			end
			valstatus += "#{@gameLogic.player_nicknames[0]} joined<br>" if @gameLogic.player_join[0]
			valstatus += "#{@gameLogic.player_nicknames[1]} joined<br>" if @gameLogic.player_join[1]
			valstatus += "#{@gameLogic.player_nicknames[0]} is ready<br>" if @gameLogic.player_ready[0]
			valstatus += "#{@gameLogic.player_nicknames[1]} is ready<br>" if @gameLogic.player_ready[1]
			ActionCable.server.broadcast("game_#{@game.id}", {
				status: "waiting",
				msg_status: valstatus,
			});
		elsif (@game.status == "running")
			ActionCable.server.broadcast("game_#{@game.id}", {
				status: @game.status,
				msg_status: "running",
				players: {
					nicknames: [
						@gameLogic.player_nicknames[0],
						@gameLogic.player_nicknames[1]
					],
					scores: [
						@gameLogic.player_scores[0],
						@gameLogic.player_scores[1]
					]
				},
				paddles: [
				{
					posX: @gameLogic.paddles[0].posX,
					posY: @gameLogic.paddles[0].posY,
					width: @gameLogic.paddles[0].width,
					height: @gameLogic.paddles[0].height,
					velocity: @gameLogic.paddles[0].velocity
				},
				{
					posX: @gameLogic.paddles[1].posX,
					posY: @gameLogic.paddles[1].posY,
					width: @gameLogic.paddles[1].width,
					height: @gameLogic.paddles[1].height,
					velocity: @gameLogic.paddles[1].velocity
				}
				],
				ball: {
					posX: @gameLogic.ball.posX,
					posY: @gameLogic.ball.posY,
					radius: @gameLogic.ball.radius
				},
				inputs: [
					@gameLogic.processed_inputs[0],
					@gameLogic.processed_inputs[1]
				],
				spec_count: @gameLogic.spec_count
			});
			@gameLogic.clear_processed
		elsif (@game.status == "finished")
			valstatus = "finished";
			if @game.winner
				valstatus = "#{@game.winner.nickname} won !"
			else
				valstatus = "finished"
			end
			ActionCable.server.broadcast("game_#{@game.id}", {
				status: @game.status,
				msg_status: valstatus,
				players: {
					nicknames: [
						@gameLogic.player_nicknames[0],
						@gameLogic.player_nicknames[1]
					],
					scores: [
						@gameLogic.player_scores[0],
						@gameLogic.player_scores[1]
					]
				}
			});
		end
	end

end

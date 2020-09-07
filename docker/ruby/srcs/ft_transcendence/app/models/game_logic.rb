class GameLogic
	include ActiveModel::Model

	@@semaphore = Mutex.new
	@@games = Hash.new

	def self.create(id)
	@@semaphore.synchronize {
		if !@@games.has_key?(id)
			valgame = Game.find_by(id: id)
			if !valgame.game_rules
				valgame_rules = GameRule.create()
				valgame.game_rules = valgame_rules
				valgame.save
			end
			@@games[id] ||= GameLogic.new(id)
		end
	}
	@@games[id]
	end

	def self.delete(id)
	@@semaphore.synchronize {
		if @@games && @@games.has_key?(id)
			@@games.delete(id)
		end
	}
	end

	def self.search(id)
	@@semaphore.synchronize {
		valgame = nil
		if @@games && @@games.has_key?(id)
			valgame = @@games[id]
		end
		valgame
	}
	end

	def self.check_rules(rules)
	if rules["max_points"].to_i < 1 || rules["max_points"].to_i > 20
		return false
	end
	if rules["canvas"]["width"].to_i < 200 || rules["canvas"]["width"].to_i > 3000
		return false
	end
	if rules["canvas"]["height"].to_i < 200 || rules["canvas"]["height"].to_i > 3000
		return false
	end
	if rules["ball"]["radius"].to_i < 1 || (rules["ball"]["radius"].to_i * 2) > rules["canvas"]["height"].to_i || (rules["ball"]["radius"].to_i * 2) > rules["canvas"]["width"].to_i
		return false
	end
	return true
	end

	def initialize(id)
		@game = Game.find_by(id: id)
		@canvasWidth = @game.game_rules.canvas_width
		@canvasHeight = @game.game_rules.canvas_height
		@ballRadius = @game.game_rules.ball_radius
		@paddles = Array.new(2)
		valpaddle_height = 50.0
		@paddles[0] = Paddle.new(5, @canvasHeight / 2 - (valpaddle_height / 2), valpaddle_height)
		@paddles[1] = Paddle.new(@canvasWidth - 20, @canvasHeight / 2 - (valpaddle_height / 2), valpaddle_height)
		@last_loser = rand(1..2)
		@last_collision = if @last_loser == 1 then @paddles[0] else @paddles[1] end
		@ball = Ball.new(@last_loser, @paddles[@last_loser - 1], @ballRadius)
		@player_scores = Array.new(2, 0)
		@player_nicknames = Array.new(2)
		@player_ready = [false, false]
		@player_join = [false, false]
		@state = "pause"
		@max_points = @game.game_rules.max_points
		@inputs = Array.new()
		@processed_inputs = Array.new(2)
		@processed_inputs[0] = []
		@processed_inputs[1] = []
		@spec_count = 0
		UpdateGameStateJob.perform_later(id)
		CheckTournamentGameJob.set(wait_until: @game.start_time + 300).perform_later(id) if ["tournament", "war"].include?(@game.mode)
		if ["ranked", "tournament"].include?(@game.mode) and @game.player1.guild and @game.player2.guild
			guild1 = @game.player1.guild
			guild2 = @game.player2.guild
			@war = War.where("state = ? AND ((guild1_id = ? AND guild2_id = ?) OR (guild1_id = ? AND guild2_id = ?))", "active", guild1, guild2, guild2, guild1)
			@war.first.games << @game if @war.empty? == false and @war.first.all_match == true
		end
	end

	def send_config
	ActionCable.server.broadcast("game_#{@game.id}", {
		config:
		{
			canvas:
			{
				width: @canvasWidth,
				height: @canvasHeight
			},
			paddles: [
				{
					width: @paddles[0].width,
					height: @paddles[0].height,
					velocity: @paddles[0].velocity
				},
				{
					width: @paddles[1].width,
					height: @paddles[1].height,
					velocity: @paddles[1].velocity
				}
			],
			ball:
			{
				speed: @ball.startingSpeed,
				radius: @ball.radius
			},
			max_points: @max_points
		}
	})
	end

	def canvasWidth
	@canvasWidth
	end

	def canvasHeight
	@canvasHeight
	end

	def paddles
	@paddles
	end

	def ball
	@ball
	end

	def player_scores
	@player_scores
	end

	def player_nicknames
	@player_nicknames
	end

	def player_ready
	@player_ready
	end

	def player_join
	@player_join
	end

	def set_nicknames(player1, player2)
	@player_nicknames[0] = player1
	@player_nicknames[1] = player2
	end

	def last_loser
	@last_loser
	end

	def state
	@state
	end

	def max_points
	@max_points
	end

	def game
	@game
	end

	def spec_count
	@spec_count
	end

	def addInput(type, id, player)
	@inputs.unshift({ type: type, id: id, player: player })
	end

	def getFrontInput
	@inputs.pop
	end

	def addProcessed(player, id)
	@processed_inputs[player - 1].push(id)
	end

	def processed_inputs
	@processed_inputs
	end

	def clear_processed
	@processed_inputs[0].clear
	@processed_inputs[1].clear
	end

	def addSpec
	@spec_count += 1
	end

	def removeSpec
	@spec_count -= 1
	end

	def start(player)
	@state = "play"
	@ball.throw(player)
	end

	def reset_ball(player)
	@state = "pause"
	@ball = Ball.new(player, @paddles[player - 1], @ballRadius)
	end

	def reset_paddles
	valpaddle_height = @paddles[0].height
	@paddles[0] = Paddle.new(5, @canvasHeight / 2 - (valpaddle_height / 2), valpaddle_height)
	valpaddle_height = @paddles[1].height
	@paddles[1] = Paddle.new(@canvasWidth - 20, @canvasHeight / 2 - (valpaddle_height / 2), valpaddle_height)
	end

	def reset_all
	valloser = 0
	if @ball.posX < 0
		@player_scores[1] += 1
		valloser = 1
	elsif @ball.posX > @canvasWidth
		@player_scores[0] += 1
		valloser = 2
	end
	reset_paddles
	reset_ball(valloser)
	@last_loser = valloser
	if (gameEnd)
		designate_winner
		attribute_points
	end
	end

	def change_rank(player)
	if player.mmr <= 1000
		player.rank = 5
	elsif player.mmr > 1000 && player.mmr <= 1200
		player.rank = 4
	elsif player.mmr > 1200 && player.mmr <= 1400
		player.rank = 3
	elsif player.mmr > 1400 && player.mmr <= 1600
		player.rank = 2
	elsif player.mmr > 1600 && player.mmr <= 1800
		player.rank = 1
	end
	end

	def attribute_points
		if @game.mode == "ranked"
			valwinner = @game.winner
			if @game.winner == @game.player1
				valloser = @game.player2
			elsif @game.winner == @game.player2
				valloser = @game.player1
			end
			valconst = 40
			valfactor = 1.0 / (1.0 + 10.0 ** ((valwinner.mmr - valloser.mmr) / 400.0))
			valwinner.mmr += valconst * valfactor
			valloser.mmr -= valconst * valfactor
			change_rank(valwinner)
			change_rank(valloser)
			valwinner.save
			valloser.save
			if @game.winner.guild
				@game.winner.guild.points += 3
				@game.winner.guild.save
			end
			@war = WarLinkGame.find_by(game: @game)
			addpoints = @war.war if @war
		elsif @game.mode == "casual"
			if @game.winner.guild
				@game.winner.guild.points += 1
				@game.winner.guild.save
			end
		elsif @game.mode == "war"
			@war_time = WarTimeLinkGame.find_by(game: @game).war_time
			addpoints = @war_time.war
		elsif @game.mode == "tournament"
			@war = WarLinkGame.find_by(game: @game)
			addpoints = @war.war if @war
		end
		if addpoints
			if @game.winner == @game.player1
				addpoints.increment!(:points1, 1)
			elsif @game.winner == @game.player2
				addpoints.increment!(:points2, 1)
			end
		end
	end

	def paddle_up(nb)
	valpaddle = @paddles[nb - 1]
	if valpaddle.posY - valpaddle.velocity > 0
		valpaddle.up
	end
	if @state == "pause" && @last_loser == nb
		@ball.setPosY(valpaddle.getCenter)
	end
	end

	def paddle_down(nb)
	valpaddle = @paddles[nb - 1]
	if valpaddle.posY + valpaddle.height + valpaddle.velocity < @canvasHeight
		valpaddle.down
	end
	if @state == "pause" && @last_loser == nb
		@ball.setPosY(valpaddle.getCenter)
	end
	end

	def manage_collide
	valpaddle = nil
	if @ball.collidesLeft(@paddles[0].posX, @paddles[0].posY, @paddles[0].width, @paddles[0].height)
		valpaddle = @paddles[0]
		if @ball.posX - @ball.radius < @paddles[0].posX + @paddles[0].width
		@ball.setPosX(@paddles[0].posX + @paddles[0].width + @ball.radius)
		end
	end
	if @ball.collidesRight(@paddles[1].posX, @paddles[1].posY, @paddles[1].width, @paddles[1].height)
		valpaddle = @paddles[1]
		if @ball.posX + @ball.radius > @paddles[1].posX
		@ball.setPosX(@paddles[1].posX - @ball.radius)
		end
	end
	if valpaddle
		valoffset = (@ball.posY + @ball.radius * 2.0 - valpaddle.posY) / (valpaddle.height + @ball.radius * 2.0)
		valphi = 0.25 * Math::PI * (2.0 * valoffset - 1.0)
		@ball.setVelocityX(@ball.velocityX * -1.0)
		if @ball.velocityY != 0 || @ball.posY != valpaddle.getCenter
		@ball.setVelocityY(@ball.speed * Math.sin(valphi))
		end
		if valpaddle != @last_collision
		if @ball.speed < valpaddle.width
			@ball.increaseSpeed
		end
		@last_collision = valpaddle
		end
	end
	end

	def updateBallPos
	if @ball.posX < 0 || @ball.posX > @canvasWidth
		reset_all
	else
		manage_collide
	end
	if @ball.collidesSideArena(@canvasHeight)
		@ball.setVelocityY(@ball.velocityY * -1)
	end
	@ball.updatePos
	end

	def gameEnd
	(@player_scores[0] == @max_points || @player_scores[1] == @max_points)
	end

	def designate_winner
	if @game.status == "running"
		@game.status = "finished"
		if @player_scores[0] > @player_scores[1]
		@game.winner = @game.player1
		else
		@game.winner = @game.player2
		end
		@game.player1_pts = @player_scores[0]
		@game.player2_pts = @player_scores[1]
		@game.save
	end
	end
end

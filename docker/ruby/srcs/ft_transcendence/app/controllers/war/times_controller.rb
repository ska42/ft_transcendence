class War::TimesController < ApplicationController
	include ActionView::Helpers::UrlHelper
	before_action :set_war
	before_action :set_war_time, only: [:edit, :update, :creategame, :destroy]
	before_action :authored, only: [:new, :create, :edit, :update, :destroy]
	before_action :running, only: [:creategame]

	# GET /war/times
	# GET /war/times.json
	def index
		@war_times = @war.war_times
	end

	# GET /war/times/new
	def new
		@war_time = WarTime.new
	end

	# GET /war/times/1/edit
	def edit
	end

	# POST /war/times
	# POST /war/times.json
	def create
		@war_time = WarTime.new(war_time_params)
		@war_time.war = @war

		respond_to do |format|
			if @war_time.save
				back_page = war_times_path(@war)
				back_page = URI(request.referer).path if params[:back]
				format.html { redirect_to back_page, notice: 'Time was successfully created.' }
				format.json { render :show, status: :created, location: back_page }
			else
				format.html { broadcast_errors @war_time, (['start_at', 'end_at', 'max_unanswered']) }
				format.json { render json: @war_time.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /war/times/1
	# PATCH/PUT /war/times/1.json
	def update
		respond_to do |format|
			if @war_time.update(war_time_params)
				back_page = war_times_path(@war)
				back_page = URI(request.referer).path if params[:back]
				format.html { redirect_to back_page, notice: 'Time was successfully updated.' }
				format.json { render :show, status: :ok, location: back_page }
			else
				format.html { broadcast_errors @war_time, (['start_at', 'end_at', 'max_unanswered']) }
				format.json { render json: @war_time.errors, status: :unprocessable_entity }
			end
		end
	end

	def creategame
		game = Game.new
		if @war.guild1.members.include?(current_user)
			game.player1 = current_user
			game.player2 = @war.guild2.members.offset(rand(@war.guild2.members.count)).first
		else
			game.player2 = current_user
			game.player1 = @war.guild1.members.offset(rand(@war.guild1.members.count)).first
		end
		game.status = "waiting"
		game.mode = "war"
		game.start_time = Time.now
		game.save
		@war_time.games << game
		redirect_to game_path(game)
		message = "Game opposing #{game.player1.nickname} & #{game.player2.nickname} is ready<br>"
		if [game.player1, game.player2].include?(current_user)
			message += "You have 5 minutes to join "
		else
			message += "You can watch match "
		end
		message += "#{link_to 'here', game_path(game)}<br>#{link_to "War ##{@war.id}", war_path(@war)}<br>#{link_to "WarTime ##{@war_time.id}", war_times_path(@war)}"
		@war.guild1.members.each do |user|
			Notification.create(user: user, title: "New game in war time!", message: message)
		end
		@war.guild2.members.each do |user|
			Notification.create(user: user, title: "New game in war time!", message: message)
		end
	end

	# DELETE /war/times/1
	# DELETE /war/times/1.json
	def destroy
		@war_time.destroy
		respond_to do |format|
			format.html { redirect_to war_times_url, notice: 'Time was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_war
			begin
				@war = War.find(params[:war_id])
			rescue
				redirect_to wars_path, :alert => "War not found" and return
			end
		end
	
		# Use callbacks to share common setup or constraints between actions.
		def set_war_time
			begin
				@war_time = WarTime.find(params[:id])
			rescue
				redirect_to war_times_path, :alert => "WarTime not found" and return
			end
		end

		# Only allow a list of trusted parameters through.
		def war_time_params
			params.require(:war_time).permit(:start_at, :end_at, :max_unanswered)
		end

		def authored
			redirect_to war_times_path, :alert => "Missing permission" and return if @war.guild1.officers.exclude?(current_user)
			redirect_to war_times_path, :alert => "It's not the time to do that" and return unless @war.state == "waiting for war times"
		end

		def running
			redirect_to war_times_path(@war), :alert => "You're not in this war" and return if @war.guild1.members.exclude?(current_user) and @war.guild2.members.exclude?(current_user)
			redirect_to war_times_path(@war), :alert => "It's not the time to do that" and return if @war_time.start_at.future? or @war_time.end_at.past?
			redirect_to war_times_path(@war), :alert => "Another fight already launched" and return unless @war_time.games.where.not(status: "finished").empty?
			redirect_to war_times_path(@war), :alert => "Max of unanswered matchs is reached" and return if @war_time.unanswered > @war_time.max_unanswered
		end
end

class WarsController < ApplicationController
	before_action :in_guild, only: [:new, :create]
	before_action :set_war, only: [:show, :update, :destroy]
	before_action :not_empty, only: [:new, :create]
	before_action :authored, only: [:destroy]

	# GET /wars
	# GET /wars.json
	def index
		@wars = War.all.order("id DESC")
		@wars = @wars.where("guild1_id = ? OR guild2_id = ?", params[:guild_id], params[:guild_id]) if params[:guild_id]
	end

	# GET /wars/1
	# GET /wars/1.json
	def show
	end

	# GET /wars/new
	def new
		@war = War.new
	end

	# POST /wars
	# POST /wars.json
	def create
		@war = War.new(war_params)
		@war.guild1 = current_user.guild
		@war.points_to_win = 0 unless @war.points_to_win
		@war.points1 = 0 unless @war.points1
		@war.points2 = 0 unless @war.points2
		@war.state = "waiting for war times"

		respond_to do |format|
			if @war.save
				back_page = @war
				back_page = URI(request.referer).path if params[:back]
				format.html { redirect_to back_page, notice: 'War was successfully created.' }
				format.json { render :show, status: :created, location: back_page }
			else
				format.html { broadcast_errors @war, (['guild2_id', 'start_at', 'end_at', 'points_to_win', 'all_match']) }
				format.json { render json: @war.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /war/times/1
	# PATCH/PUT /war/times/1.json
	def update
		respond_to do |format|
			back_page = @war
			back_page = URI(request.referer).path if params[:back]
			error_msg = "Invalid state." unless params[:state] and ["aborted", "declared", "pending", "rejected"].include?(params[:state])
			if ["aborted", "declared"].include?(params[:state])
				error_msg = "War already locked" unless error_msg or @war.state == "waiting for war times"
				error_msg = "Missing permission" unless error_msg or @war.guild1.officers.include?(current_user)
				error_msg = "Other guild already on war" if error_msg == nil and params[:state] == "declared" and War.where("id != ? AND ((guild1_id = ? AND state IN (?)) OR (guild2_id = ? AND state IN (?)))", @war, @war.guild2, ["waiting for war times", "declared", "pending", "active"], @war.guild2, ["pending", "active"]).empty? == false
				error_msg = "Other guild doesn't have enough points (#{@war.guild2.points})" if error_msg == nil and @war.points_to_win <= @war.guild2.points and params[:state] == "declared"
			else
				error_msg = "War already locked" unless error_msg or @war.state == "declared"
				error_msg = "Missing permission" unless error_msg or @war.guild2.officers.include?(current_user)
			end
			if error_msg.nil?
				@war.update(state: params[:state])
				format.html { redirect_to back_page, notice: 'War was successfully updated.' }
				format.json { render :show, status: :updated, location: back_page }
			else
				format.html { redirect_to back_page, notice: error_msg }
				format.json { render status: :unprocessable_entity }
			end
		end
	end

	# DELETE /wars/1
	# DELETE /wars/1.json
	def destroy
		@war.destroy
		respond_to do |format|
			back_page = wars_path
			back_page = URI(request.referer).path if params[:back]
			format.html { redirect_to back_page, notice: 'War was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		def in_guild
			redirect_to wars_path, :alert => "You're not in a guild" and return unless current_user.guild
			redirect_to wars_path, :alert => "Go elsewhere" and return unless helpers.ready_for_war
		end

		# Use callbacks to share common setup or constraints between actions.
		def set_war
			begin
				@war = War.find(params[:id])
			rescue
				redirect_to wars_path, :alert => "War not found" and return
			end
		end

		# Only allow a list of trusted parameters through.
		def war_params
			params.require(:war).permit(:guild2_id, :start_at, :end_at, :points_to_win, :all_match)
		end

		def not_empty
			redirect_to wars_path, :alert => "No guild available" and return if (Guild.all.where.not(id: current_user.guild)).empty?
		end

		def authored
			redirect_to wars_path, :alert => "It's not the time to do that" and return unless @war.state == "waiting for war times"
		end
end

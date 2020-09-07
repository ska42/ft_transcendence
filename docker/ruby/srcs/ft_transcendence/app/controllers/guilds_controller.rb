class GuildsController < ApplicationController
	before_action :set_guild, only: [:show, :edit, :update, :destroy]
	before_action :is_mine, only: [:edit, :update, :destroy]
	before_action :no_guild, only: [:new, :create]

	# GET /guilds
	# GET /guilds.json
	def index
		@guilds = Guild.all.order("points DESC")
	end

	# GET /guilds/invitations
	# GET /guilds/invitations.json
	def invitations
		@invits = current_user.receive_invites.order("id DESC")
	end

	def invitationspost
		@invit = GuildInvitMember.find(params[:id])
		redirect_to invitations_guilds_path, :alert => "Shit, go elsewhere" and return if @invit.user != current_user or @invit.state != "waiting" or (params[:invitations] and params[:invitations][:state] == "accepted" and current_user.guild and current_user.guild.owner == current_user)

		respond_to do |format|
			if @invit.update(invit_params)
				current_user.guild.officers.delete(current_user) if current_user.guild && current_user.guild.officers.include?(current_user)
				current_user.update(guild: @invit.guild) if @invit.state == "accepted"
				format.html { redirect_to invitations_guilds_path, notice: 'Invitation was successfully updated.' }
				format.json { render :show, status: :ok, location: invitations_guilds_path }
			else
				format.html { render :invitations }
				format.json { render json: @invit.errors, status: :unprocessable_entity }
			end
		end
	end

	# GET /guilds/1
	# GET /guilds/1.json
	def show
	end

	# GET /guilds/new
	def new
		@guild = Guild.new
	end

	# GET /guilds/1/edit
	def edit
	end

	# POST /guilds
	# POST /guilds.json
	def create
		@guild = Guild.new(guild_params)
		@guild.points = 0
		@guild.owner = current_user

		respond_to do |format|
			if @guild.save
				format.html { redirect_to @guild, notice: 'Guild was successfully created.' }
				format.json { render :show, status: :created, location: @guild }
			else
				format.html { broadcast_errors @guild, guild_params }
				format.json { render json: @guild.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /guilds/1
	# PATCH/PUT /guilds/1.json
	def update
		respond_to do |format|
			if @guild.update(guild_params)
				format.html { redirect_to @guild, notice: 'Guild was successfully updated.' }
				format.json { render :show, status: :ok, location: @guild }
			else
				format.html { broadcast_errors @guild, guild_params }
				format.json { render json: @guild.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /guilds/1
	# DELETE /guilds/1.json
	def destroy
		@guild.destroy
		respond_to do |format|
			format.html { redirect_to guilds_url, notice: 'Guild was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_guild
			begin
				@guild = Guild.find(params[:id])
			rescue
				redirect_to guilds_path, :alert => "Guild not found" and return
			end
		end

		def is_mine
			redirect_to guild_path(@guild), :alert => "It's not yours" and return unless @guild.owner == current_user
		end

		def no_guild
			redirect_to guilds_path, :alert => "You're already enrolled" and return unless current_user.guild.nil?
		end

		# Only allow a list of trusted parameters through.
		def guild_params
			params.require(:guild).permit(:name, :anagram)
		end

		# Only allow a list of trusted parameters through.
		def invit_params
			params.require(:invitations).permit(:state)
		end
end

class Guild::InvitesController < ApplicationController
	before_action :set_guild
	before_action :is_admin
	before_action :not_empty, only: [:new, :create]

	# GET /guild/invites
	# GET /guild/invites.json
	def index
		@guild_invites = @guild.invites.order("id DESC")
	end

	# GET /guild/invites/new
	def new
		@guild_invite = GuildInvitMember.new
	end

	# POST /guild/invites
	# POST /guild/invites.json
	def create
		@guild_invite = GuildInvitMember.new(guild_invite_params)
		@guild_invite.guild = @guild
		@guild_invite.by = current_user
		@guild_invite.state = "waiting"

		respond_to do |format|
			if @guild_invite.save
				format.html { redirect_to guild_invites_url, notice: 'Invite was successfully created.' }
			else
				format.html { render :new }
				format.json { render json: @guild_invite.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /guild/invites/1
	# DELETE /guild/invites/1.json
	def destroy
		redirect_to guild_invites_url, :alert => "Already used" and return unless @guild.invites.find(params[:id]).state == "waiting"
		@guild.invites.destroy(params[:id])
		respond_to do |format|
			format.html { redirect_to guild_invites_url, notice: 'Invite was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		def set_guild
			begin
				@guild = Guild.find(params[:guild_id])
			rescue
				redirect_to guilds_path, :alert => "Guild not found" and return
			end
		end

		def is_admin
			redirect_to @guild, :alert => "Missing permission" and return unless @guild.officers.include?(current_user)
		end

		# Only allow a list of trusted parameters through.
		def guild_invite_params
			params.require(:guild_invite).permit(:user_id)
		end

		def not_empty
			redirect_to guild_invites_path, :alert => "No user to add" and return if (User.all - @guild.members - @guild.invites.where(state: "waiting").map(&:user)).empty?
		end
end

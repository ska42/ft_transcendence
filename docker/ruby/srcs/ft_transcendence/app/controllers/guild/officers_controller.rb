class Guild::OfficersController < ApplicationController
	before_action :set_guild
	before_action :is_mine, only: [:destroy]
	before_action :is_owner
	before_action :not_empty, only: [:new, :create]

	# GET /guild/officers
	# GET /guild/officers.json
	def index
		@guild_officers = @guild.officers.where.not(id: @guild.owner.id)
	end

	# GET /guild/officers/new
	def new
		@guild_officer = GuildLinkOfficer.new
	end

	# POST /guild/officers
	# POST /guild/officers.json
	def create
		@guild_officer = GuildLinkOfficer.new(guild_officer_params)
		@guild_officer.guild = @guild

		respond_to do |format|
			if @guild_officer.save
				back_page = guild_officers_url
				back_page = URI(request.referer).path if params[:back]
				format.html { redirect_to back_page, notice: 'Officer was successfully created.' }
			else
				format.html { render :new }
				format.json { render json: @guild_officer.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /guild/officers/1
	# DELETE /guild/officers/1.json
	def destroy
		@guild.officers.destroy(params[:id])
		respond_to do |format|
			back_page = guild_officers_url
			back_page = URI(request.referer).path if params[:back]
			format.html { redirect_to back_page, notice: 'Officer was successfully destroyed.' }
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

		def is_owner
			redirect_to @guild, :alert => "Missing permission" and return unless @guild.owner == current_user or current_user.staff or @bypass
		end

		def is_mine
			@bypass = (User.find(params[:id]) == current_user)
		end

		# Only allow a list of trusted parameters through.
		def guild_officer_params
			params.require(:guild_officer).permit(:user_id)
		end

		def not_empty
			redirect_to guild_officers_path, :alert => "No user to add" and return if (@guild.members - @guild.officers).empty?
		end
end

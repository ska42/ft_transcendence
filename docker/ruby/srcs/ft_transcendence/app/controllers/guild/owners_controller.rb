class Guild::OwnersController < ApplicationController
	before_action :set_guild
	before_action :is_owner
	before_action :not_empty
	before_action :set_user, only: [:create]

	# GET /guild/owners/new
	def new
	end

	# POST /guild/owners
	# POST /guild/owners.json
	def create
		respond_to do |format|
			if @guild.update(owner_id: @user.id)
				back_page = @guild
				back_page = URI(request.referer).path if params[:back]
				format.html { redirect_to back_page, notice: 'Owner was successfully updated.' }
				format.json { render :show, status: :created, location: back_page }
			else
				format.html { render :new }
				format.json { render status: :unprocessable_entity }
			end
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
			redirect_to @guild, :alert => "Missing permission" and return unless @guild.owner == current_user or current_user.staff
		end

		def not_empty
			@guild_officers = @guild.officers - [@guild.owner]
			redirect_to @guild, :alert => "No officer available" and return if @guild_officers.empty?
		end

		def set_user
			begin
				@user = @guild_officers.find(params[:owner_id]).first
			rescue
				redirect_to @guild, :alert => "User not found" and return
			end
		end
end

class Guild::MembersController < ApplicationController
	before_action :set_guild
	before_action :is_mine, only: [:destroy]
	before_action :is_admin

	# GET /guild/members
	# GET /guild/members.json
	def index
		@guild_members = @guild.members - @guild.officers
	end

	# DELETE /guild/members/1
	# DELETE /guild/members/1.json
	def destroy
		@guild.members.find(params[:id]).update(guild: nil)
		respond_to do |format|
			back_page = guild_members_path
			back_page = URI(request.referer).path if params[:back]
			format.html { redirect_to back_page, notice: 'Member was successfully destroyed.' }
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

		def is_mine
			@bypass = (User.find(params[:id]) == current_user)
		end

		def is_admin
			redirect_to @guild, :alert => "Missing permission" and return unless @guild.officers.include?(current_user) or current_user.staff or @bypass
		end

		# Only allow a list of trusted parameters through.
		def guild_member_params
			params.require(:guild_member).permit(:user_id)
		end
end


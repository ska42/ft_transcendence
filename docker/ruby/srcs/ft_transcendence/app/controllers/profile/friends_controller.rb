class Profile::FriendsController < ApplicationController
	before_action :set_profile
	before_action :is_mine
	before_action :not_empty, only: [:new, :create]

	# GET /profile/friends
	# GET /profile/friends.json
	def index
		@profile_friends = @profile.friends.order("state DESC, mmr DESC, nickname ASC")
	end

	# GET /profile/friends/new
	def new
		@profile_friend = Friendship.new
	end

	# POST /profile/friends
	# POST /profile/friends.json
	def create
		@profile_friend = Friendship.new(profile_friend_params)
		@profile_friend.friend_a = current_user

		respond_to do |format|
			if @profile_friend.save
				back_page = profile_friends_path
				back_page = URI(request.referer).path if params[:back]
				format.html { redirect_to back_page, notice: 'Friend was successfully created.' }
				format.json { render :show, status: :created, location: back_page }
			else
				format.html { broadcast_errors @profile_friend, profile_friend_params }
				format.json { render json: @profile_friend.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /profile/friends/1
	# DELETE /profile/friends/1.json
	def destroy
		@profile.friends.destroy(params[:id])
		respond_to do |format|
			back_page = profile_friends_path
			back_page = URI(request.referer).path if params[:back]
			format.html { redirect_to back_page, notice: 'Friend was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_profile
			redirect_to profile_friends_path(current_user) and return unless params[:profile_id]
			begin
				@profile = User.find(params[:profile_id])
			rescue
				redirect_to profiles_path, :alert => "User not found" and return
			end
		end

		def is_mine
			redirect_to profile_path(@profile), :alert => "It's not you :)" and return unless @profile == current_user
		end

		# Only allow a list of trusted parameters through.
		def profile_friend_params
			params.require(:friendship).permit(:friend_b_id)
		end

		def not_empty
			redirect_to profile_friends_path, :alert => "No user to add" and return if (User.all - @profile.friends).empty?
		end
end

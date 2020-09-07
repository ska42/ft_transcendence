class Room::MembersController < ApplicationController
	before_action :set_room
	before_action :is_member, only: [:destroy]
	before_action :is_mine, only: [:destroy]
	before_action :is_admin
	before_action :not_officers, only: [:destroy]
	before_action :not_empty, only: [:new, :create]

	# GET /room/members
	# GET /room/members.json
	def index
		@room_members = @room.members - @room.admins
	end

	# GET /room/members/new
	def new
		@room_member = RoomLinkMember.new
	end

	# POST /room/members
	# POST /room/members.json
	def create
		@room_member = RoomLinkMember.new(room_member_params)
		@room_member.room = @room

		respond_to do |format|
			if @room_member.save
				back_page = room_members_url
				back_page = URI(request.referer).path if params[:back]
				back_page = params[:room_member][:redirect] unless params[:room_member][:redirect].empty?
				format.html { redirect_to back_page, notice: 'Member was successfully created.' }
			else
				format.html { render :new }
				format.json { render json: @room_member.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /room/members/1
	# DELETE /room/members/1.json
	def destroy
		@room.members.destroy(params[:id])
		respond_to do |format|
			back_page = room_members_url
			back_page = URI(request.referer).path if params[:back]
			back_page = params[:redirect] if params[:redirect]
			format.html { redirect_to back_page, notice: 'Member was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		def set_room
			begin
				@room = Room.find(params[:room_id])
			rescue
				redirect_to rooms_path, :alert => "Room not found" and return
			end
		end

		def is_member
			begin
				@user = User.find(params[:id])
			rescue
				redirect_to room_members_path, :alert => "User not found" and return
			end
		end

		def is_mine
			@bypass = (@user == current_user)
		end

		def is_admin
			redirect_to @room, :alert => "Missing permission" and return unless @room.admins.include?(current_user) or current_user.staff or @bypass
		end

		# Only allow a list of trusted parameters through.
		def room_member_params
			params.require(:room_member).permit(:user_id)
		end

		def not_empty
			redirect_to room_members_path, :alert => "No user to add" and return if (User.all - @room.members).empty?
		end

		def not_officers
			redirect_to @room, :alert => "User is admin" and return if @room.admins.include?(@user)
		end
end

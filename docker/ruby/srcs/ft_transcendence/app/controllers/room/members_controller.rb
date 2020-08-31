class Room::MembersController < ApplicationController
	before_action :set_room
	before_action :is_admin

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
				back_page = params[:room_member][:redirect] if params[:room_member][:redirect]
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
			format.html { redirect_to back_page, notice: 'Member was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		def set_room
			@room = Room.find(params[:room_id])
		end

		def is_admin
			redirect_to @room, :alert => "Missing permission" and return unless @room.admins.include?(current_user) or current_user.staff
		end

		# Only allow a list of trusted parameters through.
		def room_member_params
			params.require(:room_member).permit(:user_id)
		end
end

class Room::AdminsController < ApplicationController
	before_action :set_room
	before_action :is_member, only: [:destroy]
	before_action :is_mine, only: [:destroy]
	before_action :is_owner
	before_action :not_owner, only: [:destroy]
	before_action :not_empty, only: [:new, :create]

	# GET /room/admins
	# GET /room/admins.json
	def index
		@room_admins = @room.admins.where.not(id: @room.owner.id)
	end

	# GET /room/admins/new
	def new
		@room_admin = RoomLinkAdmin.new
	end

	# POST /room/admins
	# POST /room/admins.json
	def create
		@room_admin = RoomLinkAdmin.new(room_admin_params)
		@room_admin.room = @room

		respond_to do |format|
			if @room_admin.save
				back_page = room_admins_url
				back_page = URI(request.referer).path if params[:back]
				format.html { redirect_to back_page, notice: 'Admin was successfully created.' }
			else
				format.html { render :new }
				format.json { render json: @room_admin.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /room/admins/1
	# DELETE /room/admins/1.json
	def destroy
		@room.admins.destroy(params[:id])
		respond_to do |format|
			back_page = room_admins_url
			back_page = URI(request.referer).path if params[:back]
			format.html { redirect_to back_page, notice: 'Admin was successfully destroyed.' }
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
				redirect_to rooms_path, :alert => "User not found" and return
			end
		end
	
		def is_mine
			@bypass = (@user == current_user)
		end

		def is_owner
			redirect_to @room, :alert => "Missing permission" and return unless @room.owner == current_user or current_user.staff or @bypass
		end

		# Only allow a list of trusted parameters through.
		def room_admin_params
			params.require(:room_admin).permit(:user_id)
		end

		def not_empty
			redirect_to room_admins_path, :alert => "No user to add" and return if (User.members - @room.admins).empty?
		end

		def not_owner
			redirect_to @room, :alert => "User is owner" and return if @room.owner == @user
		end

		def not_empty
			redirect_to room_admins_path, :alert => "No user to add" and return if (@room.members - @room.admins).empty?
		end
end

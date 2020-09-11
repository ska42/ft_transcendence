class Room::OwnersController < ApplicationController
	before_action :set_room
	before_action :is_owner
	before_action :not_empty
	before_action :set_user, only: [:create]

	# GET /room/owners/new
	def new
	end

	# POST /room/owners
	# POST /room/owners.json
	def create
		respond_to do |format|
			if @room.update(owner_id: @owner.id)
				back_page = @room
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
		def set_room
			begin
				@room = Room.find(params[:room_id])
			rescue
				redirect_to rooms_path, :alert => "Room not found" and return
			end
		end

		def is_owner
			redirect_to @room, :alert => "Missing permission" and return unless @room.owner == current_user or current_user.staff
		end

		def not_empty
			@room_admins = @room.admins.where.not(id: @room.owner.id)
			redirect_to @room, :alert => "No admin available" and return if @room_admins.empty?
		end

		def set_user
			begin
				@owner = @room_admins.find(params[:owner_id])
			rescue
				redirect_to @room, :alert => "User not found" and return
			end
		end
end

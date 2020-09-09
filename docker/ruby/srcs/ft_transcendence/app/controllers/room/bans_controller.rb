class Room::BansController < ApplicationController
	before_action :set_room
	before_action :is_admin
	before_action :set_room_ban, only: [:show, :edit, :update, :destroy]
	before_action :not_empty, only: [:new, :create]
	before_action :active, only: [:edit, :update, :destroy]

	# GET /room/bans
	# GET /room/bans.json
	def index
		@room_bans = RoomBan.all
	end

	# GET /room/bans/1
	# GET /room/bans/1.json
	def show
	end

	# GET /room/bans/new
	def new
		@room_ban = RoomBan.new
	end

	# GET /room/bans/1/edit
	def edit
	end

	# POST /room/bans
	# POST /room/bans.json
	def create
		@room_ban = RoomBan.new(room_ban_params)
		@room_ban.room = @room
		@room_ban.by = current_user

		respond_to do |format|
			if @room_ban.save
				format.html { redirect_to room_ban_path(@room, @room_ban), notice: 'Ban was successfully created.' }
				format.json { render :show, status: :created, location: room_ban_path(@room, @room_ban) }
			else
				format.html { broadcast_errors @room_ban, room_ban_params }
				format.json { render json: @room_ban.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /room/bans/1
	# PATCH/PUT /room/bans/1.json
	def update
		respond_to do |format|
			if @room_ban.update(room_ban_params)
				format.html { redirect_to room_ban_path(@room, @room_ban), notice: 'Ban was successfully updated.' }
				format.json { render :show, status: :ok, location: room_ban_path(@room, @room_ban) }
			else
				format.html { broadcast_errors @room_ban, room_ban_params }
				format.json { render json: @room_ban.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /room/bans/1
	# DELETE /room/bans/1.json
	def destroy
		@room_ban.destroy
		respond_to do |format|
			format.html { redirect_to room_bans_url, notice: 'Ban was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_room
			begin
				@room = Room.find(params[:room_id])
			rescue
				redirect_to rooms_path, :alert => "Room not found" and return
			end
		end

		def is_admin
				redirect_to @room, :alert => "Missing permission" and return unless @room.admins.include?(current_user)
		end

		# Use callbacks to share common setup or constraints between actions.
		def set_room_ban
			begin
				@room_ban = @room.bans.find(params[:id])
			rescue
				redirect_to room_bans_path, :alert => "Ban not found" and return
			end
		end

		# Only allow a list of trusted parameters through.
		def room_ban_params
			params.require(:room_ban).permit(:user_id, :by_id, :room_id, :end_at)
		end

		def not_empty
			redirect_to room_bans_path, :alert => "No user to add" and return if (@room.members - @room.admins).empty?
		end

		def active
			redirect_to room_bans_path, :alert => "Already ended" and return if @room_ban.end_at.past?
		end
end

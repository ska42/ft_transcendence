class RoomsController < ApplicationController
	before_action :authenticate_user!
	before_action :load_entities

	def index
	end

	def password
	end

	def passwordset
		session[:room_passwords][@room.id.to_s] = params[:password]
		redirect_to room_path(@room)
	end

	def show
		pass = BCrypt::Password.new(@room.password)
		redirect_to password_room_path(@room.id), :alert => "Protected by a password" and return if pass != "" and pass != session[:room_passwords][@room.id.to_s]
		bans = current_user.receive_bans.where("room": @room).where("end_at > ?", DateTime.now.utc)
		redirect_to rooms_path, :alert => "You are banned from this room until " + bans.order("end_at DESC").first.end_at.in_time_zone("Europe/Paris").strftime("%T %F") and return if bans.exists?
		unless @room.members.include?(current_user)
			redirect_to rooms_path, :alert => "You don't have permission to enter in this room" and return if @room.privacy == "private"
			@room.members << current_user
		end
		@room_message = RoomMessage.new room: @room
		@room_messages = @room.room_messages.includes(:user)
	end

	def new
		@room = Room.new
	end

	def join
		@rooms = Room.where(privacy: "public").where.not(id: current_user.rooms_member)
	end

	def create
		@room = Room.new permitted_parameters
		@room.owner = current_user

		if @room.save
			flash[:success] = "Room #{@room.name} was created successfully"
			redirect_to rooms_path
		else
			render :new
		end
	end

	def edit
	end

	def update
		if @room.update_attributes(permitted_parameters)
			flash[:success] = "Room #{@room.name} was updated successfully"
			redirect_to rooms_path
		else
			render :new
		end
	end

	protected

	def load_entities
		session[:room_passwords] = {} unless session[:room_passwords]
		@rooms = current_user.rooms_member
		@room = Room.find(params[:id]) if params[:id]
	end

	def permitted_parameters
		params.require(:room).permit(:name, :privacy, :password)
	end
end

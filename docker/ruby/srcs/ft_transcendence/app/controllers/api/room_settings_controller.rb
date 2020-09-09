class Api::RoomSettingsController < ApiController
	before_action :set_room_setting, only: [:show, :update, :destroy]

	# GET /room_settings/1
	# GET /room_settings/1.json
	def show
		if @room_setting.owner == current_user
			@room_setting = @room_setting.slice(:name, :privacy, :password)
			if (BCrypt::Password.new(@room_setting[:password]) == "")
				@room_setting[:password] = "checked"
			else
				@room_setting[:password] = ""
			end
			render json: @room_setting
		else
			render json: {"status": "error", "error": "403: Forbidden"}, status: :forbidden
		end
	end

	# PATCH/PUT /room_settings/1
	# PATCH/PUT /room_settings/1.json
	def update
		if @room_setting.owner == current_user
			if params[:room_setting][:password] == "none"
				params[:room_setting][:password] = ""
			elsif params[:room_setting][:password] == ""
				params[:room_setting][:password] = @room_setting.password
			end
			if @room_setting.update(room_setting_params)
				render json: @room_setting, status: :ok
			else
				render json: @room_setting.errors, status: :unprocessable_entity
			end
		else
			render json: {"status": "error", "error": "403: Forbidden"}, status: :forbidden
		end
	end

	# DELETE /room_users/1
	# DELETE /room_users/1.json
	def destroy
		if @room_setting.owner == current_user
			output = {"type": "delete", "content": @room_setting}
			@room_setting.destroy
			head :no_content
			RoomChannel.broadcast_to @room_setting, output
		else
			render json: {"status": "error", "error": "403: Forbidden"}, status: :forbidden
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_room_setting
			begin
				@room_setting = Room.find(params[:id])
			rescue
				redirect_to rooms_path, :alert => "Room not found" and return
			end
		end

		# Only allow a list of trusted parameters through.
		def room_setting_params
			params.require(:room_setting).permit(:name, :privacy, :password)
		end
end

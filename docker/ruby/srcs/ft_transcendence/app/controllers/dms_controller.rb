class DmsController < ApplicationController
	before_action :set_dm, only: [:show, :destroy]
	before_action :get_mutes, only: [:index, :show]

	# GET /dms
	# GET /dms.json
	def index
		@dms = Dm.where("user1_id = ? OR user2_id = ?", current_user, current_user)
	end

	# GET /dms/1
	# GET /dms/1.json
	def show
		redirect_to dms_path, :alert => "You have muted this user" and return if @mutes.include?(@dm.user1) or @mutes.include?(@dm.user2)
		@dm_messages = @dm.dm_messages.includes(:user)
		@dm_message = DmMessage.new(dm: @dm)
	end

	# GET /dms/new
	def new
		@dm = Dm.new
		@existing1 = Dm.where(user1: current_user).map(&:user2)
		@existing2 = Dm.where(user2: current_user).map(&:user1)
	end

	# POST /dms
	# POST /dms.json
	def create
		@dm = Dm.new(dm_params)
		@dm.user1 = current_user

		respond_to do |format|
			if @dm.save
				format.html { redirect_to @dm, notice: 'Dm was successfully created.' }
				format.json { render :show, status: :created, location: @dm }
			else
				format.html { broadcast_errors @dm, dm_params }
				format.json { render json: @dm.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /dms/1
	# DELETE /dms/1.json
	def destroy
		@dm.destroy
		respond_to do |format|
			format.html { redirect_to dms_url, notice: 'Dm was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_dm
			begin
				@dm = Dm.find(params[:id])
			rescue
				redirect_to dms_path, :alert => "Dm not found" and return
			end
		end

		def get_mutes
			@mutes = current_user.mutes
		end

		# Only allow a list of trusted parameters through.
		def dm_params
			params.require(:dm).permit(:user2_id)
		end
end

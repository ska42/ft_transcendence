class Admin::BansController < AdminController
	before_action :set_admin_ban, only: [:edit, :update, :destroy]

	# GET /admin/bans
	# GET /admin/bans.json
	def index
		@admin_bans = Ban.all
	end

	# GET /admin/bans/new
	def new
		@admin_ban = Ban.new
	end

	# GET /admin/bans/1/edit
	def edit
	end

	# POST /admin/bans
	# POST /admin/bans.json
	def create
		@admin_ban = Ban.new(admin_ban_params)
		@admin_ban.user = current_user

		respond_to do |format|
			if @admin_ban.save
				format.html { redirect_to admin_bans_path, notice: 'Ban was successfully created.' }
				format.json { render :show, status: :created, location: admin_bans_path }
			else
				format.html { broadcast_errors @admin_ban, admin_ban_params }
				format.json { render json: @admin_ban.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /admin/bans/1
	# PATCH/PUT /admin/bans/1.json
	def update
		respond_to do |format|
			if @admin_ban.update(admin_ban_params)
				format.html { redirect_to admin_bans_path, notice: 'Ban was successfully updated.' }
				format.json { render :show, status: :ok, location: admin_bans_path }
			else
				format.html { broadcast_errors @admin_ban, admin_ban_params }
				format.json { render json: @admin_ban.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /admin/bans/1
	# DELETE /admin/bans/1.json
	def destroy
		@admin_ban.destroy
		respond_to do |format|
			format.html { redirect_to admin_bans_url, notice: 'Ban was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_admin_ban
			begin
				@admin_ban = Ban.find(params[:id])
			rescue
				redirect_to admin_bans_path, :alert => "Ban not found" and return
			end
		end

		# Only allow a list of trusted parameters through.
		def admin_ban_params
			params.require(:ban).permit(:login, :reason)
		end
end

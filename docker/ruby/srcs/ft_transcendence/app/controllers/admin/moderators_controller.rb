class Admin::ModeratorsController < AdminController
	before_action :set_admin_moderators, only: [:index, :destroy]
	before_action :set_admin_not_moderators, only: [:new, :create]
	before_action :set_admin_moderator, only: [:create, :destroy]
	before_action :is_owner, only: [:destroy]
	before_action :not_empty, only: [:new, :create]

	# GET /admin/moderators
	# GET /admin/moderators.json
	def index
	end

	# GET /admin/moderators/new
	def new
	end

	# POST /admin/moderators
	# POST /admin/moderators.json
	def create
		respond_to do |format|
			if @admin_moderator.update(staff: true)
				format.html { redirect_to admin_moderators_path, notice: 'Moderator was successfully created.' }
			else
				format.html { render :new }
				format.json { render json: @admin_moderator.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /admin/moderators/1
	# DELETE /admin/moderators/1.json
	def destroy
		respond_to do |format|
			@admin_moderator.update(staff: false)
			format.html { redirect_to admin_moderators_url, notice: 'Moderator was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_admin_moderators
			@admin_moderators = User.where(staff: true).order("nickname ASC")
		end

		# Use callbacks to share common setup or constraints between actions.
		def set_admin_not_moderators
			@admin_moderators = User.where(staff: false).order("nickname ASC")
		end

		# Use callbacks to share common setup or constraints between actions.
		def set_admin_moderator
			begin
				@admin_moderator = @admin_moderators.find(params[:id])
			rescue
				redirect_to admin_moderators_path, :alert => "User not found" and return
			end
		end

		def is_owner
			redirect_to admin_moderators_path, :alert => "Unable to remove site owner" and return if @admin_moderator.login == "ybayart"
		end

		def not_empty
			redirect_to admin_moderators_path, :alert => "No user to add" and return if (@admin_moderators).empty?
		end
end

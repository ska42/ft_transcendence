class Admin::TournamentsController < AdminController
	before_action :set_tournament, only: [:show, :destroy, :register]

	# GET /tournaments
	# GET /tournaments.json
	def index
		@tournaments = Tournament.all
	end

	# GET /tournaments/1
	# GET /tournaments/1.json
	def show
	end

	# GET /tournaments/new
	def new
		@tournament = Tournament.new
	end

	# POST /tournaments
	# POST /tournaments.json
	def create
		@tournament = Tournament.new(tournament_params)
		@tournament.mode = "robin" unless @tournament.mode

		respond_to do |format|
			if @tournament.save
				back_page = admin_tournament_path(@tournament)
				back_page = URI(request.referer).path if params[:back]
				format.html { redirect_to back_page, notice: 'Tournament was successfully created.' }
				format.json { render :show, status: :created, location: back_page }
			else
				format.html { broadcast_errors @tournament, (["mode", "max_player", "start_time", "points_award"]) }
				format.json { render json: @tournament.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /tournaments/1
	# DELETE /tournaments/1.json
	def destroy
		@tournament.destroy
		respond_to do |format|
			back_page = admin_tournaments_path
			back_page = URI(request.referer).path if params[:back]
			format.html { redirect_to back_page, notice: 'Tournament was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	def register
		if @tournament.users.count + 1 <= @tournament.max_player
			current_user.tournaments.push(@tournament)
			current_user.save
			valnotice = 'Registered to tournament.'
		else
			valnotice = 'Tournament is full.'
		end
		respond_to do |format|
			format.html { redirect_to @tournament, notice: valnotice }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_tournament
			begin
				@tournament = Tournament.find(params[:id])
			rescue
				redirect_to tournaments_path, :alert => "Tournament not found" and return
			end
		end

		# Only allow a list of trusted parameters through.
		def tournament_params
			params.require(:tournament).permit(:mode, :max_player, :start_time, :points_award)
		end
end

class ProfilesController < ApplicationController
	before_action :set_profile, only: [:show, :edit, :update]
	before_action :is_mine, only: [:edit, :update]
	before_action :need_otp, only: [:otp, :otppost]

	def index
		@profiles = User.all.order("state DESC, mmr DESC, nickname ASC")
	end

	def otp
		@profile = current_user
	end

	def otppost
		if current_user.current_otp == params[:otp_code]
			current_user.update(otp_accepted: true)
			redirect_to root_path, :notice => "OTP Code accepted"
		else
			redirect_to otp_profiles_path, :alert => "Invalid OPT Code"
		end
	end

	def show
		@matchs_history = Game.where(player1: @profile).or(Game.where(player2: @profile)).order("updated_at DESC")
	end

	def edit
		unless @profile.otp_required_for_login == true
			unless @profile.nickname.blank?
				@profile.otp_secret = User.generate_otp_secret
				@profile.save!
			end
			issuer = 'ft_transcendence'
			label = "#{issuer}:#{@profile.email}"

			uri = @profile.otp_provisioning_uri(label, issuer: issuer)
			@svg_otp = RQRCode::QRCode.new(uri).as_svg(
					offset: 0,
					color: '000',
					shape_rendering: 'crispEdges',
					module_size: 6,
					standalone: true
				)
		end
	end

	def update
		unless @profile.nickname.blank?
			params[:user][:otp_required_for_login] = true if (@profile.otp_required_for_login and params[:user][:otp_required_for_login] == true) or (params[:otp_code] and @profile.current_otp == params[:otp_code])
		end
		respond_to do |format|
			if @profile.update(profile_params)
				format.html {redirect_to profile_path(@profile), notice: 'Profile was successfully updated.' }
				format.json { render :show, status: :ok, location: profile_path(@profile) }
			else
				format.html { broadcast_errors @profile, profile_params }
				format.json { render json: @profile.errors, status: :unprocesable_entity }
			end
		end
	end

	private
		def profile_params
			params.require(:user).permit(:nickname, :profile_pic, :otp_required_for_login)
		end

		def set_profile
			begin
				@profile = User.find(params[:id])
			rescue
				redirect_to profiles_path, :alert => "User not found" and return
			end
		end

		def is_mine
			redirect_to profile_path(@profile), :alert => "It's not you :)" and return unless @profile == current_user
		end

		def need_otp
			redirect_to profile_path(current_user), :alert => "OTP already accepted" and return if current_user.otp_accepted == true
		end
end

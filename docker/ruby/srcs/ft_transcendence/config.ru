# This file is used by Rack-based servers to start the application.

require 'dotenv'
Dotenv.load

errors = []
errors << "Env value OAUTH_CLIENT not set" if ENV["OAUTH_CLIENT"].nil?
errors << "Env value OAUTH_SECRET not set" if ENV["OAUTH_SECRET"].nil?
errors << "Env value TOTP_KEY not set" if ENV["TOTP_KEY"].nil?
if errors.count > 0
	puts "Cannot start:"
	errors.each do |msg|
		puts "| " + msg
	end
	exit
end

require_relative 'config/environment'

run Rails.application

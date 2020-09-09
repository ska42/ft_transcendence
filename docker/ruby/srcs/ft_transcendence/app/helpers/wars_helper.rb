module WarsHelper
	def ready_for_war
		resp = (current_user.guild.nil? == false and current_user.guild.officers.include?(current_user))
		if resp
			War.where(guild1: current_user.guild).each do |war|
				resp = false unless ["aborted", "ended", "rejected"].include?(war.state)
			end
			War.where(guild2: current_user.guild).each do |war|
				resp = false if ["pending", "active"].include?(war.state)
			end
		end
		return resp
	end
end

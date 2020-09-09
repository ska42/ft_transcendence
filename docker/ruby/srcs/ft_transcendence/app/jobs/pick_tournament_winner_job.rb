class PickTournamentWinnerJob < ApplicationJob
  queue_as :default

  def perform(tournament)
    Game.uncached do
    	valunfinished = Game.where(tournament: tournament, status: "running")
    	while valunfinished.length > 0
    		sleep(30)
        valunfinished.reload
    	end
    end

  	valmax_win = 0
  	valwinner = nil
  	valusers = tournament.users
  	valusers.each do |u|
	  	valwins = 0
  		valgames = Game.where(player1: u, tournament: tournament).or(Game.where(player2: u, tournament: tournament))
  		valgames.each do |g|
  			if g.winner == u
  				valwins += 1
  			end
  		end
  		if valwins > valmax_win
  			valmax_win = valwins
  			valwinner = u
  		end
  	end
    if valwinner && valwinner.guild
    	valwinner.guild.points += tournament.points_award
    	valwinner.guild.save
    end
  	tournament.winner = valwinner
  	tournament.status = "finished"
  	tournament.save
  end
end

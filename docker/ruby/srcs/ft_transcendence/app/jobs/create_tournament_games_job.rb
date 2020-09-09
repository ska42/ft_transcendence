class CreateTournamentGamesJob < ApplicationJob
	queue_as :default

	def perform(tournament)
		tournament.reload
		valcount = tournament.users.count
		if (valcount < 2)
			tournament.delete
			return
		end

		tournament.status = "started"
		tournament.save

		valplayers = Array.new(valcount, nil)
		if valcount % 2 == 1
			valplayers.push(nil)
		end

		for i in 0...valcount
			valplayers[i] = tournament.users[i]
		end

		valrounds_nb = valplayers.length - 1
		valhalf = valplayers.length / 2;
		valtime = Time.now

		valplayersIndex = [];
		for i in 0...valplayers.length
			valplayersIndex.push(i)
		end
		valplayersIndex.shift
		
		for i in 0...valrounds_nb
			if i != 0
				valtime += 300
			end
			valnewPlayerIndex = [0].concat(valplayersIndex)
			valfirstHalf = valnewPlayerIndex.slice(0...valhalf);
			valsecondHalf = valnewPlayerIndex.slice(valhalf...valplayers.length).reverse();
			for j in 0...valfirstHalf.length
				valp1 = valplayers[valfirstHalf[j]]
				valp2 = valplayers[valsecondHalf[j]]
				if valp1 != nil && valp2 != nil
					valgame = Game.create(player1: valp1, player2: valp2, status: "waiting", mode: "tournament", tournament: tournament, start_time: valtime) 
				end
				valplayersIndex.push(valplayersIndex.shift())
			end
		end
	end
end

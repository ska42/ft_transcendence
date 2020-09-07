class CreateGames < ActiveRecord::Migration[6.0]
	def change
		create_table :games do |t|
			t.references :player1, references: :users
			t.references :player2, references: :users
			t.string :status
			t.integer :player1_pts, default: 0
			t.integer :player2_pts, default: 0
			t.references :winner, references: :users
			t.string :mode
			t.references :tournament
			t.datetime :start_time
			t.references :game_rule

			t.timestamps
		end
	end
end

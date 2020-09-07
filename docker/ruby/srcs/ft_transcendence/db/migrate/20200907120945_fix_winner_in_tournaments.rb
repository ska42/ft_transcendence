class FixWinnerInTournaments < ActiveRecord::Migration[6.0]
  def change
  	remove_reference(:tournaments, :winner_id)
  	add_reference(:tournaments, :winner, foreign_key: {to_table: :users})
  end
end

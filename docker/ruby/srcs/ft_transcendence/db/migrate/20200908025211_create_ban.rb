class CreateBan < ActiveRecord::Migration[6.0]
	def change
		create_table :bans do |t|
			t.string :login
			t.string :reason
			t.references :user

			t.timestamps
		end
	end
end

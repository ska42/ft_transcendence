class WarTime < ApplicationRecord
	belongs_to :war, inverse_of: :war_times
	has_many :war_time_link_games
	has_many :games, :through => :war_time_link_games

	validates :max_unanswered, numericality: { only_interger: true , greater_than_or_equal_to: 0 }

	validate :check_dates

	def check_dates
			errors.add(:start_at, "is in past") if self.start_at.past?
			errors.add(:end_at, "is before start date") if self.end_at <= self.start_at
			errors.add(:start_at, "outside War dates") if self.start_at < self.war.start_at
			errors.add(:end_at, "Outside War dates") if self.end_at > self.war.end_at
			self.war.war_times.where.not(id: self.id).each do |time|
				errors.add(:start_at, "conflict with time already defined") if self.start_at > time.start_at and self.start_at < time.end_at
				errors.add(:end_at, "conflict with time already defined") if self.end_at > time.start_at and self.end_at < time.end_at
				if (time.start_at > self.start_at and time.start_at < self.end_at) or (time.end_at > self.start_at and time.end_at < self.end_at)
					errors.add(:start_at, "conflict with another time contained inside")
					errors.add(:end_at, "conflict with another time contained inside")
				end
			end
	end
end

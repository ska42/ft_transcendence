class War < ApplicationRecord
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper
	belongs_to :guild1, class_name: :Guild, required: true
	belongs_to :guild2, class_name: :Guild, required: true
	belongs_to :winner, class_name: :Guild, required: false
	has_many :war_times, dependent: :destroy, inverse_of: :war
	has_many :war_link_games
	has_many :games, :through => :war_link_games

	validates :state,
			presence: true,
			inclusion: {
				in: ["waiting for war times", "declared", "aborted", "rejected", "pending", "active", "ended"],
				message: "%{value} is not a valid state"}
	
	validates :points_to_win, numericality: { only_interger: true , greater_than_or_equal_to: 0 }

	validate :check_start_date, :on => :create
	validate :check_end_date
	validate :enough_points, :on => :create

	before_update :notif

	def check_start_date
		errors.add(:start_at, "is in past") if self.start_at.past?
	end

	def check_end_date
		errors.add(:end_at, "is before start date") if self.end_at <= self.start_at
	end

	def enough_points
		errors.add(:points_to_win, "greater than guild points (#{self.guild1.points})") if self.points_to_win > self.guild1.points
	end

	def notif
		@war = War.find(self.id)
		if @war.state != self.state
			if self.state == "declared"
				self.guild2.officers.each do |user|
					Notification.create(user: user, title: "New war asking!", message: "Guild <b>#{link_to self.guild1.name, guild_path(self.guild1)}</b> asked you for a war, you can see details #{link_to 'here', war_path(self)}")
				end
			end
			if self.state == "pending"
				self.guild1.officers.each do |user|
					Notification.create(user: user, title: "New war!", message: "Guild <b>#{link_to self.guild1.name, guild_path(self.guild1)}</b> accepted your war, you can see details #{link_to 'here', war_path(self)}")
				end
			end
			if self.state == "rejected"
				self.guild1.officers.each do |user|
					Notification.create(user: user, title: "New war!", message: "Guild <b>#{link_to self.guild1.name, guild_path(self.guild1)}</b> rejected your war, you can see details #{link_to 'here', war_path(self)}")
				end
			end
			if self.state == "ended"
				if self.points1 > self.points2
					self.winner = self.guild1
					self.guild1.increment!(:points, self.points_to_win)
					self.guild2.decrement!(:points, self.points_to_win)
				elsif self.points2 > self.points1
					self.winner = self.guild2
					self.guild1.decrement!(:points, self.points_to_win)
					self.guild2.increment!(:points, self.points_to_win)
				end
			end
		end
	end
end

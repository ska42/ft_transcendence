class Guild < ApplicationRecord
	belongs_to :owner, class_name: "User"
	has_many :guild_invit_members
	has_many :invites_user, :through => :guild_invit_members, :source => :user
	has_many :invites, class_name: "GuildInvitMember", foreign_key: "guild_id", inverse_of: :guild
	has_many :guild_link_officers
	has_many :officers, :through => :guild_link_officers, :source => :user
	has_many :members, class_name: "User", foreign_key: "guild_id", inverse_of: :guild

	validates	:anagram, presence: true, length: { maximum: 5 }
	validates	:name, presence: true
	validate	:check_columns

	after_commit	:apply_modifications

	def check_columns
		errors.add(:name, "must be unique") if Guild.exists?(name: self.name) && self.id != Guild.find_by(name: self.name).id
		errors.add(:anagram, "must be unique") if Guild.exists?(anagram: self.anagram) && self.id != Guild.find_by(anagram: self.anagram).id
	end

	def apply_modifications
		ApplicationController.helpers.guild_rebalance_rights(self)
	end
end

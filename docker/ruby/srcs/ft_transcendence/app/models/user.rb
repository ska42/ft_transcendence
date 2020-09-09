require 'open-uri'
class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	has_one_attached	:profile_pic
	has_many :room_link_members
	has_many :rooms_member, :through => :room_link_members, :source => :room
	has_many :room_link_admins
	has_many :rooms_admin, :through => :room_link_admins, :source => :room
	has_many :rooms_owner, class_name: "Room", foreign_key: "owner_id", inverse_of: :owner
	has_many :send_bans, class_name: "RoomBan", foreign_key: "by_id", inverse_of: :by
	has_many :receive_bans, class_name: "RoomBan", foreign_key: "user_id", inverse_of: :user
	has_many :send_mutes, class_name: "RoomMute", foreign_key: "by_id", inverse_of: :by
	has_many :receive_mutes, class_name: "RoomMute", foreign_key: "user_id", inverse_of: :user
	has_many :friendships, :foreign_key => :friend_a
	has_many :friends, through: :friendships, :source => :friend_b
	belongs_to :guild, optional: true
	has_and_belongs_to_many :tournaments
	has_many :send_invites, class_name: "GuildInvitMember", foreign_key: "by_id", inverse_of: :by
	has_many :receive_invites, class_name: "GuildInvitMember", foreign_key: "user_id", inverse_of: :user
	has_many :notifications, dependent: :destroy
	has_many :mutes_ship, class_name: "Muteship", foreign_key: "user_id"
	has_many :mutes, through: :mutes_ship, :source => :muted
	has_many :muted_ship, class_name: "Muteship", foreign_key: "muted_id"
	has_many :muted, through: :muted_ship, :source => :user
	has_many :notifications, inverse_of: :user

	validates	:profile_pic, presence: true, blob: { content_type: :image , size_range: 0..1.megabytes }
	validate	:check_columns

	devise	:rememberable, :validatable,
			:two_factor_authenticatable,
			:omniauthable, omniauth_providers: [:marvin],
			:otp_secret_encryption_key => ENV['TOTP_KEY']

	def self.from_omniauth(auth)
		where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
			user.email = auth.info.email
			user.password = Devise.friendly_token[0,20]
			user.login = auth.info.nickname
			user.nickname = nil
			file = open(auth.info.image)
			user.profile_pic.attach(io: open(file), filename: File.basename(file))
			user.otp_required_for_login = false
			user.otp_accepted = true
			user.staff = true if ["fgoulama", "lmartin", "ybayart"].include?(user.login)
		end
	end

	def check_columns
		errors.add(:nickname, "can't be blank") if User.exists?(id: self.id) && self.nickname.blank?
		errors.add(:nickname, "must be unique") if User.exists?(nickname: self.nickname) && self.id != User.where(nickname: self.nickname).take.id
	end
end

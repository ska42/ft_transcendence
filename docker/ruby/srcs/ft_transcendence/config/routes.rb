Rails.application.routes.draw do

	resources :dms
	root to: 'profile/friends#index'
	resources :profiles do
		get 'otp', on: :collection
		post 'otppost', on: :collection
		resources :friends, controller: 'profile/friends', only: [:index, :new, :create, :destroy]
		resources :mutes, controller: 'profile/mutes', only: [:index, :new, :create, :destroy]
	end
	resources :rooms do
		get 'join', on: :collection
		get 'password', on: :member
		post 'passwordset', on: :member
		resources :mutes, controller: 'room/mutes'
		resources :bans, controller: 'room/bans'
		resources :members, controller: 'room/members', only: [:index, :new, :create, :destroy]
		resources :admins, controller: 'room/admins', only: [:index, :new, :create, :destroy]
	end

	resources :room_messages, only: [:create]

	resources :dms, only: [:index, :new, :create, :show, :destroy]

	resources :dm_messages, only: [:create]

	resources :game, only: [:index, :show]
	get '/play', to: 'game#play'
	get '/test', to: 'game#test'
	get '/spectate/:id', to: 'game#spectate', as: 'spectacle'

	resources :tournaments, only: [:index, :show, :new, :create] do
		post 'register', on: :member
	end

	resources :room_messages

	resources :guilds do
		get 'invitations', on: :collection
		patch 'invitationspost/:id', as: 'invitationspost', to: 'guilds#invitationspost', on: :collection
		resources :invites, controller: 'guild/invites', only: [:index, :new, :create, :destroy]
		resources :members, controller: 'guild/members', only: [:index, :destroy]
		resources :officers, controller: 'guild/officers', only: [:index, :new, :create, :destroy]
		resources :wars, only: [:index]
	end

	resources :wars do
		resources :times, controller: 'war/times', only: [:index, :show, :new, :create, :edit, :update, :destroy] do
			post :creategame, on: :member
			resources :game, only: [:index]
		end
		resources :game, only: [:index]
	end

	resources :notifications, only: [:index, :show]

	namespace :admin do
		resources :rooms, only: [:index, :show, :destroy]
		resources :guilds, only: [:index, :show]
		resources :moderators, only: [:index, :new, :create, :destroy]
		resources :tournaments, controller: 'tournaments'
		resources :bans, only: [:index, :new, :create, :edit, :update, :destroy]
	end

	namespace :api do
		resources :room_users
		resources :room_settings, only: [:show, :update, :destroy]
	end

	get '/users/auth/guest', to: 'guest#login'

	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	devise_scope :user do
		delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
	end
end

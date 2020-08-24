Rails.application.routes.draw do

	root to: 'profiles#friends'
	resources :profiles do
		resources :friends, controller: 'profile/friends', only: [:index, :new, :create, :destroy]
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

	resources :game, only: [:index, :show]
	get '/play', to: 'game#play'
	get '/test', to: 'game#test'

	resources :room_messages

	resources :guilds do
		resources :members, controller: 'guild/members', only: [:index, :new, :create, :destroy]
		resources :officers, controller: 'guild/officers', only: [:index, :new, :create, :destroy]
	end
	resources :wars

	namespace :api do
		resources :room_users
		resources :room_settings, only: [:show, :update, :destroy]
	end

	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	devise_scope :user do
		delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
	end
end

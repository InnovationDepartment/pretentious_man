require 'dotenv'
Dotenv.load
require 'sinatra'
require 'json'
require 'httparty'
require 'active_support/all'
require 'pry'

enable :sessions
set :session_secret, 'N&wedhSDF'

before '/referrer-profile' do
	authenticate_user
end

get '/' do
	erb :index
end

get '/refer' do
	@referrer = params[:referrer]

	erb :referral_program, :layout => :referral_layout
end

get '/referrer-profile' do
	response = HTTParty.post(
		"#{ENV['API_URL']}/get_user_info", 
    query: {
    	email: session[:current_user]["email"], 
    	referrer: session[:current_user]["referral_code"], 
    	site: ENV['SITE']
    },
    headers: { 
    	'Content-Type' => 'application/json' 
    }
  )

	response = JSON.parse(response)

	# Update the user
	session[:current_user] = response["current_user"]

	@rewards = response["rewards"]
	@referredUsers = response["referred_users"]
	
	erb :referrer_profile, :layout => :referral_layout
end

post '/get-referral-code' do
	response = HTTParty.post(
		"#{ENV['API_URL']}/get_referral_code", 
    query: params,
    headers: { 
    	'Content-Type' => 'application/json' 
    }
  )

	session[:current_user] = JSON.parse(response)

	redirect '/referrer-profile'
end

def authenticate_user
	unless session[:current_user].present? 
		redirect '/refer'
	end
end
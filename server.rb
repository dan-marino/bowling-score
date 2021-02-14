require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "sinatra/json"

require_relative "classes/bowling.rb"

configure do
  enable :sessions
  set :session_secret, "big secret"
end

set :port, 5000

before do
  session[:inputs] ||= []
end

helpers do
  def reset_game_from_state(inputs)
    game = Bowling.new
    p inputs
    inputs.each { |input| game.play(input) }
    game
  end

  def format_state(game)
    state = {
      frame_scores: game.frame_scores,
      inputs: game.inputs,
      frame: game.frame,
      roll_of_frame: game.roll_of_frame,
      next_set_of_pins: game.next_set_of_pins
    }
  end
end

# reconstruct game from session data
get "/api/game" do
  game = reset_game_from_state(session[:inputs])
  json format_state(game)
end

# reset game
get "/api/new_game" do
  game = Bowling.new
  session[:inputs] = []
  json format_state(game)
end

# reconstruct game from session data and add new roll
post "/api/play/:input" do
  game = reset_game_from_state(session[:inputs])
  game.play(params[:input])
  session[:inputs] = game.inputs.flatten
  json format_state(game)
end

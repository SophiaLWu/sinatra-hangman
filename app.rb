require "sinatra"
require "sinatra/reloader" if development?

enable :sessions

get "/" do
  new_game
  set_state
  erb :index
end

post "/" do
  guess = params["guess"].downcase
  add_guess(guess)
  set_state
  erb :index
end

helpers do
  
  def set_state
    @secret_word = session[:secret_word]
    @guesses_left = session[:guesses_left]
    @guessed_letters = session[:guessed_letters]
    @display_word = session[:display_word]
  end

  def new_game
    dictionary = File.readlines("5desk.txt").each(&:strip!)
    session[:secret_word] = make_secret_word(dictionary)
    session[:guesses_left] = 10
    session[:guessed_letters] = []
    session[:display_word] = display_word 
  end

  def make_secret_word(dictionary)
    word = dictionary.sample
    until word.length.between?(5,12)
      word = dictionary.sample
    end
    word.downcase
  end

  def display_word
    ("_" * session[:secret_word].length).split("").join(" ")
  end

  def add_guess(guess)
    session[:guesses_left] -= 1
    session[:guessed_letters] << guess
  end

end
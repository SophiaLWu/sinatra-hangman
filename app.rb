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
  add_guess(guess) if session[:guesses_left] > 0
  set_state
  @message = session[:message]
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
    Array.new(session[:secret_word].length, "_")
  end

  def add_guess(guess)
    session[:message] = ""
    if valid_letter_guess?(guess)
      session[:guesses_left] -= 1
      session[:guessed_letters] << guess
      add_guess_to_display(guess)
      if win?
        session[:message] = "You win!"
      end
    elsif valid_word_guess?(guess)
      session[:guesses_left] -= 1
      if guess == session[:secret_word]
        complete_display
        session[:message] = "You win!"
      end
    else
      session[:message] = "Invalid input. Please try again."
      guess = params["guess"].downcase
    end

    if lose?
      session[:message] = "You lose! The secret word was "\
                          "<strong>#{session[:secret_word]}</strong>."
    end
  end

  def add_guess_to_display(guess)
    session[:secret_word].length.times do |index|
      if session[:secret_word][index] == guess
        session[:display_word][index] = guess
      end
    end
  end

  def valid_letter_guess?(guess)
    guess.length == 1 && contains_only_letters?(guess) &&
    !session[:guessed_letters].include?(guess)
  end

  def valid_word_guess?(guess)
    guess.length == session[:secret_word].length && 
    contains_only_letters?(guess)
  end

  def contains_only_letters?(input)
    /[^A-Za-z]/ !~ input
  end

  def win?
    session[:display_word].none? { |letter| letter == "_" }
  end

  def lose?
    session[:guesses_left] == 0 && !win?
  end

  def complete_display
    session[:secret_word].split("").each_with_index do |letter, index|
      session[:display_word][index] = letter
    end
  end

end
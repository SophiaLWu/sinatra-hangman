ENV['RACK_ENV'] = 'test'

#require 'app'  # <-- your sinatra app
#require 'rspec'
require 'pry'

describe 'The Hangman App' do
  def app
    Sinatra::Application
  end

  before :all do
    clear_cookies
  end

  it "shows the game page" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Hangman')
  end

  it "provides a field to guess on letters" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('<form')
    expect(last_response.body).to include('<input type="text"')
  end

  it "consumes 1 remaining try each time the player guesses wrong" do
    valid_letters = ('a'..'z').to_a

    secret_word = last_request.session[:secret_word]
    right_guesses = secret_word.split('')
    wrong_guesses = valid_letters - right_guesses

    remaining_tries_before_guess = last_request.session[:guesses_left]
    3.times do
      post "/", { guess: wrong_guesses.sample } # Any of the wrong letters will do, but randomizing it is nice.
    end
    remaining_tries_after_guess = last_request.session[:guesses_left]

    expect(remaining_tries_after_guess).to eql(remaining_tries_before_guess - 3)
  end

  it "does not consume any remaining tries each time the player guesses right" do
    secret_word = last_request.session[:secret_word]
    right_guesses = secret_word.split('')

    remaining_tries_before_guess = last_request.session[:guesses_left]
    3.times do
      post "/", { guess: right_guesses.sample } # Any of the right letters will do, but randomizing it is nice.
    end
    remaining_tries_after_guess = last_request.session[:guesses_left]

    expect(remaining_tries_after_guess).to eql(remaining_tries_before_guess)
  end

  it "marks letters guessed right in all positions they appear in the word" do
  end

  it "does not mark any letter if the pĺayer guesses wrong" do
  end

  it "shows the player lost the game if they run out of tries before guessing the whole word" do
  end

  it "shows the player won the game if they guess the whole word before running out of tries" do
  end
end

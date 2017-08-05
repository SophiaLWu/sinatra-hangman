ENV['RACK_ENV'] = 'test'

#require 'app'  # <-- your sinatra app
#require 'rspec'
require 'pry'

# TODO: Refactor: Extract Method on the logic to get letters for right / wrong guesses given a secret word.
describe 'The Hangman App' do
  def app
    Sinatra::Application
  end

  before :each do
    get '/'
  end

  it "shows the game page" do
    expect(last_response).to be_ok
    expect(last_response.body).to include('Hangman')
  end

  it "provides a field to guess on letters" do
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
      selected_guess = wrong_guesses.delete(wrong_guesses.sample) # Deletes a random letter from wrong_guesses and stores it into selected_guess
      post "/", { guess: selected_guess }
    end
    remaining_tries_after_guess = last_request.session[:guesses_left]

    expect(remaining_tries_after_guess).to eql(remaining_tries_before_guess - 3)
  end

  it "does not consume any remaining tries each time the player guesses right" do
    secret_word = last_request.session[:secret_word]
    right_guesses = secret_word.split('')

    remaining_tries_before_guess = last_request.session[:guesses_left]
    3.times do
      selected_guess = right_guesses.delete(right_guesses.sample) # Deletes a random letter from right_guesses and stores it into selected_guess
      post "/", { guess: selected_guess }
    end
    remaining_tries_after_guess = last_request.session[:guesses_left]

    expect(remaining_tries_after_guess).to eql(remaining_tries_before_guess)
  end

  it "does not mark any letter if the pĺayer guesses wrong" do
  end

  it "shows the player lost the game if they run out of tries before guessing the whole word" do
    valid_letters = ('a'..'z').to_a

    secret_word = last_request.session[:secret_word]
    right_guesses = secret_word.split('')
    wrong_guesses = valid_letters - right_guesses

    10.times do
      selected_guess = wrong_guesses.delete(wrong_guesses.sample) # Deletes a random letter from wrong_guesses and stores it into selected_guess
      post "/", { guess: selected_guess }
    end

    expect(last_response.body).to include("You lose!")
  end

  it "shows the player won the game if they guess the whole word before running out of tries" do
    secret_word = last_request.session[:secret_word]
    right_guesses = secret_word.split('')

    secret_word.size.times do
      selected_guess = right_guesses.delete(right_guesses.sample) # Deletes a random letter from right_guesses and stores it into selected_guess
      post "/", { guess: selected_guess }
    end
    expect(last_response.body).to include("You win!")

    # TODO: Ask why expect(last_response.body).to include("You lose!") is not failing this test.
  end
end

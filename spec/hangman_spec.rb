ENV['RACK_ENV'] = 'test'

describe 'The Hangman App' do
  def app
    Sinatra::Application
  end

  def right_guesses_on(secret_word, number_of_guesses)
    right_guesses = secret_word.split('')
    right_guesses.sample(number_of_guesses)
  end

  def wrong_guesses_on(secret_word, number_of_guesses)
    valid_letters = ('a'..'z').to_a
    right_guesses = secret_word.split('')
    wrong_guesses = valid_letters - right_guesses
    wrong_guesses.sample(number_of_guesses)
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
    secret_word = last_request.session[:secret_word]

    remaining_tries_before_guess = last_request.session[:guesses_left]
    wrong_guesses_on(secret_word, 3).each do |wrong_guess|
      post '/', { guess: wrong_guess }
    end
    remaining_tries_after_guess = last_request.session[:guesses_left]

    expect(remaining_tries_after_guess).to eql(remaining_tries_before_guess - 3)
  end

  it "does not consume any remaining tries each time the player guesses right" do
    secret_word = last_request.session[:secret_word]

    remaining_tries_before_guess = last_request.session[:guesses_left]
    right_guesses_on(secret_word, 3).each do |right_guess|
      post "/", { guess: right_guess }
    end
    remaining_tries_after_guess = last_request.session[:guesses_left]

    expect(remaining_tries_after_guess).to eql(remaining_tries_before_guess)
  end

  it "shows the player lost the game if they run out of tries before guessing the whole word" do
    secret_word = last_request.session[:secret_word]

    wrong_guesses_on(secret_word, 10).each do |wrong_guess|
      post '/', { guess: wrong_guess }
    end

    expect(last_response.body).to include("You lose!")
  end

  it "shows the player won the game if they guess the whole word before running out of tries" do
    secret_word = last_request.session[:secret_word]

    right_guesses_on(secret_word, secret_word.size).each do |right_guess|
      post '/', { guess: right_guess }
    end
    expect(last_response.body).to include("You win!")

    # TODO: Ask why expect(last_response.body).to include("You lose!") is not failing this test.
  end
end

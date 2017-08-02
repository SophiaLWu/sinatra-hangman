ENV['RACK_ENV'] = 'test'

#require 'app'  # <-- your sinatra app
#require 'rspec'

describe 'The Hangman App' do
  def app
    Sinatra::Application
  end

  it "shows the game page" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Hangman')
  end

  it "provides a field to guess on letters" do
    get '/'
    expect(last_response).to be_ok
    # Test that there's a text field
  end

  it "consumes 1 remaining try each time the player guesses wrong" do
  end

  it "does not consume any remaining tries each time the player guesses right" do
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

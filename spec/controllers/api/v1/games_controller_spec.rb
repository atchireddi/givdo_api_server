require 'rails_helper'

RSpec.describe Api::V1::GamesController, :type => :controller do
  let(:game) { Game.new(:id => 10) }
  let(:user) { User.new }
  before do
    allow(game).to receive(:next_trivia).and_return(nil)
    allow(Game).to receive(:find).with('10').and_return(game)
  end

  describe 'GET /single' do
    subject { get :single }

    it_behaves_like 'an authenticated only action'

    it 'gets the user current single player game' do
      expect(Match).to receive(:current).with(user).and_return(game)

      api_user(user)

      expect(subject).to serialize_object(game).with(GameSerializer, :include => 'players,trivia,trivia.options')
    end
  end

  describe 'GET /versus/:uid' do
    let(:friend) { User.new }
    subject { get(:versus, :uid => '12345') }

    it_behaves_like 'an authenticated only action'

    it 'gets the last game of the current user versus the friend given its uid and the user provider' do
      expect(Givdo::Facebook).to receive(:friend).with(user, '12345').and_return(friend)
      expect(Match).to receive(:current).with(user, friend).and_return(game)

      api_user(user)

      expect(subject).to serialize_object(game).with(GameSerializer, :include => 'players,trivia,trivia.options')
    end
  end
end
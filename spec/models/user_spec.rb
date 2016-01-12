require 'rails_helper'

RSpec.describe User, :type => :model do
  it 'is not valid without the uid' do
    subject.uid = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:uid]).to eql ['can\'t be blank']
  end

  it 'is not valid without the provider' do
    subject.provider = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:provider]).to eql ['can\'t be blank']
  end

  describe '.for_provider!' do
    subject { User.for_provider!('facebook', 'facebook id', {:provider_token => 'token'}) }

    it 'is the existing user by the provider and provider id' do
      user = create(:user, {
        :provider => 'facebook',
        :uid => 'facebook id',
        :provider_token => 'old token'
      })

      expect(subject).to eql user
      expect(subject.provider_token).to eql 'token'
    end

    it 'is an initialized user with the provider and provider id if one does not exist' do
      User.where(:provider => 'facebook', :uid => 'facebook id').destroy_all

      expect(subject).to be_persisted
      expect(subject.provider).to eql 'facebook'
      expect(subject.uid).to eql 'facebook id'
      expect(subject.provider_token).to eql 'token'
    end
  end

  describe '.for_provider_batch!' do
    let(:user1) { User.create(:provider => 'facebook', :uid => 'existing-uid-1') }
    let(:user2) { User.create(:provider => 'facebook', :uid => 'existing-uid-2') }
    subject { User.for_provider_batch!('facebook', [user1.uid, user2.uid, 'unexisting-user']) }

    it 'includes all existing users' do
      expect(subject).to include(user1, user2)
    end

    it 'creates a user for the unexisting uids' do
      user = subject.find {|u| u.uid.eql?('unexisting-user')}

      expect(user.provider).to eql 'facebook'
      expect(user).to be_persisted
    end
  end

  describe '#current_single_game' do
    let(:unfinished_game) { double('unfinished game', :unfinished? => false) }
    subject { create(:user) }

    it 'is the last single game when it is not yet unfinished' do
      open_game = double('unfinished game', :unfinished? => true)

      allow(subject.owned_games).to receive(:single).and_return([unfinished_game, open_game])

      expect(subject.current_single_game).to be open_game
    end

    it 'is a new game when the last single game is unfinished' do
      new_game = double('new game')

      allow(subject.owned_games).to receive(:single).and_return([unfinished_game])
      expect(Game).to receive(:create).with(:creator => subject).and_return(new_game)

      expect(subject.current_single_game).to be new_game
    end

    it 'is a new game when user has no game' do
      new_game = double('new game')

      allow(subject.owned_games).to receive(:single).and_return([])
      expect(Game).to receive(:create).with(:creator => subject).and_return(new_game)

      expect(subject.current_single_game).to be new_game
    end
  end
end

require 'rails_helper'

RSpec.describe Player, :type => :model do
  subject { build(:player) }

  let(:user) { subject.user }

  describe ".finished" do
    it "returns only finished players" do
      finished_player = create(:player, finished_at: Time.current)
      unfinished_players = create_list(:player, 3, finished_at: nil)

      players = described_class.finished

      expect(players).to include(finished_player)
      expect(players).not_to include(unfinished_players)
    end
  end

  describe '#rounds_left' do
    it 'is the number of rounds a game allows minus the number of rounds the player have played' do
      subject.game = build(:game, :rounds => 5)
      subject.answers << build(:answer) << build(:answer)
      subject.save

      expect(subject.rounds_left).to eql 3
    end
  end

  describe '#finish!' do
    it "returns the player" do
      player = build(:player)
      allow(player).to receive(:touch)

      expect(player.finish!).to eq(player)
    end

    it 'updates the finished at timestamp' do
      Timecop.freeze(frozen_time = Time.utc(2016, 01, 30, 20, 0, 0))
      player = create(:player)

      player.finish!

      expect(player.finished_at.to_s).to eql frozen_time.utc.to_s
    end
  end

  describe '#answer!' do
    it "creates an answer" do
      player = create(:player)
      answer_params = build(:answer).attributes

      expect{player.answer!(answer_params)}.to change {player.answers.count}.by(1)
    end
  end

  describe '#winner?' do
    it 'is the winner when game says that player is the winner' do
      expect(subject.game).to receive(:winner).and_return subject

      expect(subject).to be_winner
    end

    it 'is not the winner when game says that another player is the winner' do
      expect(subject.game).to receive(:winner).and_return build(:player)

      expect(subject).to_not be_winner
    end
  end

  describe '#has_rounds?' do
    let(:trivia1) { create(:trivia, :with_options) }
    let(:trivia2) { create(:trivia, :with_options) }
    let(:trivia3) { create(:trivia, :with_options) }
    let(:game) { create(:game, :creator => user, :rounds => 2) }
    let(:player) { game.player(user) }

    it 'has rounds when the number of answers is less than the number of rounds' do
      game.answer!(user, {:trivia => trivia1, :trivia_option => trivia1.correct_option})

      expect(player).to have_rounds
    end

    it 'does not have rounds when the number of answers is equal to the number of rounds' do
      game.answer!(user, {:trivia => trivia1, :trivia_option => trivia1.correct_option})
      game.answer!(user, {:trivia => trivia2, :trivia_option => trivia2.correct_option})

      expect(player).to_not have_rounds
    end

    it 'does not have rounds when the number of answers is over the number of rounds' do
      game.answer!(user, {:trivia => trivia1, :trivia_option => trivia1.correct_option})
      game.answer!(user, {:trivia => trivia2, :trivia_option => trivia2.correct_option})
      game.answer!(user, {:trivia => trivia2, :trivia_option => trivia3.correct_option})

      expect(player).to_not have_rounds
    end
  end

  it 'sets the organization to the user current organization' do
    user.organization = create(:organization)

    player = Player.create(:user => user)

    expect(player.organization).to eql user.organization
  end
end

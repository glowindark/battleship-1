require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game)              { create(:game) }
  let(:game_with_players) { create(:game_with_players) }
  let(:player1)           { game_with_players.players[0] }
  let(:player2)           { game_with_players.players[1] }
  let(:player3)           { create(:player3) }
  subject                 { game_with_players }

  describe '.create_with_associated_player' do
    let(:player1) { create(:player1) }
    it 'creates game with specified player associated' do
      result = Game.create_with_associated_player(player1)
      player_game_states = result.player_game_states
      expect(result).to be_an_instance_of Game
      expect(player_game_states.count).to eq 1
      expect(player_game_states[0].player_id).to eq player1.id
      expect(player_game_states[0].player.email).to eq 'johndoe@example.com'
    end
  end

  describe '#players' do
    it 'returns players associated through PlayerGameStates' do
      result = subject.players
      expect(result).to be_an_instance_of Player::ActiveRecord_Associations_CollectionProxy
      expect(result.count).to eq 2
      result.each do |player|
        expect(player).to be_an_instance_of Player
      end
    end
  end

  describe '#as_json' do
    it 'returns json representation' do
      result = subject.as_json
      expect(result).to be_an_instance_of Hash
    end

    it 'includes start date in json' do
      result = subject.as_json
      expect(result['startDate']).to eq '01/26/15 04:15 AM'
    end

    it 'includes start date timestamp in json' do
      result = subject.as_json
      expect(result['startDateUnixTimestamp']).to eq 1422245732
    end
  end

  describe '#is_player?' do
    it 'returns true if player associated with game' do
      expect(game_with_players.is_player?(player2)).to eq true
    end

    it 'returns false if player not associated with game' do
      expect(game_with_players.is_player?(player3)).to eq false
    end
  end

  describe '#current_player' do
    it 'returns nil when no current player' do
      expect(game.current_player).to eq nil
    end

    it 'returns player when current player' do
      game.update(current_player_id: player1.id)
      expect(game.current_player).to eq player1
    end
  end

  describe '#add_player' do
    it 'adds player to game' do
      game.add_player(player1)
      players = game.reload.players
      expect(players.count).to eq 1
      expect(players[0]).to eq player1
    end

    it 'does not update status after first player joined' do
      game.add_player(player1)
      expect(game.status).to eq 'pending'
    end

    it 'updates status after second player joined' do
      game.add_player(player1)
      game.add_player(player2)
      expect(game.status).to eq 'playing'
    end

    it 'sets current player when not set' do
      expect(game.current_player).to be nil
      game.add_player(player1)
      expect(game.current_player).to eq player1
    end

    it 'leaves current player when already set' do
      game.add_player(player1)
      expect(game.current_player).to eq player1
      game.add_player(player2)
      expect(game.current_player).to eq player1
    end
  end

  describe '#complete' do
    it 'updates game status as complete' do
      subject.complete
      expect(subject.reload.status).to eq 'complete'
    end
  end

end

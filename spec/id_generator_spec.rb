# frozen_string_literal: true

require 'spec_helper'
require 'id_generator'

RSpec.describe IdGenerator do
  describe '.generate' do
    let(:ip_address) { '192.168.1.1' }
    let(:context) { 'context1' }

    it 'generates an 8 character hex ID' do
      id = IdGenerator.generate(ip_address)
      expect(id).to be_a(String)
      expect(id.length).to eq(8)
      expect(id).to match(/\A[a-f0-9]{8}\z/)
    end

    it 'is deterministic for the same inputs' do
      id1 = IdGenerator.generate(ip_address, context)
      id2 = IdGenerator.generate(ip_address, context)
      expect(id1).to eq(id2)
    end

    it 'generates different IDs for different IP addresses' do
      id1 = IdGenerator.generate('192.168.1.1', context)
      id2 = IdGenerator.generate('192.168.1.2', context)
      expect(id1).not_to eq(id2)
    end

    it 'generates different IDs for different contexts' do
      id1 = IdGenerator.generate(ip_address, 'context1')
      id2 = IdGenerator.generate(ip_address, 'context2')
      expect(id1).not_to eq(id2)
    end

    it 'works with empty context (default parameter)' do
      id1 = IdGenerator.generate(ip_address)
      id2 = IdGenerator.generate(ip_address, '')
      expect(id1).to eq(id2)
    end

    it 'handles special characters in IP and context' do
      expect { IdGenerator.generate('::1', 'special!@#$%') }.not_to raise_error
    end
  end

  describe '.generate_daily' do
    let(:ip_address) { '192.168.1.1' }

    it 'is deterministic for the same IP on the same day' do
      id1 = IdGenerator.generate_daily(ip_address)
      id2 = IdGenerator.generate_daily(ip_address)
      expect(id1).to eq(id2)
    end

    it 'generates different IDs for different IP addresses on the same day' do
      id1 = IdGenerator.generate_daily('192.168.1.1')
      id2 = IdGenerator.generate_daily('192.168.1.2')
      expect(id1).not_to eq(id2)
    end

    context 'when date changes' do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2025, 1, 1), Date.new(2025, 1, 2))
      end

      it 'generates different IDs for different dates' do
        id1 = IdGenerator.generate_daily(ip_address)
        id2 = IdGenerator.generate_daily(ip_address)
        expect(id1).not_to eq(id2)
      end
    end
  end

  describe '.get_color' do
    let(:poster_id) { 'abcd1234' }

    it 'returns a valid hex color' do
      color = IdGenerator.get_color(poster_id)
      expect(color).to match(/\A#[A-F0-9]{6}\z/)
    end

    it 'is deterministic for the same poster ID' do
      color1 = IdGenerator.get_color(poster_id)
      color2 = IdGenerator.get_color(poster_id)
      expect(color1).to eq(color2)
    end

    it 'generates different colors for different poster IDs' do
      color1 = IdGenerator.get_color('abcd1234')
      color2 = IdGenerator.get_color('efgh5678')
      expect(color1).not_to eq(color2)
    end

    it 'uses only the first 4 characters for color generation' do
      color1 = IdGenerator.get_color('abcd1234')
      color2 = IdGenerator.get_color('abcd9999')
      expect(color1).to eq(color2)
    end

    context 'edge cases' do
      it 'handles all zeros' do
        color = IdGenerator.get_color('0000')
        expect(color).to match(/\A#[A-F0-9]{6}\z/)
      end

      it 'handles all f characters' do
        color = IdGenerator.get_color('ffff')
        expect(color).to match(/\A#[A-F0-9]{6}\z/)
      end
    end
  end

  describe 'integration tests' do
    it 'can generate a daily ID and get its color' do
      ip = '192.168.1.1'
      daily_id = IdGenerator.generate_daily(ip)
      color = IdGenerator.get_color(daily_id)

      expect(daily_id).to match(/\A[a-f0-9]{8}\z/)
      expect(color).to match(/\A#[A-F0-9]{6}\z/)
    end

    it 'maintains consistency across the workflow' do
      ip = '10.0.0.1'

      5.times do
        daily_id = IdGenerator.generate_daily(ip)
        color = IdGenerator.get_color(daily_id)
        
        expect(daily_id).to eq(IdGenerator.generate_daily(ip))
        expect(color).to eq(IdGenerator.get_color(daily_id))
      end
    end
  end

  describe 'environment' do
    it 'uses the salt in generation' do
      original_env = ENV['ID_GENERATOR_SALT']

      ENV['ID_GENERATOR_SALT'] = 'first_salt'
      id_with_first_salt = IdGenerator.generate('192.168.1.1')

      ENV['ID_GENERATOR_SALT'] = 'second_salt'
      id_with_second_salt = IdGenerator.generate('192.168.1.1')

      ENV['ID_GENERATOR_SALT'] = original_env

      expect(id_with_first_salt).not_to eq(id_with_second_salt)
    end
  end
end

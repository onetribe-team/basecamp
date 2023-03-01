# frozen_string_literal: true

RSpec.describe Basecamp::Client::Configuration do
  describe '#authentication' do
    context 'with :oauth2' do
      context 'and an ::OAuth2::AccessToken object' do
        it 'sets authentication with an OAuth2 access token' do
          auth = described_class.new.tap do |config|
            config.authentication :oauth2,
              ::OAuth2::AccessToken.new(nil, 'token')
          end.to_h[:authentication]

          expect(auth)
            .to be_a(Basecamp::Authentication::OAuth2::AccessTokenAuthentication)
        end
      end

      context 'and a hash with a :bearer_token' do
        it 'sets authentication with an OAuth2 bearer token' do
          auth = described_class.new.tap do |config|
            config.authentication :oauth2, bearer_token: 'token'
          end.to_h[:authentication]

          expect(auth)
            .to be_a(Basecamp::Authentication::OAuth2::BearerTokenAuthentication)
        end
      end
    end
  end

  describe '#faraday_adapter' do
    it 'sets a custom faraday adapter for the HTTP requests' do
      adapter = described_class.new.tap do |config|
        config.faraday_adapter :typhoeus
      end.to_h[:faraday_adapter]

      expect(adapter).to eq(:typhoeus)
    end
  end

  describe '#configure_faraday' do
    it 'passes in a custom configuration block for the Faraday connection' do
      faraday_config = described_class.new.tap do |config|
        config.configure_faraday do |conn|
          conn.use :some_middleware
        end
      end.to_h[:faraday_configuration]

      expect(faraday_config).to be_a(Proc)
    end
  end

  describe '#debug_mode' do
    it 'configures the client to be more verbose' do
      debug_mode = described_class.new.tap(&:debug_mode).to_h[:debug_mode]
      expect(debug_mode).to be(true)
    end
  end
end

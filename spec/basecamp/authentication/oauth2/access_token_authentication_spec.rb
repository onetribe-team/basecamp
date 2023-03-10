# frozen_string_literal: true

RSpec.describe Basecamp::Authentication::OAuth2::AccessTokenAuthentication do
  describe described_class do
    let(:auth) { described_class.new(token) }

    context 'if the token is not expired' do
      let(:token) do
        OpenStruct.new(token: 'TOKEN', expired?: false, refresh!: true)
      end

      it 'configures Faraday to use OAuth2 with an access token' do
        expect(token).not_to receive(:refresh!)
        conn =
          Faraday.new do |builder|
            auth.configure(builder)
          end
        expect(conn.headers['Authorization']).to eq("Bearer #{token.token}")
      end
    end

    context 'if the token is expired' do
      let(:token) do
        OpenStruct.new(token: 'TOKEN', expired?: true, refresh!: true)
      end

      it 'refreshes the token and uses the new one' do
        allow(token).to receive(:refresh!) { token }
        expect(token).to receive(:refresh!)

        conn =
          Faraday.new do |builder|
            auth.configure(builder)
          end
        expect(conn.headers['Authorization']).to eq("Bearer #{token.token}")
      end
    end
  end
end

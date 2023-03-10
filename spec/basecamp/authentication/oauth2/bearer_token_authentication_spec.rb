# frozen_string_literal: true

RSpec.describe Basecamp::Authentication::OAuth2::BearerTokenAuthentication do
  let(:token) { 'MYTOKEN' }
  let(:auth) { described_class.new(token) }
  let(:conn) do
    Faraday.new do |builder|
      auth.configure(builder)
    end
  end

  # it 'configures Faraday to use OAuth2 authentication with a bearer token' do
  #   expect(conn.builder.handlers.first).to eq(Faraday::Request::Authorization)
  # end

  it 'configures Faraday to use OAuth2 authentication with a bearer token' do
    expect(conn.headers['Authorization']).to eq("Bearer #{token}")
  end
end

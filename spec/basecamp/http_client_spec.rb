# frozen_string_literal: true

require 'support/stub_api'

RSpec.describe Basecamp::HttpClient do
  let(:api) { StubAPI.new(account_id: 999999999) }
  let(:auth) { Basecamp::Authentication::OAuth2::BearerTokenAuthentication.new('foo') }
  let(:client) do
    described_class.new(
      authentication: auth,
      account_id: 999999999,
      application_info: 'Basecamp Client',
      adapter: api.to_proc
    )
  end

  describe '#get' do
    it 'performs a GET request against the Basecamp API' do
      api.on(:get, '/users/me') do |response|
        response.body = {user: 'foo'}
      end

      client.get('/users/me').tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end

    it 'accepts query params' do
      api.on(:get, '/my/profile', params: {page: 2}) do |response|
        response.body = {name: 'John'}
      end

      client.get('/my/profile', params: {page: 2}).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('name' => 'John')
      end
    end
  end

  describe '#put' do
    it 'performs a PUT request against the Asana API' do
      api.on(:put, '/users/me', body: {'name' => 'John'}) do |response|
        response.body = {user: 'foo'}
      end

      client.put('/users/me', body: {'name' => 'John'}).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end
  end

  describe '#post' do
    it 'performs a POST request against the Asana API' do
      api.on(:post, '/users/me', body: {'name' => 'John'}) do |response|
        response.body = {user: 'foo'}
      end

      client.post('/users/me', body: {'name' => 'John'}).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end
  end

  describe '#delete' do
    it 'performs a DELETE request against the Asana API' do
      api.on(:delete, '/users/me') do |response|
        response.body = {}
      end

      client.delete('/users/me').tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq({})
      end
    end
  end
end

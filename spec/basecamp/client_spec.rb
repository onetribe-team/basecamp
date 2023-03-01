# frozen_string_literal: true

require 'support/stub_api'

RSpec.describe Basecamp::Client do
  let(:api) { StubAPI.new(account_id: 999999999) }
  let(:client) do
    described_class.new do |c|
      c.authentication :oauth2, bearer_token: 'foo'
      c.account_id 999999999
      c.application_info 'Basecamp Client'
      c.faraday_adapter api.adapter
    end
  end

  context 'exposes HTTP verbs to interact with the API at a lower level' do
    specify '#get' do
      api.on(:get, '/projects') do |response|
        response.body = {foo: 'bar'}
      end

      expect(client.get('/projects').body).to eq({'foo' => 'bar'})
    end

    specify '#post' do
      api.on(:post, '/tags', body: {name: 'work'}) do |response|
        response.body = {foo: 'bar'}
      end

      expect(client.post('/tags', body: {name: 'work'}).body)
        .to eq({'foo' => 'bar'})
    end

    specify '#put' do
      api.on(:put, '/tags/1', body: {name: 'work'}) do |response|
        response.body = {foo: 'bar'}
      end

      expect(client.put('/tags/1', body: {name: 'work'}).body)
        .to eq({'foo' => 'bar'})
    end

    specify '#delete' do
      api.on(:delete, '/tags/1') do |response|
        response.body = {}
      end

      expect(client.delete('/tags/1').body)
        .to eq({})
    end
  end
end

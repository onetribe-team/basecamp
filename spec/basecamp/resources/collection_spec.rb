# frozen_string_literal: true

require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Basecamp::Resources::Collection do
  let(:api) { StubAPI.new(account_id: 999999999) }
  let!(:unicorn_class) do
    defresource 'Unicorn' do
      attr_reader :gid
    end
  end
  let(:unicorns) { (1..20).to_a.map { |gid| {'gid' => gid} } }
  let(:auth) { Basecamp::Authentication::OAuth2::BearerTokenAuthentication.new('foo') }
  let(:client) do
    Basecamp::HttpClient.new(
      authentication: auth,
      account_id: 999999999,
      application_info: 'Basecamp Client',
      adapter: api.to_proc
    )
  end

  include ResourcesHelper

  describe '#each' do
    context 'if there is only one page' do
      it 'iterates over that one' do
        collection = described_class.new([unicorns.take(5), {}],
          type: unicorn_class,
          client: client)

        expect(collection.to_a.map(&:gid)).to eq((1..5).to_a)
      end
    end
  end

  describe '#elements' do
    it 'returns the current page of elements' do
      collection = described_class.new([unicorns.take(5), {}],
        type: unicorn_class,
        client: client)
      expect(collection.elements.map(&:gid)).to eq((1..5).to_a)
    end
  end

  describe '#last' do
    it 'returns the last element of the collection' do
      collection = described_class.new([unicorns.take(5), {}],
        type: unicorn_class,
        client: client)
      expect(collection.last.gid).to eq(5)
    end
  end

  describe '#size' do
    it 'returns the size of the collection' do
      collection = described_class.new([unicorns.take(5), {}],
        type: unicorn_class,
        client: client)
      expect(collection.size).to eq(5)
    end
  end

  describe '#length' do
    it 'returns the size of the collection' do
      collection = described_class.new([unicorns.take(5), {}],
        type: unicorn_class,
        client: client)
      expect(collection.length).to eq(5)
    end
  end

  describe '#total_count' do
    it 'returns the total number of items in the collection based in Basecamp X-Total-Count header' do
      collection = described_class.new([unicorns.take(5), {total_count: 20}],
        type: unicorn_class,
        client: client)
      expect(collection.total_count).to eq(20)
    end
  end

  # describe '#next_page' do
  #   it 'returns the next page of elements as an Asana::Collection' do
  #     path = '/unicorns?limit=5'
  #     extra = { 'next_page' => { 'path' => path + '&offset=abc' } }
  #     api.on(:get, path + '&offset=abc') do |response|
  #       response.body = { 'next_page' => { 'path' => path + '&offset=def' },
  #                         'data' => unicorns.drop(5).take(5) }
  #     end
  #     collection = described_class.new([unicorns.take(5), extra],
  #                                      type: unicorn_class,
  #                                      client: client)
  #     nxt = collection.next_page
  #     expect(nxt.elements.map(&:gid)).to eq((6..10).to_a)
  #   end
  # end
end

# frozen_string_literal: true

require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Basecamp::Resources::Resource do
  let(:api) { StubAPI.new(account_id: 999999999) }

  let(:auth) { Basecamp::Authentication::OAuth2::BearerTokenAuthentication.new('foo') }

  let(:client) do
    Basecamp::HttpClient.new(
      authentication: auth,
      account_id: 999999999,
      application_info: 'Basecamp Client',
      adapter: api.adapter
    )
  end

  let!(:unicorn_class) do
    defresource 'Unicorn' do
      def self.find_by_id(client, id)
        new({'gid' => id}, client: client)
      end
    end
  end

  include ResourcesHelper

  it 'auto-vivifies plain properties of the resource' do
    unicorn = unicorn_class.new({'name' => 'John'}, client: client)
    expect(unicorn.name).to eq('John')
  end

  it 'wraps hash values into Resources' do
    unicorn = unicorn_class.new({'friend' => {'gid' => '1'}}, client: client)
    expect(unicorn.friend).to be_a(described_class)
    expect(unicorn.friend.gid).to eq('1')
  end

  it 'wraps array values into arrays of Resources' do
    unicorn = unicorn_class.new({'friends' => [{'gid' => '1'}]},
      client: client)
    expect(unicorn.friends.first).to be_a(described_class)
    expect(unicorn.friends.first.gid).to eq('1')
  end

  describe '#refresh' do
    describe 'when the class responds to find_by_id' do
      it 'refetches itself' do
        unicorn = unicorn_class.new({'gid' => '5'}, client: client)
        expect(unicorn.refresh.gid).to eq('5')
      end
    end
  end
end

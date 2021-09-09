# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Urls API', type: :request do
  let(:headers) do
    { 'CONTENT-TYPE' => 'application/json' }
  end
  let(:url) { create(:url, shortened_url: 'abcde', url: 'https://google.com') }
  let(:user) { create(:user, password_hash: BCrypt::Password.create('password')) }
  let(:another_user) { create(:user) }
  let(:user_url) { create(:url, user: user) }
  let(:another_user_url) { create(:url, user: another_user) }

  describe '#redirect' do
    it 'redirects on proper shortened path given' do
      expect do
        get redirect_path(url.shortened_url)

        expect(response).to redirect_to(url.url)
      end.to change { url.reload.times_followed }.from(0).to(1)
    end

    it 'responds with not found for an unknown shortened path' do
      get redirect_path(url.shortened_url + '1')

      expect(response).to have_http_status(404)
    end
  end

  describe '#create' do
    it 'creates a url for an anonymous user' do
      allow_any_instance_of(ShortenedPathsService).to receive(:lookup).and_return('abcdefg')
      post urls_path, headers: headers, params: { url: 'https://google.com' }.to_json
      expect(response).to have_http_status(201)
      expect(json.dig('url', 'url')).to eq('https://google.com')
      expect(json.dig('url', 'shortened_url')).to eq('abcdefg')
      expect(Url.first.url).to eq('https://google.com')
      expect(Url.first.shortened_url).to eq('abcdefg')
      expect(Url.first.user_id).to be(nil)
    end

    it 'does not create create a url with invalid data' do
      allow_any_instance_of(ShortenedPathsService).to receive(:lookup).and_return('abcdefg')
      expect do
        post urls_path, headers: headers, params: { url: '' }.to_json
        expect(response).to have_http_status(422)
      end.not_to change(Url, :count)
    end

    it 'creates a url for a current user' do
      allow_any_instance_of(ShortenedPathsService).to receive(:lookup).and_return('abcdefg')
      post login_path, headers: headers, params: { email: user.email, password: 'password' }.to_json
      full_headers = headers.merge('X-CSRF-Token' => response.cookies['CSRF-TOKEN'])
      post urls_path, headers: full_headers, params: { url: 'https://google.com' }.to_json
      expect(response).to have_http_status(201)
      expect(json.dig('url', 'url')).to eq('https://google.com')
      expect(json.dig('url', 'shortened_url')).to eq('abcdefg')
      expect(Url.first.url).to eq('https://google.com')
      expect(Url.first.shortened_url).to eq('abcdefg')
      expect(Url.first.user_id).to be(user.id)
    end
  end

  describe '#index' do
    it 'fails with authorization error for anonymous users' do
      get urls_path, headers: headers
      expect(response).to have_http_status(401)
    end
  end

  describe '#destroy' do
    it 'destroys a url for a current user' do
      post login_path, headers: headers, params: { email: user.email, password: 'password' }.to_json
      full_headers = headers.merge('X-CSRF-Token' => response.cookies['CSRF-TOKEN'])
      instance = user_url
      expect do
        delete url_path(instance.shortened_url), headers: full_headers
        expect(response).to have_http_status(200)
      end.to change(Url, :count).by(-1)
    end

    it 'does not destroy urls which do not belong to the user' do
      post login_path, headers: headers, params: { email: user.email, password: 'password' }.to_json
      full_headers = headers.merge('X-CSRF-Token' => response.cookies['CSRF-TOKEN'])
      [another_user_url, url]
      expect do
        delete url_path(another_user_url.shortened_url), headers: full_headers
        expect(response).to have_http_status(404)
      end.to_not change(Url, :count)
      expect do
        delete url_path(url.shortened_url), headers: full_headers
        expect(response).to have_http_status(404)
      end.to_not change(Url, :count)
    end

    it 'fails with authorization error for anonymous users' do
      delete url_path(url.shortened_url), headers: headers
      expect(response).to have_http_status(401)
    end
  end
end

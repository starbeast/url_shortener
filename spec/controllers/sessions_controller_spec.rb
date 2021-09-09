# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  let(:headers) do
    { 'CONTENT-TYPE' => 'application/json' }
  end
  let(:user) { create(:user, password_hash: BCrypt::Password.create('password')) }

  describe '#signup' do
    it 'creates a user' do
      expect {
        post signup_path, headers: headers, params: { email: 'test@mail.com', password: 'password' }.to_json
        expect(response).to have_http_status(200)
      }.to change(User, :count).by(1)
    end

    it 'does not create a user with the email of another one' do
      post signup_path, headers: headers, params: { email: user.email, password: 'password' }.to_json
      expect(response).to have_http_status(422)
      expect(User.count).to be(1)
    end

    it 'does not create a user with empty password' do
      post signup_path, headers: headers, params: { email: 'test@mail.com', password: '' }.to_json
      expect(response).to have_http_status(422)
      expect(User.count).to be(0)
    end
  end

  describe '#login' do
    it 'logs in with valid credentials' do
      post login_path, headers: headers, params: { email: user.email, password: 'password' }.to_json
      expect(response).to have_http_status(200)
      expect(request.session[:user_id]).to eq(user.id)
      expect(request.session[:_csrf_token]).not_to be_empty
    end

    it 'does not login with invalid credentials' do
      post login_path, headers: headers, params: { email: user.email, password: 'pass' }.to_json
      expect(response).to have_http_status(401)
      expect(request.session.keys).to eq([])
    end
  end

  describe '#logout' do
    it 'logs user out' do
      post login_path, headers: headers, params: { email: user.email, password: 'password' }.to_json
      expect(request.session[:user_id]).to eq(user.id)
      get logout_path, headers: headers
      expect(response).to have_http_status(200)
      expect(request.session.keys).not_to include('user_id', '_csrf_token')
    end
  end
end

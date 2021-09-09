# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  describe 'validations' do
    describe 'does no allow to create an api token with empty attributes' do
      let(:user) { create(:user) }
      let(:api_token) { build(:api_token, user: user) }

      %i[alias user token expires_at].each do |attribute|
        it "fails to create an api token with empty #{attribute}" do
          api_token.public_send(:"#{attribute}=", nil)
          api_token.save
          expect(api_token.persisted?).to eq(false)
          expect(api_token.errors.messages.keys).to eq([attribute])
        end
      end
    end
  end

  describe 'creation' do
    let(:user) { create(:user) }

    it 'has access to an original raw token after creation' do
      token = ApiToken.generate(user_id: user.id, alias: 'test')
      expect(token.persisted?).to be(true)
      expect(token.raw_token).not_to be_empty
      expect(ApiToken.lookup(token.raw_token).id).to eq(token.id)
    end
  end
end

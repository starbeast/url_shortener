# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    describe 'does not allow to create a user with empty email' do
      let(:user_with_empty_email) { build(:user, email: nil) }

      it 'fails to create a user' do
        user_with_empty_email.save
        expect(user_with_empty_email.persisted?).to be(false)
        expect(user_with_empty_email.errors.messages.keys).to eq([:email])
      end
    end

    describe 'does not allow to create a duplicated user' do
      let!(:user) { create(:user) }
      let(:another_user) { create(:user, email: user.email) }

      it 'fails to create a duplicate' do
        expect { another_user }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end

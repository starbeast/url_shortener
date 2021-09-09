# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Url, type: :model do
  describe 'validations' do
    describe 'does not allow to create a url with a duplicated shortened path' do
      let!(:url) { create(:url) }
      let(:url2) { create(:url, shortened_url: url.shortened_url) }

      it 'fails to create a url' do
        expect { url2 }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'does not allow to create a url with empty fields' do
      let(:url) { build(:url) }

      %i[url shortened_url].each do |attribute|
        it "fails to create a url with empty #{attribute}" do
          url.public_send(:"#{attribute}=", nil)
          url.save
          expect(url.persisted?).to eq(false)
          expect(url.errors.messages.keys).to eq([attribute])
        end
      end
    end
  end
end

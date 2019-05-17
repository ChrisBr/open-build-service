require 'browser_helper'

RSpec.feature 'Bootstrap_User Contributions', type: :feature, js: true do
  let!(:user) { create(:confirmed_user) }

  context 'no contributions' do
    it 'shows 0' do
      visit user_show_path(user: user.login)

      expect(page).to have_text('0 contributions')
    end
  end
end

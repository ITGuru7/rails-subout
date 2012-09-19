module WorldExt
  module UsersHelper
    def sign_in(user)
      visit new_user_session_path

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Sign in"

      page.should have_content("Sign out")
    end
  end
end

World(WorldExt::UsersHelper, ActionController::RecordIdentifier)

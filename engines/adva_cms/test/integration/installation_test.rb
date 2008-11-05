require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class InstallationTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  def test_a_user_goes_through_site_install_process
    install_initial_site!
    update_initial_password!
    manage_new_site!
    log_out_and_view_empty_frontend!
  end
  
  def install_initial_site!
    # go to root page
    get "/"

    # user should see the install template
    assert_template "admin/install/index"

    # fill in the form and submit the form
    fills_in "website name",  :with => "adva-cms Test"
    fills_in "website title", :with => "adva-cms Testsite"
    fills_in "title",         :with => "Home"
    clicks_button "Create"

    # check that a new site is created
    assert_equal 1, Site.count
    site = Site.first
    assert_not_nil site

    # check that root section is created
    assert_equal 1, site.sections.count
    assert_equal "Home", site.sections.first.title

    # check that admin account is created and verified
    assert_equal 1, User.count
    admin = User.first
    assert_not_nil admin
    assert admin.verified?

    # check that the system authenticates the user
    assert_equal admin, controller.current_user

    # check that the system authenticates the user as a superuser
    assert admin.has_role?(:superuser)
  end
  
  def update_initial_password!
    # go to the user profile page
    clicks_link "Change your password right now"

    # update the password and save
    fills_in "password", :with => 'updated password'
    clicks_button "Save"
  end
  
  def manage_new_site!
    # go to admin main page
    get admin_site_path(Site.first)

    # check that the user sees the site dashboard
    assert_template "admin/sites/show"
  end
  
  def log_out_and_view_empty_frontend!
    clicks_link "Logout"

    # check that the user sees the frontend
    assert_template "sections/show"
    
    #check that the frontend contains the site title
    assert response.body =~ /adva-cms Testsite/, "frontend should contain site title"
  end
end
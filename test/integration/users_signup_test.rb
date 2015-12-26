require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    @test_info = { name: 'Max Payne',
                   email: 'Max_Payne@example.com',
                   password: 'password',
                   password_confirmation: 'password' }
    @kylo = users(:kylo)
  end

  def assert_signup_successful(name = nil)
    assert_template 'users/show', 'Should be on profile page'

    assert_no_error_messages

    assert_flash type: 'success', expected: name ? "Welcome, #{name}!" : nil

    assert logged_in?, 'User should be logged in'
  end

  def assert_signup_failed(errors)
    assert_template 'users/new', 'Should be on signup page'

    unless errors[:flash]
      explanations = errors[:explanations].length
      noun = explanations == 1 ? 'error' : 'errors'
      errors[:flash] = "The form contains #{explanations} #{noun}."
    end

    assert_error_messages errors

    assert_not logged_in?, 'User should not be logged in'
  end

  test 'valid signup information is accepted' do
    name = 'Max Kanata'

    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: name,
                                            email: 'maz@example.com',
                                            password: 'password',
                                            password_confirmation: 'password',
                                            remember_me: '1' }
    end

    assert_signup_successful name
  end

  test 'post to create should ignore extra parameters' do
    name = 'Luke Skywalker'

    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: name,
                                            email: 'the_last_jedi@example.com',
                                            password: 'password',
                                            password_confirmation: 'password',
                                            id: 'so lonely :(' }
    end

    assert_signup_successful name
    # This tests user_params - the id field will be stripped out, and not cause
    # an error.  If it were not stripped out, an error would be raised because
    # ids are integers - not strings.
  end

  test 'should error on post with missing name' do
    assert_no_difference 'User.count' do
      post users_path, user: @test_info.merge(name: '')
    end
    assert_response 422, 'should error on missing name'
    assert_signup_failed highlights: ['input#user_name'],
                         explanations: ['Name can\'t be blank']
  end

  test 'should error on post with invalid email' do
    assert_no_difference 'User.count' do
      post users_path, user: @test_info.merge(email: '')
    end
    assert_response 422, 'should error on missing email'
    assert_signup_failed highlights: ['input#user_email'],
                         explanations: ['Email can\'t be blank',
                                        'Email is invalid']

    assert_no_difference 'User.count' do
      post users_path, user: @test_info.merge(email: 'i am not an email')
    end

    assert_response 422, 'should error on invalid email'
    assert_signup_failed highlights: ['input#user_email'],
                         explanations: ['Email is invalid']

    assert_no_difference 'User.count' do
      post users_path, user: @test_info.merge(email: @kylo.email)
    end
    assert_response 422, 'should error on already-taken email'
    assert_signup_failed highlights: ['input#user_email'],
                         flash: 'The form contains 1 error.',
                         explanations: ['Email has already been taken']
  end

  test 'should error on post with invalid password or confirmation' do
    post users_path, user: @test_info.merge(password: '',
                                            password_confirmation: '')
    assert_response 422, 'should error on missing password and confirmation'
    assert_select '.field_with_errors input#user_password', 1,
                  'should highlight password field'

    post users_path, user: @test_info.merge(password: 'short',
                                            password_confirmation: 'short')
    assert_response 422, 'should error on too-short password'
    assert_select '.field_with_errors input#user_password', 1,
                  'should highlight password field'

    post users_path, user:
                     @test_info.merge(password: 'longbutwrong',
                                      password_confirmation: 'wrongandlong')
    assert_response 422, 'should error on mismatched password and confirmation'
    assert_select '.field_with_errors input#user_password_confirmation', 1,
                  'should highlight password confirmation field'
  end
end

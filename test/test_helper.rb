ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical
    # order.
    fixtures :all
    include ApplicationHelper

    # Returns true if a test user is logged in.
    def logged_in?
      !session[:user_id].nil?
    end

    # Logs in a test user.
    def log_in_as(user, options = {})
      if integration_test?
        password    = options[:password] || 'password'
        remember_me = options[:remember_me] || '1'
        post login_path, session: { email:       user.email,
                                    password:    password,
                                    remember_me: remember_me }
      else
        session[:user_id] = user.id
      end
    end

    private

    # Returns true inside an integration test.
    def integration_test?
      defined?(post_via_redirect)
    end

    # assert that a flash message shows up in unit tests
    def assert_flash_unit(options)
      type = options[:type]
      expected = options[:expected]

      if expected.nil?
        assert flash[type] && flash[type] != '',
               "Should see a #{type} flash"
      else
        if expected
          assert_equal expected, flash[type],
                       "Should see a #{type} flash with '#{expected}'"
        else
          assert_not flash[type], "Should not see a #{type} flash"
        end
      end
    end

    # assert that a flash message shows up in integration tests
    def assert_flash_integration(options)
      type = options[:type]
      expected = options[:expected]

      selector = '.alert'
      selector += "-#{type}" if type
      message_object = type ? "#{type} flash" : 'flash'

      if expected.nil?
        message = "Should see a #{message_object}"
        assert_select selector, true, message
      else
        # rubocop:disable Style/MultilineTernaryOperator
        message = expected ?
          "Should see a #{message_object}, expecting: <#{expected}>" :
          "Should not see a #{message_object}"
        # rubocop:enable Style/MultilineTernaryOperator

        assert_select selector, expected, message
      end
    end

    # assert that a flash message shows up
    def assert_flash(options)
      if integration_test?
        assert_flash_integration options
      else
        assert_flash_unit options
      end
    end

    # assert that some input fields are highlighted
    def assert_highlights(highlights)
      highlights.each do |selector|
        assert_select ".field_with_errors #{selector}", 1,
                      "#{selector} should be highlighted"
      end
    end

    # assert that some error explanations exist
    def assert_explanations(explanations)
      explanations.each do |explanation|
        assert_select '#error_explanation li', explanation,
                      "Should see an explanation saying '#{explanation}'"
      end
    end

    # abstract wrapper for assert_flash, assert_highlights, and
    # assert_explanations
    def assert_error_messages(options)
      assert_highlights(options[:highlights]) if options[:highlights]

      assert_flash(type: 'danger', expected: options[:flash]) if options[:flash]

      assert_explanations(options[:explanations]) if options[:explanations]
    end
  end
end

require 'test_helper'

class CurrenciesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get currencies_index_url
    assert_response :success
  end

  test 'should get new' do
    get currencies_new_url
    assert_response :success
  end

  test 'should get create' do
    get currencies_create_url
    assert_response :success
  end

  test 'should get edit' do
    get currencies_edit_url
    assert_response :success
  end

  test 'should get update' do
    get currencies_update_url
    assert_response :success
  end

  test 'should get destroy' do
    get currencies_destroy_url
    assert_response :success
  end
end

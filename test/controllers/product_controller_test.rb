require 'test_helper'

class ProductControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get product_index_url
    assert_response :success
  end

  test 'should get show' do
    get product_show_url
    assert_response :success
  end

  test 'should get create' do
    get product_create_url
    assert_response :success
  end

  test 'should get edit' do
    get product_edit_url
    assert_response :success
  end

  test 'should get update' do
    get product_update_url
    assert_response :success
  end

  test 'should get delete' do
    get product_delete_url
    assert_response :success
  end
end

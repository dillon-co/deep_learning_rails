require 'test_helper'

class DigitRecognizersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @digit_recognizer = digit_recognizers(:one)
  end

  test "should get index" do
    get digit_recognizers_url
    assert_response :success
  end

  test "should get new" do
    get new_digit_recognizer_url
    assert_response :success
  end

  test "should create digit_recognizer" do
    assert_difference('DigitRecognizer.count') do
      post digit_recognizers_url, params: { digit_recognizer: {  } }
    end

    assert_redirected_to digit_recognizer_url(DigitRecognizer.last)
  end

  test "should show digit_recognizer" do
    get digit_recognizer_url(@digit_recognizer)
    assert_response :success
  end

  test "should get edit" do
    get edit_digit_recognizer_url(@digit_recognizer)
    assert_response :success
  end

  test "should update digit_recognizer" do
    patch digit_recognizer_url(@digit_recognizer), params: { digit_recognizer: {  } }
    assert_redirected_to digit_recognizer_url(@digit_recognizer)
  end

  test "should destroy digit_recognizer" do
    assert_difference('DigitRecognizer.count', -1) do
      delete digit_recognizer_url(@digit_recognizer)
    end

    assert_redirected_to digit_recognizers_url
  end
end

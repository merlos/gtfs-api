# The MIT License (MIT)
#
# Copyright (c) 2016 Juan M. Merlos, panatrans.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.



require 'test_helper'

=begin
module GtfsApi
  class FeedsControllerTest < ActionController::TestCase
    setup do
      @feed = feeds(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:feeds)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create feed" do
      assert_difference('Feed.count') do
        post :create, feed: { name: @feed.name, prefix: @feed.prefix, url: @feed.url, version: @feed.version }
      end

      assert_redirected_to feed_path(assigns(:feed))
    end

    test "should show feed" do
      get :show, id: @feed
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @feed
      assert_response :success
    end

    test "should update feed" do
      patch :update, id: @feed, feed: { name: @feed.name, prefix: @feed.prefix, url: @feed.url, version: @feed.version }
      assert_redirected_to feed_path(assigns(:feed))
    end

    test "should destroy feed" do
      assert_difference('Feed.count', -1) do
        delete :destroy, id: @feed
      end

      assert_redirected_to feeds_path
    end
  end
end

=end

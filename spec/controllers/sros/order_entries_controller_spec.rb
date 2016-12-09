require "rails_helper"

RSpec.describe Sros::OrderEntriesController, :type => :controller do
  describe "GET #index" do
    it "responds successfully with a HTTP 200 status code" do
      get :index
      expect(response).to be_success
    end
  end
end

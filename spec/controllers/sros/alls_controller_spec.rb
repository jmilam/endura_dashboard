require "rails_helper"

RSpec.describe Sros::AllsController, :type => :controller do
  describe "GET #index" do
    before(:each) do
      get :index
    end

    it "responds successfully" do
      build :report_criteria
      expect(response).to be_success
    end
    it "should have valid data in hash" do
      expect(assigns(:sro_summary).count).to be > 0
    end
  end
end

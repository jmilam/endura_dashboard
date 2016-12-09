require "rails_helper"

RSpec.describe Sro, :type => :model do
  describe "it should perform calculations" do
    it "should add" do
      expect(Sro.add(1,2)).to eq(3)
    end
  end
end

require 'spec_helper'

describe Company do
  it "should be a guest by default" do
    c = FactoryGirl.create(:company)
    c.should be_guest
  end
end


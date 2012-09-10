require 'spec_helper'

describe Company do
  it "should be a guest by default" do
    c = FactoryGirl.create(:company)
    expect(c).to be_guest
  end

  it "should generate company message path by default" do
    c = FactoryGirl.create(:company)
    expect(c.company_msg_path).not_to be_empty
  end
end


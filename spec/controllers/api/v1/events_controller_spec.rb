require 'spec_helper'

describe Api::V1::EventsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "GET 'index'" do
    it "responds recent events" do
      events = [3, 2, 1]

      Event.should_receive(:recent).and_return(events)

      get :index, api_token: user.authentication_token, format: 'json'

      result = parse_json(response.body)
      result.should == events
    end
  end
end

require 'spec_helper'

describe CompaniesController do
  describe 'GET dashboard' do
    before do
      sign_in_user
    end

    it 'should assign list of recent events' do
      events = [Event.new]
      Event.stub!(:recent).and_return(events)
      get 'dashboard'
      assigns(:events).should == events   
    end
  end
end

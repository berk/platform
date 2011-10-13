require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Platform::Application do
  describe '#creation' do

    before :all do 
      @user = User.create!(:first_name => "Mike")
      Platform::Config.init(@user)
    end
    
    context "creating new application" do
      it "should create unique hash key and secret" do
        app = Platform::Application.create(:name => 'Sample app')
        app.key.should_not be(nil)
        app.secret.should_not be(nil)
      end
      it "should be retriavable by id" do
        app1 = Platform::Application.create(:name => 'Sample app')
        app2 = Platform::Application.for(app1.id)
        app1.should == app2
      end
      it "should be retriavable by key" do
        app1 = Platform::Application.create(:name => 'Sample app')
        app2 = Platform::Application.for(app1.key)
        app1.should == app2
      end
      it "should be in a new state" do
        app1 = Platform::Application.create(:name => 'Sample app')
        app1.state.should == "new"
      end
    end

    context "changing application states" do
      it "should change states according to the state machine" do
        app = Platform::Application.create(:name => 'Sample app')
        app.submit!
        app.state.should == "submitted"
        app.approve!
        app.state.should == "approved"
        app.block!
        app.state.should == "blocked"
      end
      it "should fail if incorrect states are requested" do
        app = Platform::Application.create(:name => 'Sample app')
        app.submit!
        app.state.should == "submitted"
        app.deprecate!
        app.state.should == "submitted"
      end
    end
    
  end  
end

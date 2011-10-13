require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Platform::Developer do
  describe '#creation' do

    before :all do 
      @user = User.create!(:first_name => "Mike")
      Platform::Config.init(@user)
    end
    
    context "find_or_create developer" do
      it "should create a developer first and then return the same developer" do
        developer1 = Platform::Developer.find_or_create(@user)
        developer1.should_not be(nil)
        developer2 = Platform::Developer.find_or_create(@user)
        developer1.should == developer2
        developer3 = Platform::Developer.for(@user)
        developer3.should == developer2
      end
    end
    
  end  
end

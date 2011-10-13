require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Platform::Config do
  subject { Platform::Config }
  describe 'configuration' do
    context 'by default' do
      its(:current_user) {should be(nil)}
    end
  end
end

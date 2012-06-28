#--
# Copyright (c) 2011 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Platform::Oauth::OauthModelMethods

  def self.included(base)
    base.has_many :access_tokens, :class_name => "Platform::Oauth::AccessToken", :dependent => :destroy
    base.has_many :request_tokens, :class_name => "Platform::Oauth::RequestToken", :dependent => :destroy
    base.has_many :refresh_tokens, :class_name => "Platform::Oauth::RefreshToken", :dependent => :destroy
  end

  def authorized_oauth_access_tokens
    self.access_tokens.select{|t| t.authorized_at}
  end

  def access_token_for(application)
    return unless application
    access_tokens.detect{|t| t.application_id == application.id}
  end

end

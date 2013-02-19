#--
# Copyright (c) 2011 Michael Berkovich
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

class Platform::Oauth::AccessToken < Platform::Oauth::OauthToken
  validates_presence_of :user_id 
  
  before_create :set_authorized_at

  def to_json(options={})
    hash = {:access_token => token}
    hash[:expires_in] = valid_to.to_i - Time.now.to_i
    hash.to_json(options)
  end

protected

  def set_authorized_at
    self.authorized_at = Time.now
  end

  # Ticket 19802
  before_create :set_valid_to
  def set_valid_to
    self.valid_to ||= Time.now + lifetime
  end

  def lifetime
    @lifetime ||= Registry.api.token_lifetime
  end

end

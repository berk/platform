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

module Platform
  module RandomPasswordGenerator
  
    VOWELS = ['a', 'e', 'i', 'u'] unless defined?(VOWELS)
    CONSONANTS =  ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z'] unless defined?(CONSONANTS)
    DIGITS = ['2', '3', '4', '5', '6', '7', '8', '9'] unless defined?(DIGITS)
  
    def random_password(alpha=6, numeric=2)
      RandomPasswordGenerator.random_password(alpha, numeric)
    end
    
    def self.a_part(slen)
      ret = ''
      for i in 0...slen
        if i % 2 == 0
          randid = rand(CONSONANTS.length)
          ret = ret + CONSONANTS[randid]
        else
          randid = rand(VOWELS.length)
          ret = ret + VOWELS[randid]
        end
      end # for
      return ret
    end # def a_part
  
    def self.n_part(slen)
      ret = ''
      for i in 0...slen
        randid = rand(DIGITS.length)
        ret = ret + DIGITS[randid]
      end # for
      return ret
    end # def n_part
    
    def self.random_password(alpha=6, numeric=2)
    
      fpl = alpha / 2
      if alpha % 2 != 0
        fpl = int(alpha / 2) + 1
      end
      lpl = alpha - fpl
    
      start = a_part(fpl)
      mid = n_part(numeric)
      tail = a_part(lpl)
    
      result = "%s%s%s" % [start, mid, tail]
      return result
    
    end
    
  end
end
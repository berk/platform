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
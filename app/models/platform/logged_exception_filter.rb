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

class Platform::LoggedExceptionFilter <  Platform::BaseFilter

  def default_order
    'created_at'
  end

  def default_criteria_key
    :exception_class
  end

  def date_condition
    date_criteria = definition[:created_at]
    return date_criteria.container.sql_condition if date_criteria and (date_criteria.validate == nil)
    nil
  end

  def default_filters
    [
      ["Exceptions Logged Today", "created_today"],
    ]
  end

  def default_filter_conditions(key)
    if (key=="created_today")
      @order      ='created_at'
      @order_type ='desc'
      return [:created_at, :is_on, Date.today]
    end
  end
  
  def default_filter_if_empty
    "created_today"
  end

end

module Enumerable
  def find_consecutive
    r = []
    started = false
    each do |a|
      if (yield a)
        started = true
        r << a
      else
        break if started
      end
    end
    r
  end
end
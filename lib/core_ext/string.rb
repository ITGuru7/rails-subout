class String
  def name_capitalize
    self.split.each {|s| s.capitalize!}.join(' ')
  end
end


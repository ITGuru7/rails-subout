class Hash
  def keep_keys(keys)
    output = Hash.new
    self.each do |k,v|
      output[k] = v if keys.include?(k)
    end
    output
  end
  def capitalize_value(k)
    self[k] = self[k].name_capitalize if self[k]
  end
  def downcase_value(k)
    self[k] = self[k].downcase if self[k]
  end
end  

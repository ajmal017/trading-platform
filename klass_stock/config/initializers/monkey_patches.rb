class Object
  def is_numeric?
    true if Float(self) rescue false
  end
end

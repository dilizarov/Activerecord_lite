class MassObject
  def self.set_attrs(*attributes)
    attributes.each do |attribute|
      
        define_method(attribute) do
          self.instance_variable_get("@#{attribute}")
        end
      
        define_method("#{attribute}=") do |val|
          self.instance_variable_set("@#{attribute}", val)
        end
      
    end
    
    @attributes = attributes
  end
   
  def self.attributes
    @attributes
  end
  
  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end
  
  def initialize(params = {})
    
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.attributes.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
  
end

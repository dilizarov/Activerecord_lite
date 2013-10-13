require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  
  extend Searchable
  extend Associatable
  
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    table = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{@table_name}
      SQL
      
    table.map! do |row|
      self.new(row)
    end  
    
    table
  end

  def self.find(id)
    item = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{@table_name}
      WHERE id = ?
      SQL
      
    item.map! do |row|
      self.new(row)
    end
    
    item.first
  end

  def save
    
    values = attribute_values
    
    if self.id == nil
      create
    else
      update
    end
  end

  def attribute_values
    self.class.attributes.map do |attribute|
      self.send(attribute)
    end
  end

  private

  def create
    
    values = attribute_values
    
    DBConnection.execute(<<-SQL, *values)
    INSERT INTO #{self.class.table_name}
    ( #{ self.class.attributes.join(',') } )
    VALUES ( #{ ( ['?'] * self.class.attributes.length ).join(',')  } ) 
    SQL
    
    self.id = DBConnection.last_insert_row_id

  end

  def update
    
    values = attribute_values[1..-1]
    
    attributes = self.class.attributes.dup
    attributes.delete(:id)
    
    attributes.map! { |attribute| "#{attribute} = ?" }   
    
    DBConnection.execute(<<-SQL, *values)
    UPDATE #{self.class.table_name}
    SET #{attributes.join(",")}
    WHERE id = #{self.id}
    SQL
    
  end

end

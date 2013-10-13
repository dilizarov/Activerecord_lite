require_relative './db_connection'

module Searchable
  
  def where(params)
    keys = params.keys
    keys.map! { |key| "#{key.to_s} = ?"}
    values = params.values
    
    results = DBConnection.execute(<<-SQL, *values)
      SELECT *
      FROM #{self.table_name}
      WHERE #{keys.join(' AND ')}
    SQL
    
    self.parse_all(results)
  end
end
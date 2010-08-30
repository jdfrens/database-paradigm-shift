class Author
  include MongoMapper::Document 
          
  key :first_name, String
  key :last_name, String
  key :suffix, String, :default => ""
  many :authorships
  timestamps!
end

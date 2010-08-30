class Authorship
  include MongoMapper::Document 
          
  key :author_id, ObjectId
  key :book_id, ObjectId
  key :rank, Integer
  timestamps!

  belongs_to :book
  belongs_to :author
end

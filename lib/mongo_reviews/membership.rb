class Membership
  include MongoMapper::EmbeddedDocument
  
  key :grouping_id, ObjectId
  belongs_to :grouping
  key :rank, Integer
end

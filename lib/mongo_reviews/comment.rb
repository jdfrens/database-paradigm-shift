class Comment
  include MongoMapper::Document
  
  key :kind, String
  key :content, String
  
  key :commentable_id, ObjectId
  key :commentable_type, String
  belongs_to :commentable, :polymorphic => true
  timestamps!
end
class Book
  include MongoMapper::Document

  key :title, String
  key :sortable_title, String
  key :kind, String
  key :year, Integer
  key :rating, Integer, :within => -5..5, :allow_nil => true
  key :genres, Array
  key :ownerships, Array
  many :readon_dates
  many :memberships
  many :external_identifiers
  many :comments, :as => :commentable, :class_name => 'Comment'
  many :authorships
  timestamps!
  
  before_validation :set_sortable_title
    
  private
  
  def set_sortable_title
    if self.sortable_title.blank?
      self.sortable_title = self.title
    end
    
    if self.sortable_title.match(/(The|A|An)\s+(.*)/)
      self.sortable_title = "#{$2}, #{$1}"
    end
  end
end

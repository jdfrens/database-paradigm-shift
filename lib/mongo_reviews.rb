require 'rubygems'

require 'mongo_mapper'

DATABASE = "reviews"
def connection
  @connection ||= Mongo::Connection.new('localhost')
end
MongoMapper.connection = connection
MongoMapper.database = DATABASE
def db
  @db ||= connection.db(DATABASE)
end

class Book
  include MongoMapper::Document

  key :title, String
  key :sortabletitle, String
  key :rating, Integer
  key :year, Integer
  key :genres, Array
  key :ownerships, Array
  key :membership_ids, Array
  key :read_dates, Array

  many :authorships
  many :external_identifiers
  many :reviews
  many :memberships, :in => :membership_ids
end

class ExternalIdentifier
  include MongoMapper::EmbeddedDocument
  
  key :kind, String
  key :value, String
end

class Review
  include MongoMapper::EmbeddedDocument
  
  key :kind, String
  key :content, String
end

class Author
  include MongoMapper::Document

  key :first_name, String
  key :last_name, String
  key :suffix, String

  many :authorships
  
  def full_name
    [first_name, last_name, suffix].compact.join(" ").strip
  end
end

class Authorship
  include MongoMapper::Document

  key :author_id, Mongo::ObjectID
  key :book_id, Mongo::ObjectID
  key :rank, Integer

  belongs_to :author
  belongs_to :book
end

class Compendium
  include MongoMapper::Document
  
  key :name, String
end

class Membership
  include MongoMapper::Document
  
  key :compendium_id, Mongo::ObjectID
  key :rank, Integer
  
  belongs_to :compendium
end

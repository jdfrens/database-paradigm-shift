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

Dir["#{File.dirname(__FILE__)}/mongo_reviews/*.rb"].each do |file|
  require file
end

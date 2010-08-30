# a series of books can be collected in a "Grouping"
# see Membership relationship
class Grouping
  include MongoMapper::Document

  key :name, String
end
class ExternalIdentifier
  include MongoMapper::EmbeddedDocument

  key :kind, String
  key :value, String
end
require 'active_record'

def ar_database(database)
  ActiveRecord::Base.establish_connection(
    :adapter => "postgresql",
    :database => database,
    :username => "jdfrens",
    :host => "localhost")
end

module Old
  class Book < ActiveRecord::Base
  end

  class Author < ActiveRecord::Base
  end

  class Collection < ActiveRecord::Base
  end
  
  class Genre < ActiveRecord::Base
  end
  
  class Authorship < ActiveRecord::Base
    set_table_name "writes"

    belongs_to :book, :foreign_key => "bookid"
    belongs_to :author, :foreign_key => "authorid"
  end
  
  class ReadDate < ActiveRecord::Base
    set_table_name "dates"
    
    belongs_to :book, :foreign_key => "bookid"
  end
  
  class ExternalIdentifier < ActiveRecord::Base
    self.inheritance_column = :_type_disabled
    set_table_name "externalidentifiers"
    
    belongs_to :book, :foreign_key => "bookid"
  end
  
  class Ownership < ActiveRecord::Base
    set_table_name "owns"
    
    belongs_to :book, :foreign_key => "bookid"
  end
  
  class Characterization < ActiveRecord::Base
    set_table_name "characterizedas"
    
    belongs_to :book, :foreign_key => "bookid"
    belongs_to :genre, :foreign_key => "genreid"
  end
  
  class Membership < ActiveRecord::Base
    set_table_name "collectedas"
    
    belongs_to :book, :foreign_key => "bookid"
    belongs_to :collection, :foreign_key => "collectionid"
  end
end

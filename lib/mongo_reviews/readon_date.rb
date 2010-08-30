class ReadonDate
  include MongoMapper::EmbeddedDocument
  include Comparable

  key :year, Integer
  key :month, Integer
  
  def self.parse(str)
    if str.match(/(\w+)\s+(\d+)/)
      ReadonDate.new(:month => month_parse($1), :year => $2)
    end
  end
  
  def self.month_parse(month)
    Date::MONTHNAMES.index(month)
  end
  
  def <=>(other)
    if self.year == other.year
      self.month <=> other.month
    else
      self.year <=> other.year
    end
  end
       
  def formatted
    Date::MONTHNAMES[month] + " " + year.to_s
  end
end

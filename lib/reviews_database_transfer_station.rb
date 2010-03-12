require 'rubygems'
require 'tzinfo'
require 'active_support/inflector'

require 'mongo_reviews'
require 'ar_books'

require 'utils'

class ReviewsDatabaseTranferStation
  def initialize(kind)
    ar_database(kind.pluralize)
    @media_genre = kind
  end
  
  def process()
    @books = process_basic_elements(Old::Book) do |the_old|
      Book.new(:title => the_old.title,
               :sortabletitle => the_old.sortabletitle,
               :review => the_old.review,
               :evaluation => the_old.evaluation,
               :rating => the_old.rating,
               :year => the_old.year)
    end
    each_book("adding media genre") do |book|
      book.genres << @media_genre
    end

    @authors = process_basic_elements(Old::Author) do |the_old|
      Author.new(:first_name => the_old.fname,
                 :last_name => the_old.lname,
                 :suffix => the_old.suffix)
    end

    @compendia = process_basic_elements(Old::Collection) do |the_old|
      Compendium.new(:name => the_old.name)
    end
  
    add_to_books(Old::ReadDate) do |book, old_read_date|
      book.read_dates << MongoMapper.time_class.parse(old_read_date.date.to_s)
    end
    
    add_to_books(Old::ExternalIdentifier) do |book, old_identifier|
      book.external_identifiers << 
        ExternalIdentifier.new(:kind => old_identifier["type"], 
                               :value => old_identifier.value)
    end

    add_to_books(Old::Ownership) do |book, old_ownership|
      book.ownerships << old_ownership["format"]
    end

    print "Old::Authorship"
    Old::Authorship.all.each do |the_old|
      book = @books[the_old.book.id]
      author = @authors[the_old.author.id]
      the_new = Authorship.new(:rank => the_old.rank)
      the_new.book = book
      the_new.author = author
      the_new.save!
      dot
    end
    blank_line

    print "Old::Membership"
    Old::Membership.all.each do |the_old|
      book = @books[the_old.book.id]
      compendium = @compendia[the_old.collection.id]
      membership = Membership.new(:rank => the_old.rank)
      membership.compendium = compendium
      book.memberships << membership
      book.save!
      dot
    end
    blank_line
  end
  
  private
  def each_book(message)
    print message
    Book.all.each do |book|
      yield book
      book.save!
      dot
    end
    blank_line
  end
  
  def process_basic_elements(model_class)
    hash = {}
    print model_class.name
    model_class.all.each do |element|
      new_element = yield element
      new_element.save!
      hash[element.id] = new_element
      dot
    end
    blank_line
    hash
  end

  def add_to_books(model_class)
    print model_class.name
    model_class.all.each do |the_old|
      book = @books[the_old.book.id]
      yield(book, the_old)
      book.save!
      dot
    end
    print "\n"
  end
end

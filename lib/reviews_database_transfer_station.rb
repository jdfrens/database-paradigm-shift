require 'rubygems'
require 'tzinfo'
require 'active_support/inflector'

require 'mongo_reviews'
require 'ar_books'

require 'utils'

class ReviewsDatabaseTranferStation
  def initialize(kind)
    ar_database(kind.pluralize)
    @media_kind = kind
  end
  
  def process()
    @books = process_basic_elements(Old::Book) do |the_old|
      book = Book.new(:title => the_old.title,
               :sortable_title => the_old.sortabletitle,
               :kind => @media_kind,
               :rating => convert_rating(the_old.rating),
               :year => the_old.year)
      unless the_old.review.blank?
        book.comments << Comment.new(:kind => "quick", :content => the_old.review)
      end
      unless the_old.evaluation.blank?
        book.comments << Comment.new(:kind => "long", :content => the_old.evaluation)
      end
      book.save!
      book
    end
    add_to_books(Old::Characterization) do |book, old_characterization|
      book.genres << old_characterization.genre.name
    end

    @authors = process_basic_elements(Old::Author) do |the_old|
      Author.new(:first_name => the_old.fname,
                 :last_name => the_old.lname,
                 :suffix => the_old.suffix)
    end

    @groupings = process_basic_elements(Old::Collection) do |the_old|
      Grouping.new(:name => the_old.name)
    end
  
    add_to_books(Old::ReadDate) do |book, old_read_date|
      date = old_read_date.date
      book.readon_dates << ReadonDate.new(:month => date.month, :year => date.year)
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
      grouping = @groupings[the_old.collection.id]
      membership = Membership.new(:rank => the_old.rank)
      membership.grouping = grouping
      book.memberships << membership
      book.save!
      dot
    end
    blank_line
  end
  
  private
  def convert_rating(rating)
    case rating
    when 0
      nil
    when 1
      -5
    when 2
      -4
    when 3
      -3
    when 4
      -2
    when 5
      -1
    when 6
      0
    when 7
      1
    when 8
      2
    when 9
      3
    when 10
      3
    when 11
      4
    when 12
      4
    when 13
      5
    end
  end
  
  def each_book(message)
    print message
    @books.each do |id, book|
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

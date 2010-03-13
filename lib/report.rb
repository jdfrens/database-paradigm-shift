require 'mongo_reviews'
require 'utils'

class Report
  def generate
    ["book", "movie", "tvshow"].each do |top_genre|
      header(top_genre)
      Book.all(:genres => top_genre, :order => "sortabletitle").each do |book|
        title(book)
        collections(book)
        authors(book)
        genres(book)
        external_identifiers(book)
      end
      blank_line
    end  
    timestamp
  end
  
  def textilize_identifier(identifier)
    case identifier.kind
    when "imdb"
      "\"IMDb\":http://www.imdb.com/title/#{identifier.value}"
    when "isbn"
      "\"ISBN\":http://books.google.com/books?as_isbn=#{identifier.value}"
    when "loc"
      "\"LoC\":http://lccn.loc.gov/#{identifier.value}"
    end
  end
  
  private
  def header(top_genre)
    puts "h1. #{top_genre.pluralize.capitalize}"
    blank_line
  end
  
  def title(book)
    ownership = ""
    if (book.ownerships.length > 0)
      ownership = " *"
    end
    puts "h2. #{book.title}#{ownership}"
    blank_line
  end
  
  def authors(book)
    return if book.authorships.length == 0
    authors_names = book.authorships.map do |authorship|
      authorship.author.full_name
    end
    puts "by #{authors_names.join(", ")}"
    blank_line
  end
  
  def collections(book)
    book.memberships.each do |membership|
      puts "Book ##{membership.rank} in #{membership.compendium.name}"
    end
    blank_line
  end
  
  def genres(book)
    genres = book.genres[1..-1]
    unless genres.empty?
      puts "*genres:* #{genres.join(", ")}"
      blank_line
    end
  end
  
  def external_identifiers(book)
    unless book.external_identifiers.empty?
      print "*external links*: "
      output = book.external_identifiers.map do |identifier|
        textilize_identifier(identifier)
      end.join(", ")
      puts output
      blank_line
    end
  end
  
  def timestamp
    blank_line
    puts "Generated at: #{Time.now.to_s}"
  end
end

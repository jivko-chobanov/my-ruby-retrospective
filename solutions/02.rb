class Collection
  include Enumerable

  attr_accessor :songs

  def initialize(songs = [])
    @songs = songs
  end

  def each(&block)
    @songs.each &block
  end

  def names
    @songs.map(&:name).uniq
  end

  def artists
    @songs.map(&:artist).uniq
  end

  def albums
    @songs.map(&:album).uniq
  end

  def self.parse(text)
    new_collection = Collection.new
    text.split("\n").select { |line| !line.empty? }.each_slice(3) do |song_data|
        new_collection.songs << Song.new(song_data)
      end
    new_collection
  end

  def filter(criteria)
    Collection.new @songs.select { |song| criteria.is_satisfied.(song) }
  end

  def adjoin(other_collection)
    Collection.new(@songs + other_collection.songs)
  end
end


class Criteria
  attr_accessor :is_satisfied

  def initialize(&is_satisfied)
    @is_satisfied = is_satisfied
  end

  def create(attribute_name, needle)
    @is_satisfied = ->(song) { needle == song.send(attribute_name) }
    self
  end

  def self.name(name)
    Criteria.new.create :name, name
  end

  def self.artist(artist)
    Criteria.new.create :artist, artist
  end

  def self.album(album)
    Criteria.new.create :album, album
  end

  def &(other)
    Criteria.new do |song|
      @is_satisfied.(song) and other.is_satisfied.(song)
    end
  end

  def |(other)
    Criteria.new do |song|
      @is_satisfied.(song) or other.is_satisfied.(song)
    end
  end

  def !
    Criteria.new { |song| !@is_satisfied.(song) }
  end
end


class Song
  attr_reader :name, :artist, :album

  def initialize( attributes )
    @name, @artist, @album = attributes
  end
end

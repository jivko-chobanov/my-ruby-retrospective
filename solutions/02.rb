module SongAttributes
  NAMES = [:name, :artist, :album]
end

class Song < Struct.new(*SongAttributes::NAMES)
  def self.parse(text)
    new *text.split("\n")
  end
end

class Collection
  include Enumerable

  attr_reader :songs

  def self.parse(text)
    new text.split("\n\n").map { |song_text| Song.parse(song_text) }
  end

  def initialize(songs)
    @songs = songs
  end

  # dynamically get SongAttributes::NAMES
    # song_attr_accessors = 
    #   Song.instance_methods - Struct.new(:anything).instance_methods
    # song_attributes = song_attr_accessors.select do |method_name|
    #   method_name.to_s[-1] != '='
    # end
  SongAttributes::NAMES.each do |attribute|
    define_method (attribute.to_s + 's') do
      @songs.map(&attribute).uniq
    end
  end

  def filter(criteria)
    Collection.new @songs.select { |song| criteria.matches? song }
  end
  
  def adjoin(other)
    Collection.new @songs | other.songs
  end

  def each(&block)
    @songs.each &block
  end
end

class Criteria
  class << self
    SongAttributes::NAMES.each do |attribute|
      define_method attribute do |value|
        new ->(song) { song.send(attribute) == value }
      end
    end
  end

  def initialize(condition)
    @condition = condition
  end

  def matches?(song)
    @condition.(song)
  end

  def |(other)
    Criteria.new ->(song) do
      matches?(song) or other.matches?(song)
    end
  end

  def &(other)
    Criteria.new ->(song) do
      matches?(song) and other.matches?(song)
    end
  end

  def !
    Criteria.new ->(song) { not matches?(song) }
  end
end

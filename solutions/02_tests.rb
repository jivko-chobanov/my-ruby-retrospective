require_relative 'solution.rb'
class Collection
  def to_s
    @songs.map(&:to_s)
  end
end

class TestTask2 < MiniTest::Unit::TestCase
  def test_collection
    collection = Collection.parse(TEXT_OF_1_SONG)
    collection_songs = collection.instance_variable_get :@songs
    songs = [Song.new("Fields of Gold", "Sting", "Ten Summoner's Tales")]

    assert_equal songs, collection_songs


    collection = Collection.parse(TEXT_OF_2_SONGS)
    collection_songs = collection.instance_variable_get :@songs
    songs = [Song.new("Fields of Gold", "Sting", "Ten Summoner's Tales"),
      Song.new("Mad About You", "Sting", "The Soul Cages"),
    ]

    assert_equal songs, collection_songs
  end

  def test_extraction_by_attribute
    collection = Collection.parse(TEXT_OF_3_SONGS)

    assert_equal ['Fields of Gold', 'Mad About You'], collection.names
    assert_equal ['Sting', 'Eva Cassidy'], collection.artists
    assert_equal ["Ten Summoner's Tales", 'The Soul Cages', 'Live at Blues Alley'], collection.albums
  end

  def test_criteria
    song = Song.new("Fields of Gold", "Sting", "Ten Summoner's Tales")
    assert Criteria.artist('Sting').matches? song
    refute Criteria.artist('').matches? song
  end

  def test_filter
    collection = Collection.parse(TEXT_OF_3_SONGS)

    assert_equal Collection.parse(TEXT_OF_2_SONGS_OF_STING).to_s,
      collection.filter(Criteria.artist 'Sting').to_s
  end

  def test_filter_combinations
    collection = Collection.parse(TEXT_OF_3_SONGS)

    assert_equal Collection.parse(TEXT_OF_1_SONG_STING_FIELDS).to_s,
      collection.filter(
        Criteria.artist('Sting') & Criteria.name('Fields of Gold')
      ).to_s

    assert_equal Collection.parse(TEXT_OF_3_SONGS).to_s,
      collection.filter(
        Criteria.artist('Sting') | Criteria.name('Fields of Gold')
      ).to_s

    assert_equal Collection.parse(TEXT_OF_1_SONG_EVA_FIELDS).to_s,
      collection.filter(
        !Criteria.artist('Sting')
      ).to_s
  end

  def test_adjoin
    collection_sting = Collection.parse(TEXT_OF_2_SONGS_OF_STING)
    collection_eva = Collection.parse(TEXT_OF_1_SONG_EVA_FIELDS)

    assert_equal Collection.parse(TEXT_OF_3_SONGS).to_s,
      collection_sting.adjoin(collection_eva).to_s
  end

  def test_enumerable
    collection = Collection.parse(TEXT_OF_3_SONGS)
    
    assert_equal collection.to_s, collection.map(&:to_s)
  end

  TEXT_OF_1_SONG = TEXT_OF_1_SONG_STING_FIELDS = "Fields of Gold
Sting
Ten Summoner's Tales"

  TEXT_OF_1_SONG_EVA_FIELDS = "Fields of Gold
Eva Cassidy
Live at Blues Alley"

  TEXT_OF_2_SONGS = TEXT_OF_2_SONGS_OF_STING = "Fields of Gold
Sting
Ten Summoner's Tales

Mad About You
Sting
The Soul Cages"

  TEXT_OF_3_SONGS = "Fields of Gold
Sting
Ten Summoner's Tales

Mad About You
Sting
The Soul Cages

Fields of Gold
Eva Cassidy
Live at Blues Alley"
end

__END__
Autumn Leaves
Eva Cassidy
Live at Blues Alley

Autumn Leaves
Bill Evans
Portrait in Jazz

Brain of J.F.K
Pearl Jam
Yield

Jeremy
Pearl Jam
Ten

Come Away With Me
Norah Johnes
One

Acknowledgment
John Coltrane
A Love Supreme

Ruby, My Dear
Thelonious Monk
Mysterioso"
end

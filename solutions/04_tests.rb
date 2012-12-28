require_relative 'solution.rb'
class Test4 < MiniTest::Unit::TestCase
  def test_validation_email
    assert Validations.email? 'zhizho91@gmail.com'
    refute Validations.email? 'nomail'

    assert Validations.email? 'yes@host.com'
    refute Validations.email? 'no$%^&@host.com'

    assert Validations.email? 'd_fdFFD_+.-ffwg456780@host.com'

    assert Validations.email? 'a' * 200 + '@host.com'
    refute Validations.email? 'a' * 201 + '@host.com'

    refute Validations.email? '@host.com'
    refute Validations.email? '_@host.com'
    refute Validations.email? '+dd@host.com'
    refute Validations.email? '-@host.com'
    refute Validations.email? '.@host.com'
  end

  def test_validation_hostname
    assert Validations.hostname? 'knizhen-pazar.net'
    refute Validations.hostname? 'aaa'

    assert Validations.hostname? 'knigi.knizhen-pazar.net'
    refute Validations.hostname? 'no.knigi.knizhen-pazar.net'
    refute Validations.hostname? '.knigi.knizhen-pazar.net'
    refute Validations.hostname? 'knigi.knizhen-pazar.'
    refute Validations.hostname? 'knigi..net'
    refute Validations.hostname? '$knigi.knizhen-pazar.net'
    refute Validations.hostname? 'knigi.$knizhen-pazar.net'
    
    refute Validations.hostname? 'k(nigi.knizhen-pazar.net'
    refute Validations.hostname? 'knigi.kn*izhen-pazar.net'
    assert Validations.hostname? 'Knizhen-pazar.net'
    assert Validations.hostname? '1knizhen-pazar.net'
    
    refute Validations.hostname? 'k' * 63 + '.net'
    assert Validations.hostname? 'k' * 62 + '.net'
    refute Validations.hostname? 's' * 30 + '.' + 'k' * 33 + '.net'
    assert Validations.hostname? 's' * 30 + '.' + 'k' * 32 + '.net'

    refute Validations.hostname? 'knigi-.knizhen-pazar.net'
    refute Validations.hostname? 'k-.knizhen-pazar.net'
    assert Validations.hostname? 'k.knizhen-pazar.net'
    
    refute Validations.hostname? 'knigi-.knizhen-pazar.n9t'
    refute Validations.hostname? 'knigi.knizhen-pazar.nett'
    assert Validations.hostname? 'k.knizhen-pazar.nEt'
    assert Validations.hostname? 'k.knizhen-pazar.bg'

    assert Validations.hostname? 'k.knizhen-pazar.bg.aA'
    refute Validations.hostname? 'knigi.knizhen-pazar.net.bbb'
    refute Validations.hostname? 'knigi.knizhen-pazar.net.9d'
    refute Validations.hostname? 'knigi.knizhen-pazar.net.a'
  end

  def test_phone
    assert Validations.phone? '0883 484637'
    assert Validations.phone? '+883 484637'
    assert Validations.phone? '0088 3484637'

    assert Validations.phone? '0883484637'
    assert Validations.phone? '0883,48(46-37'
    assert Validations.phone? '0883),48( 46,-37'
    refute Validations.phone? '0883 ,-484637'
    refute Validations.phone? '0883484637-'

    assert Validations.phone? '+359 88 121-212-12'
  end

  def test_ip_address
    assert Validations.ip_address? '0.2.3.4'
    assert Validations.ip_address? '10.20.30.40'
    assert Validations.ip_address? '100.200.113.114'
    
    refute Validations.ip_address? '1000.200.113.114'
    refute Validations.ip_address? '.200.113.114'
    refute Validations.ip_address? '100.200.113.'
    refute Validations.ip_address? '1.200.113'

    refute Validations.ip_address? '256.200.113.114'
    refute Validations.ip_address? '1.200.113.999'
  end

  def test_number
    assert Validations.number? '0' 
    refute Validations.number? '-'
    assert Validations.number? '100000000000'
    refute Validations.number? '01'
    assert Validations.number? '-10'
    assert Validations.number? '10.0'
    assert Validations.number? '10.23234234'
    refute Validations.number? '10.'
  end

  def test_integer
    assert Validations.integer? '0' 
    refute Validations.integer? '-'
    assert Validations.integer? '100000000000'
    refute Validations.integer? '01'
    assert Validations.integer? '-10'
    refute Validations.integer? '10.0'
    refute Validations.integer? '10.23234234'
    refute Validations.integer? '10.'
  end

  def test_date
    assert Validations.date? '0000-01-01'
    refute Validations.date? '0000-01'
    refute Validations.date? '0000-01-0a'
    refute Validations.date? '0000-99-01'
    refute Validations.date? '0000-01-99'
  end

  def test_time
    assert Validations.time? '00:00:00'
    assert Validations.time? '24:59:59'
    
    refute Validations.time? ':00:00'
    refute Validations.time? '25:00:00'
    refute Validations.time? '25:00:1'
    refute Validations.time? '25:1:11'
    refute Validations.time? '00:60:00'
    refute Validations.time? '00:00:60'
  end

  def test_date_time
    assert Validations.date_time? '0000-01-01 00:00:00'
    refute Validations.date_time? '0000-01-01  00:00:00'
    refute Validations.date_time? '0000-01-0100:00:00'
  end

  def filter(text)
    PrivacyFilter.new(text).filtered
  end

  def test_privacy_filter
    assert_equal 'aaaa', filter('aaaa')
    refute_equal 'bbbb', filter('aaaa')
    assert_equal 'sdfv [EMAIL]', filter('sdfv aaa@bbb.com')
    assert_equal 'kefve [PHONE]kkave', filter('kefve 0883484637kkave')
    assert_equal '[PHONE] [EMAIL]', filter('0883484637 aaa@bbb.com')
    assert_equal '[PHONE] a [PHONE]', filter('0883484637 a 08888888')
    assert_equal '[EMAIL]', filter('009-123456.+359123456@0123456.bg')

    with_flags = PrivacyFilter.new('+359 88 121-212-12 aaa')
    with_flags.preserve_phone_country_code = true
    assert_equal '+359 [FILTERED] aaa', with_flags.filtered
    
    with_flags = PrivacyFilter.new('+359 88 121-212-12 aaa 0883484637')
    with_flags.preserve_phone_country_code = true
    assert_equal '+359 [FILTERED] aaa [PHONE]', with_flags.filtered
  end
end 

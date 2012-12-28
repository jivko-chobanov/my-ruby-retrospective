module RegexpStrings
  def email
    '[[:alnum:]][A-Za-z0-9_+.-]{1,199}@(?<hostname>.*)'
  end

  alias email_without_hostname email
  alias email_without_username_part email

  def hostname
    anydomain = '[[:alnum:]](([0-9A-Za-z-]{1,60}[0-9a-zA-Z])?)|([0-9a-zA-Z])'
    "((?<subdomain>#{anydomain})[.])?
      (?<domain>#{anydomain})\.
      (?<tld>[A-Za-z]{2,3}(\.[A-Za-z]{2})?)"    
  end

  def phone
    '(?<prefix>
      (?<local>0[0-9]+)|
      (?<international>(00)|(\+)([1-9][0-9]{0,3}))
    )
    (?<main>[0-9]*(([ \)\(\-\,]){0,2}[0-9]+)+)'
  end

  alias phone_without_international phone

  def phone_local
    '(?<prefix>
      (?<local>0[1-9][0-9]*)
    )
    (?<main>[0-9]*(([ \)\(\-\,]){0,2}[0-9]+)+)'
  end

  def ip_address
    '(?<number1>(?<number>[0-9]|[1-9][0-9]{1,2}))\.
        (?<number2>\g<number>)\.
        (?<number3>\g<number>)\.
        (?<number4>\g<number>)'
  end

  def number
     "#{integer}
        (?<fraction>\.[0-9]+)?"
  end

  def integer
    '(?<integer>-?([0-9]|[1-9][0-9]+))'
  end

  def date
    '[0-9]{4}-
      (?<month>[0-9]{2})-
      (?<day>[0-9]{2})'
  end

  def time
    '(?<hours>[0-9]{2}):
      (?<minutes>[0-9]{2}):
      (?<seconds>[0-9]{2})'
  end

  def date_time
    '(?<date>.+)\ (?<time>.+)'
  end
end

module AdditionalChecks
  def check_email
    Validations.hostname? @extracted['hostname']
  end

  def check_hostname
    if @extracted['subdomain'] then
      (@extracted['domain'] + @extracted['subdomain']).size < 63
    else
      true
    end
  end

   def check_ip_address
    1.upto(4).inject(true) do |a, b|
      group_name = ('number' + b.to_s)
      a and @extracted[group_name].to_i < 256
    end
  end

  def check_date
    @extracted['month'].to_i.between?(1, 12) and
    @extracted['day'].to_i.between?(1, 31)
  end

  def check_time
    @extracted['hours'].to_i.between?(0, 24) and
    @extracted['minutes'].to_i.between?(0, 59) and
    @extracted['seconds'].to_i.between?(0, 59)
  end

  def check_date_time
    Validations.date? @extracted['date'] and
    Validations.time? @extracted['time']
  end
end

class Filter
  include RegexpStrings
  include AdditionalChecks

  def initialize(type)
    @type = type
    @extracted = {}
  end

  def exact_match(text)
    /^#{regexp_string}$/x.match text
    @extracted = $~
    not @extracted.to_a.empty?    
  end

  def regexp_string
    send @type.to_sym
  end

  def check
    check_method = ('check_' + @type).to_sym
    if respond_to? check_method then send check_method else true end
  end
end

class PrivacyFilter
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname,:partially_preserve_email_username

  def initialize(text)
    @text = text
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially_preserve_email_username = false
  end

  def get_types_and_replacements
    types_and_replacements = {}
    if @preserve_phone_country_code
      types_and_replacements[:phone_without_international] = '\k<international> [FILTERED]'
      types_and_replacements[:phone_local] = '[PHONE]'
      types_and_replacements[:email] = '[EMAIL]'
    end

    if @preserve_email_hostname
      types_and_replacements[:email_without_hostname] = '\k<hostname>[FILTERED]'
      types_and_replacements[:phone] = '[PHONE]'
    end

    if @partially_preserve_email_username
      types_and_replacements[:email_without_username_part] = '[FILTERED]'
      types_and_replacements[:phone] = '[PHONE]'
    end

    if types_and_replacements.empty?
      types_and_replacements.update email: '[EMAIL]', phone: '[PHONE]'
    end
    types_and_replacements
  end

  def filtered
    types_and_replacements = get_types_and_replacements

    filtered_text = @text
    types_and_replacements.each do |type, replacement|
      filter = Filter.new type.to_s
      filtered_text.gsub! /#{filter.regexp_string}/x, replacement
    end
    filtered_text
  end
end

class Validations
  class << self
    def is(type, text)
      filter = Filter.new type
      filter.exact_match text and filter.check
    end

    def email?(text)
      is('email', text)
    end

    def hostname?(text)
      is('hostname', text)
    end

    def phone?(text)
      is('phone', text)
    end

    def ip_address?(text)
      is('ip_address', text)
    end

    def number?(text)
      is('number', text)
    end

    def integer?(text)
      is('integer', text)
    end

    def date?(text)
      is('date', text)
    end

    def time?(text)
      is('time', text)
    end

    def date_time?(text)
      is('date_time', text)
    end
  end
end

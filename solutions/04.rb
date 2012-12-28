module Patterns
  DOMAIN_NAME = /[0-9a-zA-Z](?:[0-9A-Za-z-]{0,61}[0-9a-zA-Z])?/i
  TLD = /[a-zA-Z]{2,3}(?:\.[a-zA-Z]{2})?/i
  HOSTNAME = /(?:#{DOMAIN_NAME}\.)+#{TLD}/i
  EMAIL_USERNAME_FIRST_SYMBOL = /[0-9a-zA-Z]/
  EMAIL_USERNAME_NOT_FIRST_SYMBOL = /[A-Za-z0-9_+.-]/
  EMAIL = /\b
    #{EMAIL_USERNAME_FIRST_SYMBOL}
    #{EMAIL_USERNAME_NOT_FIRST_SYMBOL}{,200}
    @(?<hostname>#{HOSTNAME})\b/ix
  EMAIL_EXTRACTING_3_LETTERS_OF_USERNAME = /\b
    (?<username_3_letters>
      #{EMAIL_USERNAME_FIRST_SYMBOL}
      #{EMAIL_USERNAME_NOT_FIRST_SYMBOL}{2}
    )
    #{EMAIL_USERNAME_NOT_FIRST_SYMBOL}{3,197}
    @(?<hostname>#{HOSTNAME})\b/ix

  PHONE_DELIMITER = /[ ()-]{1,2}/
  PHONE_LOCAL = /(?<![0-9A-Za-z+])0(?!0)(?:#{PHONE_DELIMITER}?[0-9]+)+/
  PHONE_GLOBAL = /(?:00|\+)[0-9]{1,3}/
  PHONE_MAIN = /(?:#{PHONE_DELIMITER}?[0-9]){6,11}/
  PHONE_PREFIX = /(?:#{PHONE_LOCAL}|#{PHONE_GLOBAL})/
  PHONE_NUMBER = /#{PHONE_PREFIX}#{PHONE_MAIN}/
  PHONE_NUMBER_GLOBAL_ONLY = /(?<country_code>#{PHONE_GLOBAL})#{PHONE_MAIN}/

  IP_ADDRESS = /(\d+)\.(\d+)\.(\d+)\.(\d+)/

  INTEGER = /-?(?:0|[1-9][0-9]*)/
  NUMBER = /#{INTEGER}(?:\.[0-9]+)?/

  DATE = /\d{4}-(?<month>\d\d)-(?<day>\d\d)/
  TIME = /(?<hours>\d\d):(?<minutes>\d\d):(?<seconds>\d\d)/
end

class Validations
  class << self
    include Patterns
    
    METHOD_PATTERNS = {
      email?: EMAIL,
      hostname?: HOSTNAME,
      phone?: PHONE_NUMBER,
      number?: NUMBER,
      integer?: INTEGER,
    }

    METHOD_PATTERNS.each do |method_name, pattern|
      define_method method_name do |text|
        /\A#{pattern}\z/ =~ text
      end
    end

    def date_time?(text)
      if /\A(?<date>#{DATE})[ T](?<time>#{TIME})\z/ =~ text
        date?($~[:date]) and time?($~[:time])
      end
    end

    def time?(text)
      if /\A#{TIME}\z/ =~ text
        $~[:hours].to_i.between?(0,23) and
        $~[:minutes].to_i.between?(0,59) and
        $~[:seconds].to_i.between?(0,59)
      end
    end

    def date?(text)
      if /\A#{DATE}\z/ =~ text
        $~[:month].to_i.between?(1,12) and $~[:day].to_i.between?(1,31)
      end
    end

    def ip_address?(text)
      if /\A#{IP_ADDRESS}\z/ =~ text
        $~.captures.all? { |byte| byte.to_i.between?(0, 255) }
      end
    end
  end
end

class PrivacyFilter
  include Patterns

  attr_accessor :preserve_phone_country_code,
                :preserve_email_hostname,
                :partially_preserve_email_username

  def initialize(text)
    @text = text
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially_preserve_email_username = false
  end

  def filtered
    text = @text

    if @partially_preserve_email_username
      @preserve_email_hostname = true
      text.gsub!(EMAIL_EXTRACTING_3_LETTERS_OF_USERNAME, '\k<username_3_letters>[FILTERED]@\k<hostname>')
    end
    if @preserve_email_hostname
      text.gsub!(EMAIL, '[FILTERED]@\k<hostname>')
    end
    text.gsub!(EMAIL, "[EMAIL]")

    if @preserve_phone_country_code
      text.gsub!(PHONE_NUMBER_GLOBAL_ONLY, '\k<country_code> [FILTERED]')
    end
    text.gsub!(PHONE_NUMBER, "[PHONE]")
    text
  end
end

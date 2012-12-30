module Patterns
  DOMAIN_NAME = /[0-9a-zA-Z](?:[0-9A-Za-z-]{0,61}[0-9a-zA-Z])?/i
  TLD = /[a-zA-Z]{2,3}(?:\.[a-zA-Z]{2})?/i
  HOSTNAME = /(?:#{DOMAIN_NAME}\.)+#{TLD}/i
  EMAIL = /\b(?<username>[0-9a-zA-Z][\w+.-]{,200})@(?<hostname>#{HOSTNAME})\b/i

  PHONE_DELIMITER = /[ ()-]{1,2}/
  PHONE_LOCAL = /\b(?<![0-9A-Za-z+])0(?!0)(?:#{PHONE_DELIMITER}?\d+)+/
  PHONE_GLOBAL = /(?:\b00|\+)[1-9]\d{,2}/
  PHONE_MAIN = /(?:#{PHONE_DELIMITER}?\d){7,11}/
  PHONE_PREFIX = /(?:#{PHONE_LOCAL}|#{PHONE_GLOBAL})/
  PHONE_NUMBER = /#{PHONE_PREFIX}#{PHONE_MAIN}\b/

  IP_ADDRESS = /(\d+)\.(\d+)\.(\d+)\.(\d+)/

  INTEGER = /-?(?:0|[1-9]\d*)/
  NUMBER = /#{INTEGER}(?:\.\d+)?/

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
        !!(/\A#{pattern}\z/ =~ text)
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
  end

  def filtered
    filter_phones filter_emails(@text)
  end

  private

  def filter_emails(text)
    text.gsub EMAIL do
      hidden_email $~[:username], $~[:hostname]
    end
  end

  def hidden_email(username, hostname)
    if @preserve_email_hostname or @partially_preserve_email_username
      "#{hidden_username username}@#{hostname}"
    else
      "[EMAIL]"
    end
  end

  def hidden_username(username)
    if @partially_preserve_email_username and username.length > 5
      "#{username[0..2]}[FILTERED]"
    else
      "[FILTERED]"
    end
  end

  def filter_phones(text)
    text.gsub PHONE_NUMBER do
      hidden_phone $&
    end
  end

  def hidden_phone(phone_number)
    if @preserve_phone_country_code and /\A#{PHONE_GLOBAL}/ =~ phone_number
      "#{$&} [FILTERED]"
    else
      "[PHONE]"
    end
  end
end

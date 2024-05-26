#!/usr/bin/env ruby

require 'net/imap'
require 'logger'
require 'json'

LOGGER = Logger.new(File.expand_path('logs/run.log', __dir__), 'daily')
VALID_DOMAINS = File.read(File.expand_path('valid-domains.conf', __dir__)).split("\n")
GET_SERVER = File.dirname(File.expand_path(__FILE__)) << "/server.sh"
SERVER = JSON.parse(IO.popen(GET_SERVER).read.strip)

def login_to_imap
  imap = Net::IMAP.new(SERVER['host'], port: SERVER['port'], ssl: SERVER['ssl'])
  imap.login(SERVER['username'], SERVER['password'])
  imap
end

def process_messages(imap)
  imap.select('INBOX.spam')

  imap.search(['ALL']).each do |message_id|
    data = imap.fetch(message_id, 'BODY.PEEK[HEADER.FIELDS (From)]').first
    from = data.attr.values.first.strip
    
    if VALID_DOMAINS.any? {|domain| from.include?(domain)}
      LOGGER.info "Moving to Inbox: [#{message_id}] #{from}"
  
      imap.copy(message_id, 'Inbox')
      imap.store(message_id, '+FLAGS', [:Deleted])
    end
  end
end

def logout_from_imap(imap)
  imap.close
  imap.logout
  imap.disconnect
end

begin
  imap = login_to_imap
  process_messages(imap)
rescue => e
  LOGGER.error "Error encountered: #{e.message}"
  LOGGER.error e.backtrace.join("\n")
ensure
  logout_from_imap(imap)
end


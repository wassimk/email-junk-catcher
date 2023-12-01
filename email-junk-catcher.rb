#!/usr/bin/env ruby

require 'net/imap'
require 'logger'

begin
  LOGGER = Logger.new(File.expand_path('run.log', __dir__), 'daily')
  PASS = File.read(File.expand_path('.private', __dir__)).strip
  VALID_DOMAINS = File.read(File.expand_path('valid-emails.conf', __dir__)).split("\n")
  
  imap = Net::IMAP.new('secure.emailsrvr.com', port: 993, ssl: true)
  imap.login('wassim@metallaoui.com', PASS)

  imap.select('INBOX.spam')

  imap.search(['ALL']).each do |message_id|
    data = imap.fetch(message_id, 'BODY.PEEK[HEADER.FIELDS (From)]').first
    from = data.attr.values.first.strip
    
    if VALID_DOMAINS.any? {|valid_email| from.include?(valid_email)}
      LOGGER.info "Moving to Inbox: [#{message_id}] #{from}"
  
      imap.copy(message_id, 'Inbox')
      imap.store(message_id, '+FLAGS', [:Deleted])
    end
  end

  imap.close
  imap.logout
  imap.disconnect
rescue => e
  LOGGER.error "Error encountered: #{e.message}"
end

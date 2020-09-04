#!/usr/bin/env ruby

require 'logger'
logger = Logger.new('run.log', 'daily')
logger.debug "Started executing"

PASS = File.read(File.expand_path('.private', __dir__)).strip
VALID_EMAILS = File.read('valid-emails.conf').split("\n")

require 'net/imap'
imap = Net::IMAP.new('secure.emailsrvr.com', port: 993, ssl: true)
imap.login('wassim@metallaoui.com', PASS)

imap.select('INBOX.spam')

imap.search(['ALL']).each do |message_id|
  headers = imap.fetch(message_id, 'BODY.PEEK[HEADER.FIELDS (From Subject)]')[0].attr.values.first
  next unless VALID_EMAILS.any? { |from| headers =~ /#{from}/ }

  subject = headers.match(/Subject: (.*)/)[1] rescue nil
  logger.info "Moving to Inbox: [#{message_id}] #{subject}"

  imap.copy(message_id, 'Inbox')
  imap.store(message_id, '+FLAGS', [:Deleted])
end

imap.close
imap.logout
imap.disconnect

logger.debug "Done executing"

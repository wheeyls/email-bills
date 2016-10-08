require 'net/imap'
require 'mail'

class GmailChecker
  def initialize(user = '', pass = '', box = '')
    @user = user
    @pass = pass
    @mailbox = box
  end

  def start
    @imap = Net::IMAP.new 'imap.gmail.com', 993, true
    @imap.login(@user, @pass)
    @imap.select(@mailbox)
  end

  def get_all
    seq_ids = @imap.search('ALL')
    uids = @imap.fetch(seq_ids, 'UID').map { |item| item.attr['UID'] }

    existing = get_from_db(uids)
    existing_ids = existing.map(&:id)

    new_messages = get_from_server uids - existing_ids

    existing.concat new_messages
  end

  def get_from_db(uids)
    Message.where(uid: uids)
  end

  def get_from_server(uids)
    uids.map do |uid|
      items = @imap.fetch(uid, 'RFC822')
      item = items.present? && items.first.attr['RFC822']

      extract_and_build uid, item if item
    end
  end

  def self.assign_addresses(mail, m)
    mail.to && mail.to.each do |email|
      m.to_addresses.find_or_initialize_by email: email
    end

    mail.from && mail.from.each do |email|
      m.from_addresses.find_or_initialize_by email: email
    end

    mail.cc && mail.cc.each do |email|
      m.cc_addresses.find_or_initialize_by email: email
    end

    mail.bcc && mail.bcc.each do |email|
      m.bcc_addresses.find_or_initialize_by email: email
    end
  end

  def extract_and_build(uid, imap_message)
    mail = Mail.new imap_message

    parsed_body = GmailChecker.find_reply(mail)

    m = Message.new uid: uid,
                body: get_body(mail),
                parsed_body: parsed_body[0],
                received_date: mail.date,
                subject: mail.subject,
                message_id: mail.message_id,
                raw: mail.encoded

    GmailChecker.assign_addresses mail, m
    m.save!
    m
    rescue
      puts "fuck #{uid}"
  end

  def get_body(mail)
    GmailChecker.html_part(mail) || GmailChecker.plain_part(mail)
  end

  def self.plain_part(mail)
    mail.multipart? ?
      (mail.text_part ? mail.text_part.body.encoded : nil) :
      mail.body.encoded
  end

  def self.html_part(mail)
    mail.html_part ? mail.html_part.body.encoded : nil
  end

  def self.find_reply(email, body_text = GmailChecker.plain_part(email))
    from_name = /(Michael Wheeler|Bonnie Cheng)/
    from_email = /(mt.maui@gmail.com|rabbitbonnie@gmail.com)/
    message_id = email.message_id
    header = email.header.to_s

    rules = [
      [ 'Gmail', lambda { message_id =~ /.+gmail\.com>\z/},
        /^.*#{from_name}\s+<#{from_email}>\s*wrote:.*$/ ],
      [ 'Yahoo! Mail', lambda { message_id =~ /.+yahoo\.com>\z/},
        /^_+\nFrom: #{from_name} <#{from_email}>$/ ],
      [ 'Microsoft Live Mail/Hotmail', lambda { header =~ /<.+@(hotmail|live).com>/},
        /^Date:.+\nSubject:.+\nFrom: #{from_email}$/ ],
      [ 'Outlook Express', lambda { header =~ /Microsoft Outlook Express/ },
        /^----- Original Message -----$/ ],
      [ 'Outlook', lambda { header =~ /Microsoft Office Outlook/ },
        /^\s*_+\s*\nFrom: #{from_name}.*$/ ],

      [ 'Mail.app', lambda { header =~ /Apple Mail/ },
        /^On .+(AM|PM), #{from_name} wrote:.*$/ ],

      # Generic fallback
      [ nil, lambda { true }, /^.*#{from_email}.*$/ ]
    ]

    notes = body_text
    source = nil

    # Try to detect which email service/client sent this message
    rules.find do |r|
      if r[1].call
        # Try to extract the reply.  If we find it, save it and cancel the search.
        reply_match = body_text.match(r[2])
        if reply_match
          notes = body_text[0, reply_match.begin(0)]
          source = r[0]
          next true
        end
      end
    end

    [notes.strip, source]
  end
end

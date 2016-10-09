require 'net/imap'
require 'mail'

module EmailBills
  class GmailChecker
    def initialize(box = '', user = ENV['GMAIL_USER'], pass = ENV['GMAIL_PASSWORD'])
      @user = user
      @pass = pass
      @mailbox = box
    end

    def login
      return if @logged_in
      @imap = Net::IMAP.new 'imap.gmail.com', 993, true
      @imap.login(@user, @pass)
      @logged_in = true
    end

    def get_since(date, box = @mailbox)
      login
      @imap.select(box)
      seq_ids = @imap.search(['SINCE', date.strftime('%d-%b-%Y')])
      uids = @imap.fetch(seq_ids, 'UID').map { |item| item.attr['UID'] }

      get_from_server uids
    end

    def get_from_server(uids)
      uids.map do |uid|
        items = @imap.fetch(uid, 'RFC822')
        item = items.first.attr['RFC822'] if items && items.count > 0

        extract_and_build uid, item if item
      end
    end

    def extract_and_build(uid, imap_message)
      mail = Mail.new imap_message

      Message.new uid: uid,
                  body: get_body(mail),
                  received_date: mail.date,
                  subject: mail.subject,
                  message_id: mail.message_id,
                  raw: mail.encoded
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
  end
end

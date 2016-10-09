module EmailBills
  class Message
    attr_reader :uid, :body, :received_date, :subject, :message_id, :raw

    def initialize(uid:, body:, received_date:, subject:, message_id:, raw:)
      @uid = uid
      @body = body
      @received_date = received_date
      @subject = subject
      @message_id = message_id
      @raw = raw
    end
  end
end

require 'celluloid'

class Camaloon
  def self.currency
    @@currency
  end

  def self.currency=(v)
    @@currency = v
  end
end

Camaloon.currency = "eur"


$sent_emails = []

class Worker
  include Celluloid
  attr_reader :sent_emails

  def email(new_currency)
    prev = Camaloon.currency
    Camaloon.currency = new_currency
    # Do expensive work here
    new_cur = Camaloon.currency
    #puts "-"*11
    #puts "Thread #{Thread.current.object_id} is about to set currency #{new_cur}"
    $sent_emails << new_cur
    #puts "Thread #{Thread.current.object_id} finished setting currency #{new_cur}"
    Camaloon.currency = prev
  end
end


5.times.map do
  %w(eur gpb us chp).map do |curr|
    worker = Worker.new
    1000.times do
      worker.async.email(curr)
    end
  end
end

p $sent_emails.select{|x| x =="eur"}.size
p $sent_emails.select{|x| x =="gpb"}.size
p $sent_emails.select{|x| x =="us"}.size
p $sent_emails.select{|x| x =="chp"}.size

# Expected output: 5000 for each.

require 'celluloid'

class Camaloon
  def self.currency
    Thread.current[:_camaloon_currency] ||= "xxxx"
  end

  def self.currency=(v)
    Thread.current[:_camaloon_currency] = v
  end
end


$sent_emails = []

class Worker
  include Celluloid

  def initialize(curr)
    @curr = curr
  end

  def email(st)
    prev = Camaloon.currency
    Camaloon.currency = @curr
    # Do expensive work here
    new_cur = Camaloon.currency
    $sent_emails << new_cur
    Camaloon.currency = prev
  end
end


valid_currencies = %w(eur gpb us chp)

5.times.map do
  valid_currencies.map do |curr|
    worker = Worker.pool(args: curr)
  end
end.flatten.map{|x| 100.times.map { x.future.email(nil) }}.flatten.each(&:value)

p $sent_emails.select{|x| x =="eur"}.size
p $sent_emails.select{|x| x =="gpb"}.size
p $sent_emails.select{|x| x =="us"}.size
p $sent_emails.select{|x| x =="chp"}.size

# Expected output: 5000 for each.

class ThreadScheduler
  THREAD_STATUS_BAR    = 0
  THREAD_COMMUNICATION = 1

  class << self
    attr_accessor :status_bar, :communication, :cache
  end
  self.cache = Hash.new

  def self.start
    self.dispatch_status_bar
    self.dispatch_communication
  end

  def self.stop
    _stop(THREAD_STATUS_BAR)
    _stop(THREAD_COMMUNICATION)
    self.status_bar.join
    self.communication.join
    self.status_bar = nil
    self.communication = nil
  end

  def self.dispatch_status_bar
    _start(THREAD_STATUS_BAR)
    self.status_bar = Thread.new do
      json = {"initialize" => "status_bar"}.to_json
      execution_ret = mrb_eval("Context.start('main', 'PAX', '#{json}')")
    end
  end

  def self.dispatch_communication
    _start(THREAD_COMMUNICATION)
    self.communication = Thread.new do
      json = {"initialize" => "communication"}.to_json
      execution_ret = mrb_eval("Context.start('main', 'PAX', '#{json}')")
    end
  end

  def self.command(id, string)
    value = ThreadScheduler._command(id, string)
    if value != "cache"
      eval(value)
    else
      self.cache[id] ||= {}
      self.cache[id][string] ||= false
    end
  end

  def self.execute(id)
    self._execute(id) do |str|
      if DaFunk::PaymentChannel.client
        if str == "check"
          DaFunk::PaymentChannel.client.check(false).to_s
        else
          DaFunk::PaymentChannel.client.send(str).to_s
        end
      else
        "false"
      end
    end
  end

  def self.alive?(thread)
    check(thread) == :alive
  end

  def self.die?(thread)
    check(thread) == :dead
  end

  def self.check(thread)
    case thread
    when :status_bar
      _parse(_check(THREAD_STATUS_BAR))
    when :communication
      _parse(_check(THREAD_COMMUNICATION))
    else
      _parse(_check(THREAD_STATUS_BAR))
    end
  end

  def self._parse(status)
    case status
    when 0
      :dead
    when 1
      :alive
    when 2
      :alive
    when 3
      :alive
    else
      :dead
    end
  end
end


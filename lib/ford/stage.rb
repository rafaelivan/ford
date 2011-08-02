require 'logger'

module Ford
  
  #
  # Ford threads
  #
  @@threads = []
  def self.threads
    @@threads
  end
  
  #
  # Join all threads and wait them to finish
  #
  def self.join
    @@threads.each { |t| t.join }
  end

  #
  # The class Ford::Stage can be extended by each stage in a pipeline
  #
  # It has built-in structures and functions that helps building a pipeline
  #
  class Stage
    
    attr_accessor :config, :logger, :item
    
    #
    # Create a queue for each Stage subclass
    #
    @queue = Queue.new
    def self.queue
      @queue
    end
    def self.queue=queue
      @queue = queue
    end
    
    def self.inherited(subclass)
      subclass.queue = Queue.new
    end
    
    #
    # Fork this stage
    #
    # TODO
    
    #
    # Create a stage in thread mode
    #
    def self.init_stage(options = {})
      options = {
        :threads => 1
      }.merge(options)
      
      options[:threads].times do |tid|
        options = options.clone
        options[:thread_id] = tid
        
        # Create a new thread
        t = Thread.new {
          obj = nil
          begin
            obj = self.new(options)
            obj.run
          rescue Exception => exc
            obj.logger.fatal("\nFailed to execute the #{self.class}'s thread (#{tid})")
            obj.logger.fatal("was consuming: #{obj.item}")
            obj.logger.fatal("#{exc}\n#{exc.backtrace.join("\n")}")
          end
        }
        
        Ford.threads.push t
        
      end
      
    end
     
    #
    # Initialize the stage 
    #
    def initialize(options = {})
      data = {
        :debug => Ford.debug, # If true, logs messages during execution
        :log_to => STDOUT, # Logging path or IO instance
        :from_stage => self.class # Reference of the Stage that is used as data input (normally, itself). Will load items from its queue.
      }.merge(options)
      
      @config = Ford::Config.new(data) # instance configuration
      @logger = Logger.new(@config.log_to) # instance logger
      @logger.level = @config.debug ? Logger::DEBUG : Logger::INFO      
    end
    
    #
    # Run the stage
    #
    def run      
      while (@item = pop_item)
        start_consume_at = Time.now
        
        logger.debug("Consuming...(#{config.thread_id})")
        consume
        
        logger.debug("Consumed in #{Time.now - start_consume_at} seconds (#{config.thread_id})")
      end      
    end
    
    #
    # When using the default run, consume should be implemented.
    #
    def consume
      raise 'Must implement!'
    end
    
    #
    # Pop an item from the queue
    #
    def pop_item
      self.class.queue.pop
    end
    
    #
    # Enqueue an item in the stage's queue
    #
    def send_to(stage_class, item)
      stage_class.queue.push item
      logger.debug("Sent to #{stage_class}'s queue (#{config.thread_id})")
    end
    
    #
    # Enqueue an item in the current stage's queue
    #
    def send_back(item)
      self.class.queue.push item
      logger.debug("Sent back (#{config.thread_id})")
    end
    
  end
  
end
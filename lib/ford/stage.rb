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
    @@threads.each {|t| t.join}
  end

  #
  # The class Ford::Stage can be extended by each stage in a pipeline
  #
  # It has built-in structures and functions that helps building a pipeline
  #
  class Stage
    
    attr_accessor :config, :logger, :input
    
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
    # Create a stage in thread mode
    #
    def self.init_stage(options={})
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
            obj.logger.fatal("was consuming: #{obj.input}")
            obj.logger.fatal("#{exc}\n#{exc.backtrace.join("\n")}")
          end
        }
        
        Ford.threads.push t
        
      end
      
    end
    
    
    #
    # Initialize the stage 
    #
    def initialize(options={})
      data = {
        :debug => false, # If true, logs messages during execution
        :log_to => STDOUT, # Logging path or IO instance
        :input_stage => self.class # Reference to the input Stage (normally, itself). Will load objs from its queue.
      }.merge(options)
      
      @config = Ford::Config.new(data) # instance configuration
      @logger = Logger.new(@config.log_to) # instance logger
      @logger.level = @config.debug ? Logger::DEBUG : Logger::INFO      
    end
    
    #
    # Run the stage
    #
    def run      
      while (@input = pop_input)
        start_consume_at = Time.now
        
        logger.debug("Consuming...(#{config.thread_id})")
        consume_input
        
        logger.debug("Consumed in #{Time.now - start_consume_at} seconds (#{config.thread_id})")
      end      
    end
    
    #
    # When using the default run, consume_input should be implemented.
    #
    def consume_input
      raise 'Must implement!'
    end
    
    #
    # Pop an object from the input queue
    #
    def pop_input
      @config.input_stage.queue.pop
    end
    
    #
    # Enqueue an object in the stage's queue
    #
    def enqueue_to(stage_class, obj)
      stage_class.queue.push obj
      logger.debug("Enqueued into #{stage_class}'s queue (#{config.thread_id})")
    end
    
    #
    # Enqueue an object in the current stage's queue
    #
    def enqueue_back(obj)
      self.class.queue.push obj
      logger.debug("Enqueued back (#{config.thread_id})")
    end
    
  end
  
end
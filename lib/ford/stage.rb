require 'logger'

module Ford
  
  # Ford stages.
  @@stages = []
  def self.stages
    @@stages
  end
  
  #
  # Ford threads.
  #
  @@threads = []
  def self.threads
    @@threads
  end
  
  #
  # Waits all stages to finish.
  #
  def self.join
    
    if Ford.finishable?
      @@stages.each { |s| s.finishing_thread.join }
    else
      @@threads.each { |t| t.join }
    end
    
  end
  
  #
  # Checks if a given stage can finish itself.
  #
  # - stage: the stage asking to finish itself.
  #
  def self.can_finish? stage

    # Checks the pipeline stages in linear order.
    @@stages.each do |s|
      
      return true if stage == s
      return false if not s.has_finished?

    end

  end

  #
  # The class Ford::Stage can be extended by each stage in a pipeline
  #
  # It has built-in structures and functions that helps building a pipeline
  #
  class Stage
    
    attr_accessor :config, :logger, :item
    
    # The stage's queue.
    @queue = Queue.new
    def self.queue
      @queue
    end
    def self.queue=queue
      @queue = queue
    end
    
    # Indicates wether the stage has finished or not.
    @finished = false
    def self.finished
      @finished
    end
    def self.finished=finished
      @finished = finished
    end
    
    # The number of threads of the stage.
    @number_of_threads = 1
    def self.number_of_threads
      @number_of_threads
    end
    def self.number_of_threads=n
      @number_of_threads = n
    end
    
    # The thread responsible for finishing the stage.
    @finishing_thread = nil
    def self.finishing_thread
      @finishing_thread
    end
    def self.finishing_thread=finishing_thread
      @finishing_thread = finishing_thread
    end
    
    #
    # Sets some attributes of each inherited subclass.
    #
    def self.inherited(subclass)
      subclass.queue = Queue.new
      subclass.finished = false
    end
    
    #
    # Creates a stage in thread mode.
    #
    def self.init_stage(options = {})
      
      options = {
        :threads => 1
      }.merge(options)
      
      # Saves the number of threads of this stage.
      self.number_of_threads = options[:threads]
      
      # Creates as many threads as requested.
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
            obj.logger.fatal("#{exc}\n#{exc.backtrace.join('\n')}")
          end
        }
        
        Ford.threads.push t
        
      end
      
      # Creates a thread responsible for finishing the stage when all
      # working threads get blocked.
      self.finish_stage if Ford.finishable?
      
      Ford.stages.push self
      
    end
    
    #
    # Finishes the stage when all of its threads get blocked.
    #
    def self.finish_stage
      
      # If a finishable pipeline is being created, then it's necessary to create a 
      # finishing thread for each stage.
      self.finishing_thread = Thread.new {
      
        t = 2
        while true do
          
          # puts "#{self} - #{self.queue.num_waiting}/#{self.number_of_threads}"
          
          # Checks if all stage's threads are blocked.
          # Special stages that doesn't use the queue should explicitly tell Ford that they have finished.
          if self.has_finished? or self.number_of_threads == self.queue.num_waiting
          
            # Checks if the all previous stages are really finished before finishing this stage.
            if Ford.can_finish? self
              
              # The stage has finished.
              self.finished = true

              break
              
            end

          end

          sleep(t=[t*2,60].min)
          
        end
       
      }
       
    end
    
    #
    # Returns: true, if the stage has finished; false, otherwise.
    #
    def self.has_finished?
      self.finished
    end
    
    #
    # Fork this stage
    #
    # TODO
     
    #
    # Initializes the stage.
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
    # Runs the stage.
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
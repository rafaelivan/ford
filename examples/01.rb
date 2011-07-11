require 'rubygems'
require 'ford'

module MyPipeline
  
  class Stage1 < Ford::Stage
    
    # Override method run
    def run
      
      10.times do |i|
        enqueue_to Stage2, 'obj'
      end
      
    end
    
  end
  
  class Stage2 < Ford::Stage
    
    def consume_input
      sleep 1 # fake some processing
      puts @input
    end
    
  end
  
  def self.run
    MyPipeline::Stage1.init_stage(:threads => 1, :debug => true)
    MyPipeline::Stage2.init_stage(:threads => 3, :debug => true)
    
    Ford.join
  end
  
end

MyPipeline.run
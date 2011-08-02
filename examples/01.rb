require 'rubygems'
require 'ford'

module MyPipeline

  def self.run
    MyPipeline::Stage1.init_stage(:threads => 1, :debug => true)
    MyPipeline::Stage2.init_stage(:threads => 3, :debug => true)
    
    Ford.join
  end
  
  class Stage1 < Ford::Stage
    
    # Override method run
    def run
      
      50.times do |i|
        send_to Stage2, 'obj'
      end
      
    end
    
  end
  
  class Stage2 < Ford::Stage
    
    def consume
      sleep 1 # fake some processing
      puts @input
    end
    
  end
  
end

MyPipeline.run
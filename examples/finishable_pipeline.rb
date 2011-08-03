require 'rubygems'
require 'ford'

module FinishablePipeline

  def self.run
    Ford.finishable = true # We're creating a finishable pipeline.
    
    FinishablePipeline::Stage1.init_stage(:threads => 1)
    FinishablePipeline::Stage2.init_stage(:threads => 3)
    
    Ford.join
  end
  
  class Stage1 < Ford::Stage
    
    # Override method run
    def run
      
      10.times do |i|
        send_to Stage2, "obj #{i}"
      end
      
      # Special stages that don't use the queue should explicitly tell Ford that they have finished.
      Stage1.finished = true
      
    end
    
  end
  
  class Stage2 < Ford::Stage
    
    def consume
      sleep 1 # Fakes some processing.
      puts @item
    end
    
  end
  
end

FinishablePipeline.run
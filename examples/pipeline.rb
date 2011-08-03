require 'rubygems'
require 'ford'

module Pipeline

  def self.run
    Ford.debug = true # Default debugging behaviour.
    
    Pipeline::Stage1.init_stage(:threads => 1, :debug => false)
    Pipeline::Stage2.init_stage(:threads => 3)
    
    # Waits all threads to finish before finishing the program.
    Ford.join
  end
  
  class Stage1 < Ford::Stage
    
    # Override method run
    def run
      
      50.times do |i|
        send_to Stage2, "obj #{i}"
      end
      
    end
    
  end
  
  class Stage2 < Ford::Stage
    
    def consume
      sleep 1 # Fakes some processing.
      puts @item
    end
    
  end
  
end

Pipeline.run
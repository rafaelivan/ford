module Ford
  
  #
  # Default debugging flag.
  #
  @@debug = false
  def self.debug
    @@debug
  end
  def self.debug=debug
    @@debug = debug
  end
  
  #
  # Tells the pipeline will finish or not.
  #
  @@finishable = false
  def self.finishable?
    @@finishable
  end
  def self.finishable=finishable
    @@finishable = finishable
  end
  
  #
  # Default logger output. 
  # Any stage can override this configuration.
  #
  @@log_to = STDOUT
  def self.log_to
    @@log_to
  end
  def self.log_to=log_to
    @@log_to = log_to
  end
  
end

require 'ford/config'
require 'ford/stage'
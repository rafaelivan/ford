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
  
end

require 'ford/config'
require 'ford/stage'
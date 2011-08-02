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
  
end

require 'ford/config'
require 'ford/stage'
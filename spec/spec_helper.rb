require "json"
require "active_support/core_ext/hash/keys"
require "active_support/inflector"
require "rack/test"

require "olive_branch"

module Rails
  class VERSION
    MAJOR = 4
    MINOR = 2
    TINY = 4
    PRE = nil
  end
end

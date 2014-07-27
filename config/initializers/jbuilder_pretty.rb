require 'jbuilder'
require 'json'

class Jbuilder
  alias_method :_original_target, :target!

  def target!
    ::JSON.pretty_generate(@attributes)
  end
end


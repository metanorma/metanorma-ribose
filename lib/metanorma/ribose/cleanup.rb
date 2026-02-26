require "metanorma-generic"

module Metanorma
  module Ribose
    class Cleanup < Metanorma::Generic::Cleanup
      extend Forwardable
    end
  end
end

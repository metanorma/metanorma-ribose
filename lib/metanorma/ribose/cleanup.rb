require "metanorma-generic"

module Metanorma
  module Ribose
    class Cleanup < Metanorma::Generic::Cleanup
      extend Forwardable

      def_delegators :@converter, *delegator_methods
    end
  end
end

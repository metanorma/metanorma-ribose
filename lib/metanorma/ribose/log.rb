module Metanorma
  module Ribose
    class Converter
      RIBOSE_LOG_MESSAGES = {
        # rubocop:disable Naming/VariableNumber
        # No gem-specific log messages currently defined
      }.freeze
      # rubocop:enable Naming/VariableNumber

      def log_messages
        super.merge(RIBOSE_LOG_MESSAGES)
      end
    end
  end
end

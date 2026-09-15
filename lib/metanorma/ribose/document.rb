# frozen_string_literal: true

# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/ribose.rb).
module Metanorma
  module Ribose
  end
end


module Metanorma
  module Ribose::Document
    autoload :Metadata, "metanorma/ribose/document/metadata"
    autoload :Root, "metanorma/ribose/document/root"
  end
end

# Backwards-compat alias so external consumers that reference
# Metanorma::RiboseDocument keep resolving during the transition.
module Metanorma
  existing = defined?(Metanorma::RiboseDocument) && Metanorma::RiboseDocument
  if !existing.equal?(Metanorma::Ribose::Document)
    Metanorma.send(:remove_const, :RiboseDocument) if existing
    RiboseDocument = Metanorma::Ribose::Document
  end
end

if defined?(Metanorma::Registers::Setup.setup_ribose_register)
  Metanorma::Registers::Setup.setup_ribose_register
end

module Metanorma
  deprecate_constant :RiboseDocument
end

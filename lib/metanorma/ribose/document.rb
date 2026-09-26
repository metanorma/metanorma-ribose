# frozen_string_literal: true

# Ribose bibdata subclasses the ISO metadata models; the ISO document
# register must exist for parsing to resolve.
require "metanorma/iso/document"

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

require "metanorma-core"
require "metanorma/document"
require "metanorma/ribose/html"

# OCP adoption: ONE registration in the metanorma-core flavor table.
# Lazy: skip silently on resolutions without the flavor table.
if defined?(Metanorma::Core::Flavors)
  Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                      name: :ribose,
                                      gem: "metanorma-ribose",
                                      model_root: Metanorma::Ribose::Document::Root,
                                      processor: defined?(Metanorma::Ribose::Processor) ? Metanorma::Ribose::Processor : nil,
                                      pubid_module: nil,
                                      renderers: { html: Metanorma::Ribose::Html::Renderer },
                                    ))
end

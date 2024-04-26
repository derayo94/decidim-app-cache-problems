# frozen_string_literal: true

require "cell/partial"

module ProposalsExtend
  extend ActiveSupport::Concern

  included do
    def cache_hash
      hash = []
      hash << "decidim/proposals/highlighted_proposals_for_component"
      hash << proposals.cache_key_with_version
      hash << I18n.locale.to_s
      hash << RequestStore.store[:toggle_machine_translations].to_s
      hash.join(Decidim.cache_key_separator)
    end
  end
end

Decidim::Proposals::HighlightedProposalsForComponentCell.include ProposalsExtend

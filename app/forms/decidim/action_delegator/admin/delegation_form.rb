# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      # A form object used to create a Delegation
      #
      class DelegationForm < Form
        attribute :granter_id, Integer
        attribute :grantee_id, Integer
        attribute :setting, Setting

        validates :granter_id, presence: true
        validates :grantee_id, presence: true
        validates :setting, presence: true

        def granter
          User.find_by(id: granter_id)
        end

        def grantee
          User.find_by(id: grantee_id)
        end
      end
    end
  end
end

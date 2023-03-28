# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Verifications
      module DelegationsVerifier
        # This is an engine that authorizes users by sending them a code through an SMS.
        class Engine < ::Rails::Engine
          isolate_namespace Decidim::ActionDelegator::Verifications::DelegationsVerifier

          paths["db/migrate"] = nil
          paths["lib/tasks"] = nil

          routes do
            resource :authorizations, only: [:new, :create, :edit, :update, :destroy], as: :authorization do
              get :renew, on: :collection
            end

            root to: "authorizations#new"
          end
        end
      end
    end
  end
end

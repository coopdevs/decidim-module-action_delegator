# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # This is the engine that runs on the public interface of `ActionDelegator`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ActionDelegator::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :settings, only: [:index, :new, :create, :destroy] do
          resources :delegations, only: [:index, :new, :create, :destroy]
        end

        resources :consultations, param: :slug, only: [] do
          get :results, on: :member
          resources :exports, only: [:create], module: :consultations

          namespace :exports do
            resources :sum_of_weights, only: :create
          end

          namespace :results do
            resources :sum_of_weights, only: :index
          end
        end

        root to: "delegations#index"
      end

      initializer "decidim_action_delegator.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_action_delegator_manifest.js admin/decidim_action_delegator_manifest.css)
      end

      def load_seed
        nil
      end
    end
  end
end

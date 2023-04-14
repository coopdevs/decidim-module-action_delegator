# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # This is the engine that runs on the public interface of `ActionDelegator`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ActionDelegator::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :settings do
          resources :delegations, only: [:index, :new, :create, :destroy]
          resources :ponderations
          resources :participants
          resources :permissions, only: [:create]
        end

        resources :consultations, param: :slug, only: [] do
          get :results, on: :member
          get :weighted_results, on: :member
          resources :exports, only: :create, module: :consultations

          namespace :exports do
            resources :sum_of_weights, only: :create
          end
        end

        root to: "delegations#index"
      end

      initializer "decidim_admin_action_delegator.admin_user_menu" do
        Decidim.menu :admin_user_menu do |menu|
          menu.add_item :users,
                        I18n.t("menu.delegations", scope: "decidim.action_delegator.admin"), decidim_admin_action_delegator.settings_path,
                        active: is_active_link?(decidim_admin_action_delegator.settings_path),
                        if: allowed_to?(:index, :impersonatable_user)
        end
      end

      initializer "decidim_admin_action_delegator.admin_consultation_menu" do
        Decidim.menu :admin_consultation_menu do |menu|
          menu.remove_item :results_consultation
          is_results = is_active_link?(decidim_admin_consultations.results_consultation_path(current_consultation)) ||
                       is_active_link?(decidim_admin_action_delegator.results_consultation_path(current_consultation)) ||
                       is_active_link?(decidim_admin_action_delegator.weighted_results_consultation_path(current_consultation))
          params = {
            position: 1.2,
            active: is_results,
            if: allowed_to?(:read, :question)
          }
          params[:submenu] = { target_menu: :admin_delegation_results_submenu } if is_results
          menu.add_item :delegated_results,
                        I18n.t("results", scope: "decidim.admin.menu.consultations_submenu"),
                        decidim_admin_consultations.results_consultation_path(current_consultation),
                        params
        end
      end

      initializer "decidim_admin_action_delegator.admin_consultation_menu" do
        Decidim.menu :admin_delegation_results_submenu do |menu|
          menu.add_item :by_answer,
                        I18n.t("by_answer", scope: "decidim.action_delegator.admin.menu.consultations_submenu"),
                        decidim_admin_consultations.results_consultation_path(current_consultation),
                        position: 1.0,
                        active: is_active_link?(decidim_admin_consultations.results_consultation_path(current_consultation)),
                        if: allowed_to?(:read, :question)
          menu.add_item :by_type_and_weight,
                        I18n.t("by_type_and_weight", scope: "decidim.action_delegator.admin.menu.consultations_submenu"),
                        decidim_admin_action_delegator.results_consultation_path(current_consultation),
                        position: 1.1,
                        active: is_active_link?(decidim_admin_action_delegator.results_consultation_path(current_consultation), :exact),
                        if: allowed_to?(:read, :question)
          menu.add_item :sum_of_weights,
                        I18n.t("sum_of_weights", scope: "decidim.action_delegator.admin.menu.consultations_submenu"),
                        decidim_admin_action_delegator.weighted_results_consultation_path(current_consultation),
                        position: 1.2,
                        active: is_active_link?(decidim_admin_action_delegator.weighted_results_consultation_path(current_consultation)),
                        if: allowed_to?(:read, :question)
        end
      end

      def load_seed
        nil
      end
    end
  end
end

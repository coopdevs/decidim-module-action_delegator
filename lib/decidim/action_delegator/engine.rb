# frozen_string_literal: true

require "savon"
require "rails"
require "decidim/core"
require "decidim/consultations"

module Decidim
  module ActionDelegator
    # This is the engine that runs on the public interface of action_delegator.
    # Handles all the logic related to delegation except verifications
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ActionDelegator

      routes do
        # Add engine routes here
        authenticate(:user) do
          resources :user_delegations, controller: :user_delegations
          root to: "user_delegations#index"
        end
      end

      config.to_prepare do
        # override votes questions
        Decidim::Consultations::VoteQuestion.include(Decidim::ActionDelegator::Consultations::VoteQuestionOverride)
        Decidim::Consultations::MultipleVoteQuestion.include(Decidim::ActionDelegator::Consultations::MultipleVoteQuestionOverride)
        Decidim::Consultations::VoteForm.include(Decidim::ActionDelegator::Consultations::VoteFormOverride)
        Decidim::Consultations::MultiVoteForm.include(Decidim::ActionDelegator::Consultations::VoteFormOverride)
        Decidim::Consultations::Vote.include(Decidim::ActionDelegator::Consultations::VoteOverride)
      end

      initializer "decidim_action_delegator.overrides", after: "decidim.action_controller" do
        config.to_prepare do
          Decidim::Consultations::QuestionVotesController.include(Decidim::ActionDelegator::Consultations::QuestionVotesControllerOverride)
          Decidim::Consultations::QuestionsController.include(Decidim::ActionDelegator::Consultations::QuestionsControllerOverride)
          Decidim::Consultations::ConsultationsController.include(Decidim::ActionDelegator::Consultations::ConsultationsControllerOverride)
          Decidim::Consultations::QuestionMultipleVotesController.include(Decidim::ActionDelegator::Consultations::QuestionMultipleVotesControllerOverride)
          Decidim::Verifications::Sms::AuthorizationsController.include(Decidim::ActionDelegator::Verifications::Sms::AuthorizationsControllerOverride)
        end
      end

      initializer "decidim_action_delegator.permissions" do
        Decidim::Consultations::Permissions.prepend(ConsultationsPermissionsExtension)
      end

      initializer "decidim_action_delegator.webpacker.assets_path" do |_app|
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.item t("vote_delegations", scope: "layouts.decidim.user_profile"),
                    decidim_action_delegator.user_delegations_path,
                    position: 5.0,
                    active: :exact
        end
      end
    end
  end
end

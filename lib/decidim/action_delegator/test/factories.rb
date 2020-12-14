# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/consultations/test/factories"

FactoryBot.define do
  factory :delegation, class: "Decidim::ActionDelegator::Delegation" do
    setting
    granter { association :user, organization: setting.consultation.organization }
    grantee { association :user, organization: setting.consultation.organization }
  end

  factory :setting, class: "Decidim::ActionDelegator::Setting" do
    max_grants { 3 }
    consultation
  end
end

FactoryBot.modify do
  factory :authorization, class: "Decidim::Authorization" do
    trait :direct_verification do
      name { "direct_verifications" }
    end
  end
end

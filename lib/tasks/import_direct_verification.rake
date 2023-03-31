# frozen_string_literal: true

namespace :action_delegator do
  desc "Imports direct_verification existing authorizations into the participants table"
  task import_direct_verifications: :environment do
    Decidim::Organization.order(:id).find_each do |organization|
      puts "Processing organization [#{organization.name}]"
      settings = Decidim::ActionDelegator::OrganizationSettings.new(organization).query
      authorizations = Decidim::Authorization.where(name: "direct_verifications", user: organization.users)
      puts "Found #{authorizations.count} authorizations"
      count = 0
      authorizations.each do |authorization|
        weight = authorization.metadata["membership_weight"]
        type = authorization.metadata["membership_type"]
        phone = authorization.metadata["membership_phone"]
        email = authorization.user.email
        settings.find_each do |setting|
          ponderation = setting.ponderations.find_or_create_by!(weight: weight, name: (type.presence || "weight-#{weight}"))
          participant = setting.participants.find_or_create_by(
            ponderation: ponderation,
            phone: phone,
            email: email
          )
          if participant.persisted?
            puts "Imported authorization [#{authorization.id}] into participant [#{participant.email}] with ponderation [#{ponderation.title}]"
            count += 1
          end
        end
      end
      puts "Imported #{count} authorizations"
    end
  end
end

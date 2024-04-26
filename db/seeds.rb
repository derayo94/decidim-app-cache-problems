# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# You can remove the 'faker' gem if you don't want Decidim seeds.
def localized_hash(fr_text: "", nl_text: "", en_text: "")
  {
    fr: fr_text,
    nl: nl_text,
    en: en_text
  }
end

if !Rails.env.production? || ENV.fetch('SEED', nil)

  require 'decidim/faker/localized'

  PASSWORD = 'decidim123456789'
  SEEDS_ROOT = File.join(__dir__, 'seeds')

  puts 'Creating system admin user...'
  Decidim::System::Admin.find_or_initialize_by(email: 'system@example.org').update!(
    password: PASSWORD,
    password_confirmation: PASSWORD
  )

  puts 'Creating organization...'
  ORGANIZATION_NAME = 'Example City'
  organization = Decidim::Organization.find_or_initialize_by(
    name: ORGANIZATION_NAME,
    host: ENV.fetch('DECIDIM_HOST', 'localhost'),
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      localized_hash(
        fr_text: "Plateforme Decidim pour Example City !",
        nl_text: "Decidim-platform voor Example City!",
        en_text: "Decidim platform for Example City!")
    end,
    default_locale: :fr,
    available_locales: %i[fr nl en],
    reference_prefix: 'example-city',
    available_authorizations: Decidim.authorization_workflows.map(&:name),
    users_registration_mode: :enabled,
    tos_version: Time.current,
    badges_enabled: true,
    user_groups_enabled: true,
    send_welcome_notification: true,
    enable_machine_translations: true
  )

  Decidim::System::CreateDefaultPages.call(organization)
  Decidim::System::CreateDefaultContentBlocks.call(organization)
  Decidim::System::PopulateHelp.call(organization)

  hero_content_block = Decidim::ContentBlock.find_by(
    organization: organization,
    manifest_name: :hero,
    scope_name: :homepage
  )
  file_path = File.join(SEEDS_ROOT, 'homepage_image.jpg')
  hero_content_block.images_container.background_image.attach(
    io: File.open(file_path),
    filename: 'homepage_image.jpg',
    content_type: 'image/jpeg'
  )
  settings = {}
  welcome_text = localized_hash(
    fr_text: "Bienvenue sur Dummy City !",
    nl_text: "Welkom in Dummy City!",
    en_text: "Welcome to Dummy City!")
  settings = welcome_text.inject(settings) { |acc, (k, v)| acc.update("welcome_text_#{k}" => v) }
  hero_content_block.settings = settings
  hero_content_block.save!

  puts 'Creating admin user for organization...'
  admin = Decidim::User.find_or_initialize_by(email: 'admin@example.org')
  admin.update!(
    name: 'Admin',
    nickname: 'admin',
    password: PASSWORD,
    password_confirmation: PASSWORD,
    password_updated_at: Time.current,
    organization: organization,
    confirmed_at: Time.current,
    locale: :fr,
    admin: true,
    tos_agreement: true,
    accepted_tos_version: organization.tos_version,
    admin_terms_accepted_at: Time.current
  )

  puts('Creating regular users for organization...')
  regular_user = Decidim::User.find_or_initialize_by(email: 'user@example.org')
  regular_user.update!(
    name: 'John Smith',
    nickname: 'johnsmith',
    password: PASSWORD,
    password_confirmation: PASSWORD,
    confirmed_at: Time.current,
    locale: :fr,
    organization: organization,
    tos_agreement: true,
    personal_url: Faker::Internet.url,
    about: Faker::Lorem.paragraph(sentence_count: 2),
    accepted_tos_version: organization.tos_version
  )

  locked_user = Decidim::User.find_or_initialize_by(email: 'locked_user@example.org')
  locked_user.update!(
    name: 'Jane Doe',
    nickname: 'janedoe',
    password: PASSWORD,
    password_confirmation: PASSWORD,
    confirmed_at: Time.current,
    locale: :nl,
    organization: organization,
    tos_agreement: true,
    personal_url: Faker::Internet.url,
    about: Faker::Lorem.paragraph(sentence_count: 2),
    accepted_tos_version: organization.tos_version
  )
  locked_user.lock_access!

  puts('Creating an example process...')
  participatory_process = Decidim::ParticipatoryProcess.new(
    {
      organization: organization,
      title: localized_hash(
        fr_text: "Exemple de processus participatif",
        nl_text: "Voorbeeld van een participatief proces",
        en_text: "Example of participatory process"),
      subtitle: localized_hash(fr_text: "Exemple", nl_text: "Voorbeeld", en_text: "Example"),
      weight: 0,
      slug: "my-participatory-process-#{Time.zone.now.to_i}",
      description: localized_hash(
        fr_text: "Description de l'example",
        nl_text: "Beschrijving van het voorbeeld",
        en_text: "Description of the example"),
      short_description: localized_hash(fr_text: "Bref", nl_text: "Kort", en_text: "Brief"),
    }
  )
  participatory_process.save!
  participatory_process.publish!

  proposals_component = Decidim.traceability.create!(
    Decidim::Component,
    admin,
    manifest_name: 'proposals',
    name: localized_hash(fr_text: "Propositions", nl_text: "Voorstellen", en_text: "Proposals"),
    participatory_space: participatory_process,
    default_step_settings: {
      creation_enabled: true
    },
    step_settings: {}
  )
  proposals_component.publish!
end

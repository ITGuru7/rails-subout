# RailsAdmin config file. Generated on October 06, 2012 16:04
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  # I18n.default_locale = :de

  config.current_user_method { current_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, User

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, User

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['Subout', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }


  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [Bid, Company, Contact, Employee, Event, FavoriteInvitation, Location, Opportunity, OpportunityType, Profile, Region, RegionType, User]

  # Add models here if you want to go 'whitelist mode':
  # config.included_models = [Bid, Company, Contact, Employee, Event, FavoriteInvitation, Location, Opportunity, OpportunityType, Profile, Region, RegionType, User]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end

  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  # config.model Bid do
  #   # Found associations:
  #     configure :opportunity, :belongs_to_association 
  #     configure :bidder, :belongs_to_association 
  #     configure :event, :has_one_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :opportunity_id, :bson_object_id         # Hidden 
  #     configure :amount, :decimal 
  #     configure :bidder_id, :bson_object_id         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Company do
  #   # Found associations:
  #     configure :created_from_invitation, :belongs_to_association 
  #     configure :users, :has_many_association 
  #     configure :auctions, :has_many_association 
  #     configure :opportunities, :has_many_association 
  #     configure :contacts, :has_many_association 
  #     configure :locations, :has_many_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :name, :string 
  #     configure :email, :text 
  #     configure :street_address, :text 
  #     configure :zip_code, :text 
  #     configure :city, :text 
  #     configure :state, :text 
  #     configure :hq_location_id, :text 
  #     configure :active, :boolean 
  #     configure :company_msg_path, :text 
  #     configure :member, :boolean 
  #     configure :favorite_supplier_ids, :serialized 
  #     configure :favoriting_buyer_ids, :serialized 
  #     configure :created_from_invitation_id, :bson_object_id         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Contact do
  #   # Found associations:
  #     configure :company, :belongs_to_association 
  #     configure :location, :has_one_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :company_id, :bson_object_id         # Hidden 
  #     configure :phone, :text 
  #     configure :phone2, :text 
  #     configure :twenty_four_hour_line, :text 
  #     configure :fax, :text 
  #     configure :contact_name, :text 
  #     configure :email1, :text 
  #     configure :email2, :text 
  #     configure :email3, :text 
  #     configure :location_id, :text         # Hidden 
  #     configure :quest, :text 
  #     configure :survey_result, :text   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Employee do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :company_id, :integer 
  #     configure :name, :string 
  #     configure :profile_id, :integer 
  #     configure :contact_id, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Event do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :description, :text 
  #     configure :model_id, :text 
  #     configure :model_type, :text 
  #     configure :company_id, :text   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model FavoriteInvitation do
  #   # Found associations:
  #     configure :buyer, :belongs_to_association 
  #     configure :supplier, :belongs_to_association 
  #     configure :created_company, :has_one_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :supplier_name, :text 
  #     configure :supplier_email, :text 
  #     configure :custom_message, :text 
  #     configure :token, :text 
  #     configure :accepted, :boolean 
  #     configure :buyer_id, :bson_object_id         # Hidden 
  #     configure :supplier_id, :bson_object_id         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Location do
  #   # Found associations:
  #     configure :company, :belongs_to_association 
  #     configure :contact, :belongs_to_association 
  #     configure :opportunity, :belongs_to_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :company_id, :bson_object_id         # Hidden 
  #     configure :contact_id, :bson_object_id         # Hidden 
  #     configure :street_number, :integer 
  #     configure :street_number_prefix, :text 
  #     configure :street_name, :text 
  #     configure :street_type, :text 
  #     configure :street_direction, :text 
  #     configure :address_type, :text 
  #     configure :address_type_identifier, :text 
  #     configure :minor_municipality, :text 
  #     configure :major_municipality, :text 
  #     configure :governing_district, :text 
  #     configure :postal_area, :text 
  #     configure :country, :text 
  #     configure :combined_street, :text 
  #     configure :opportunity_id, :bson_object_id         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Opportunity do
  #   # Found associations:
  #     configure :opportunity_type, :has_one_association 
  #     configure :buyer, :belongs_to_association 
  #     configure :bids, :has_many_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :name, :string 
  #     configure :description, :text 
  #     configure :starting_location, :text 
  #     configure :ending_location, :text 
  #     configure :start_date, :datetime 
  #     configure :end_date, :datetime 
  #     configure :opportunity_type_id, :integer         # Hidden 
  #     configure :bidding_ends, :datetime 
  #     configure :bidding_done, :boolean 
  #     configure :quick_winnable, :boolean 
  #     configure :win_it_now_price, :decimal 
  #     configure :winning_bid_id, :text 
  #     configure :for_favorites_only, :boolean 
  #     configure :buyer_id, :bson_object_id         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model OpportunityType do
  #   # Found associations:
  #     configure :opportunity, :belongs_to_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :name, :string 
  #     configure :opportunity_id, :bson_object_id         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Profile do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :name, :string 
  #     configure :contact_id, :integer 
  #     configure :company_id, :integer 
  #     configure :active, :boolean   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Region do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :region_type_id, :integer 
  #     configure :company_id, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model RegionType do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :name, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model User do
  #   # Found associations:
  #     configure :company, :belongs_to_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :email, :text 
  #     configure :password, :password         # Hidden 
  #     configure :password_confirmation, :password         # Hidden 
  #     configure :reset_password_token, :text         # Hidden 
  #     configure :reset_password_sent_at, :datetime 
  #     configure :remember_created_at, :datetime 
  #     configure :sign_in_count, :integer 
  #     configure :current_sign_in_at, :datetime 
  #     configure :last_sign_in_at, :datetime 
  #     configure :current_sign_in_ip, :text 
  #     configure :last_sign_in_ip, :text 
  #     configure :authentication_token, :text 
  #     configure :company_id, :bson_object_id         # Hidden 
  #     configure :role, :text   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
end

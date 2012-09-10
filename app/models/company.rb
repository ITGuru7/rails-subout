require 'csv'

class String
  def name_capitalize
    self.split.each {|s| s.capitalize!}.join(' ')
  end
end

class Hash
  def keep_keys(keys)
    output = Hash.new
    self.each do |k,v|
      output[k] = v if keys.include?(k)
    end
    output
  end
  def capitalize_value(k)
    self[k] = self[k].name_capitalize if self[k]
  end
  def downcase_value(k)
    self[k] = self[k].downcase if self[k]
  end
end  

class Company
  include Mongoid::Document
  field :name, type: String
  field :hq_location_id, type: String
  field :active, type: Boolean
  field :company_msg_path, type: String
  field :member, type: Boolean, default: false

  after_initialize :init

  has_many :users
  has_many :opportunities
  has_many :favorites
  has_many :contacts
  has_many :locations

  validates_presence_of :name, :on => :create, :message => "can't be blank"
  validates_presence_of :company_msg_path, :on => :create, :message => "can't be blank"
  
  def init
  	self.company_msg_path  ||= UUID.new.generate
  end

  def interested_in_event?(event)
  	true
  end

  def guest? 
    !member?
  end

  def send_event(event, associated_object)
    Rails.logger.info "Queing event to be sent to path #{company_msg_path}"
  	event.delay.send_msg(company_msg_path, associated_object)
  end

  def Company.import_and_replace(filename)
    # We've sort of gamed the system here. The CSV file that we are importing has the following header line:
    # quest,survey_result,name,phone,phone2,twenty_four_hour_line,fax,contact_name,combined_street,major_municipality,governing_district,postal_area,email1,email2,email3
    # Which just so happens to be the attribute names for companies, contacts and locations.
    # What we will do is to read in the line, make a Hash out of it, and pass it to create, which should 
    # create our records auto-magically.

    puts "Importing and replacing #{filename}"
    headers = nil
    imported_records = 0

    Company.delete_all
    Contact.delete_all
    Location.delete_all

    CSV.foreach(filename) do |data|
      info = Hash.new
      unless headers then
        headers = data
      else
        headers.each_index do |x|
          info[headers[x]] = data[x]
        end
      end
      info.downcase_value("email1")
      info.downcase_value("email2")
      info.downcase_value("email3")
      info.capitalize_value("combined_street")
      info.capitalize_value("major_municipality")
      info.capitalize_value("name")
      info.capitalize_value("contact_name")

      # Now, we have a hash of all of the attributes. Let's make some companies, contacts and locations.
      # In case we already have data here, let's just update them if the company name matches.
      c = Company.create(info.keep_keys(%w{name}))
      info["company_id"] = c.id
      Location.create(info.keep_keys(%w{company_id combined_street major_municipality governing_district postal_area}))
      Contact.create(info.keep_keys(%w{company_id phone phone2 twenty_four_hour_line fax contact_name email1 email2 email3}))
    end
  end
end

require 'csv'

namespace :subout do
  class CompanyImportAndExport
    def self.execute(filename)
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

  task :import_and_replace => :environment do
    puts 'needs fixin'
    # CompanyImportAndExport.execute
  end
end

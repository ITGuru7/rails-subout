require './config/environment.rb'

class Migrate < Thor
  desc "change_currency", "Change currency"
  def change_currency
    Mongoid.unit_of_work(disable: :all) do
      Bid.all.each do |bid|
        amount = bid[:amount]
        bid.set(:amount, amount.to_i * 100) if amount.kind_of?(String)
      end

      Opportunity.all.each do |o|
        win_it_now_price = o[:win_it_now_price]
        o.set(:win_it_now_price, win_it_now_price.to_i * 100) if win_it_now_price.kind_of?(String)

        value = o[:value]
        o.set(:value, value.to_i * 100) if value.kind_of?(String)
      end
    end
  end
end

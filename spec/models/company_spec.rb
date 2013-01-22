require 'spec_helper'

describe Company do
  it "should generate company message path by default" do
    c = FactoryGirl.create(:company)
    expect(c.company_msg_path).not_to be_empty
  end

  describe "#add_favorite_supplier!" do
    it 'adds the supplier to the favorite suppliers list' do
      supplier = FactoryGirl.create(:company)
      buyer = FactoryGirl.create(:company)
      buyer.add_favorite_supplier!(supplier)
      buyer.favorite_supplier_ids.should include(supplier.id)
    end
  end

  describe "#favorite_suppliers" do
    it 'returns the list of favortie suppliers' do
      supplier = FactoryGirl.create(:company)
      buyer = FactoryGirl.create(:company)
      buyer.favorite_supplier_ids << supplier.id
      buyer.save

      buyer.favorite_suppliers.should include(supplier)
    end
  end
end


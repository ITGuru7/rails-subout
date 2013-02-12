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

  describe ".notified_recipients_by" do
    let(:poster) { FactoryGirl.create(:company) }
    let!(:ca_subscriber) { FactoryGirl.create(:ca_company) }
    let!(:ma_subscriber) { FactoryGirl.create(:ma_company) }
    let!(:national_subscriber) { FactoryGirl.create(:company) }
    let!(:favorited_ca_subscriber) { FactoryGirl.create(:ca_company) }

    before do
      poster.add_favorite_supplier!(favorited_ca_subscriber)
    end

    context "with favorite only" do
      it "returns only favorited company" do
        opportunity = FactoryGirl.create(:opportunity, buyer: poster)

        result = Company.notified_recipients_by(opportunity).to_a
        result.should_not include(ca_subscriber)
        result.should include(ma_subscriber)
        result.should include(national_subscriber)
        result.should_not include(favorited_ca_subscriber)
      end
    end

    context "California" do
      it "returns national and California subscribers" do
        opportunity = FactoryGirl.create(:opportunity, buyer: poster, for_favorites_only: true)

        result = Company.notified_recipients_by(opportunity).to_a
        result.should_not include(ca_subscriber)
        result.should_not include(ma_subscriber)
        result.should_not include(national_subscriber)
        result.should include(favorited_ca_subscriber)
      end
    end
  end

  describe ".available_opportunities" do
    let(:poster) { FactoryGirl.create(:company) }
    let!(:ca_subscriber) { FactoryGirl.create(:ca_company) }
    let!(:ma_subscriber) { FactoryGirl.create(:ma_company) }
    let!(:national_subscriber) { FactoryGirl.create(:company) }
    let!(:favorited_ca_subscriber) { FactoryGirl.create(:ca_company) }

    before do
      poster.add_favorite_supplier!(favorited_ca_subscriber)
    end

    context "favorite only opportunity" do
      let!(:fav_only_opportunity) { FactoryGirl.create(:opportunity, for_favorites_only: true, buyer: poster) }

      it { favorited_ca_subscriber.available_opportunities.should include(fav_only_opportunity) }
      it { ma_subscriber.available_opportunities.should_not include(fav_only_opportunity) }
      it { national_subscriber.available_opportunities.should_not include(fav_only_opportunity) }
    end

    context "non favorite only Massachusetts opportunity" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster) }

      it { national_subscriber.available_opportunities.should include(ma_opportunity) }
      it { ma_subscriber.available_opportunities.should include(ma_opportunity) }
      it { ca_subscriber.available_opportunities.should_not include(ma_opportunity) }
      it { favorited_ca_subscriber.available_opportunities.should_not include(ma_opportunity) }
    end

    context "canceled opportunity" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster) }
      before { ma_opportunity.update_attribute(:canceled, true) }

      it { national_subscriber.available_opportunities.should_not include(ma_opportunity) }
    end

    context "ended opportunity" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster) }
      before { ma_opportunity.update_attribute(:created_at, 2.days.ago) }

      it { national_subscriber.available_opportunities.should_not include(ma_opportunity) }
    end

    context "won opportunity" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster, winning_bid_id: "some_id") }

      it { national_subscriber.available_opportunities.should_not include(ma_opportunity) }
    end

    context "own opportunities" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster) }

      it { poster.available_opportunities.should_not include(ma_opportunity) }
    end

    context "when sort_by and sort_direction are nil" do
      it { lambda { poster.available_opportunities(nil, nil) }.should_not raise_error }
    end
  end
end

require "rails_helper"

RSpec.describe Policy, type: :model do
  describe "associations" do
    it { should have_many(:endorsements).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { create(:policy) }

    it { should validate_presence_of(:number) }
    it { should validate_uniqueness_of(:number) }
    it { should validate_presence_of(:issue_date) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:sum_insured) }
    it { should validate_presence_of(:lmg) }
    it { should validate_numericality_of(:lmg).is_greater_than_or_equal_to(0) }

    it "is invalid if end_date is before start_date" do
      policy = build(:policy, start_date: Date.today, end_date: Date.yesterday)
      expect(policy).to be_invalid
      expect(policy.errors[:end_date]).to include("must be after the start date")
    end

    it "is invalid if start_date is more than 30 days after issue_date" do
      policy = build(:policy, issue_date: Date.today, start_date: 40.days.from_now)
      expect(policy).to be_invalid
      expect(policy.errors[:start_date]).to include("cannot be more than 30 days after the issue date")
    end
  end

  describe "#apply_sum_insured!" do
    it "updates sum_insured and lmg" do
      policy = create(:policy)
      policy.apply_sum_insured!(200_000.00)
      expect(policy.sum_insured).to eq(200_000.00)
      expect(policy.lmg).to eq(200_000.00)
    end
  end

  describe "#apply_term!" do
    it "updates start and end date" do
      policy = create(:policy)
      new_start = policy.issue_date + 10.days
      new_end = new_start + 1.year
      policy.apply_term!(new_start, new_end)
      expect(policy.start_date).to eq(new_start)
      expect(policy.end_date).to eq(new_end)
    end
  end

  describe "#mark_as_closed!" do
    it "updates status to closed" do
      policy = create(:policy)
      policy.mark_as_closed!
      expect(policy.status).to eq("closed")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Endorsement, type: :model do
  let(:policy) { create(:policy) }

  describe "validations" do
    it "is valid with required attributes" do
      endorsement = create(:endorsement, policy: policy)
      expect(endorsement).to be_valid
      expect(endorsement.issue_date).to be >= policy.issue_date
    end

    it "is invalid without issue_date" do
      endorsement = build(:endorsement, policy: policy, issue_date: nil)
      expect(endorsement).not_to be_valid
      expect(endorsement.errors[:issue_date]).to include("can't be blank")
    end

    it "is invalid without endorsement_type" do
      endorsement = build(:endorsement, policy: policy, endorsement_type: nil)
      expect(endorsement).not_to be_valid
      expect(endorsement.errors[:endorsement_type]).to include("can't be blank")
    end
  end

  describe "immutability" do
    it "raises error when trying to update" do
      endorsement = create(:endorsement, policy: policy)
      expect {
        endorsement.update!(new_sum_insured: 200_000)
      }.to raise_error(ActiveRecord::RecordNotSaved, /Endorsements cannot be edited or deleted/)
    end

    it "raises error when trying to destroy" do
      endorsement = create(:endorsement, policy: policy)
      expect {
        endorsement.destroy!
      }.to raise_error(ActiveRecord::RecordNotDestroyed, /Endorsements cannot be edited or deleted/)
    end
  end
end

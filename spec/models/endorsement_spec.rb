# frozen_string_literal: true

require "rails_helper"

RSpec.describe Endorsement, type: :model do
  let(:policy) { create(:policy, lmg: 100_000.00, status: "active") }
  let(:endorsement) { create(:endorsement, policy: policy) }

  describe "validations" do
    it "is valid with required attributes" do
      expect(endorsement).to be_valid
    end

    it "is invalid without issue_date" do
      endorsement.issue_date = nil
      expect(endorsement).not_to be_valid
      expect(endorsement.errors[:issue_date]).to include("can't be blank")
    end

    it "is invalid without endorsement_type" do
      endorsement.endorsement_type = nil
      expect(endorsement).not_to be_valid
      expect(endorsement.errors[:endorsement_type]).to include("can't be blank")
    end
  end

  describe "immutability" do
    it "raises error when trying to update" do
      expect {
        endorsement.update!(new_sum_insured: 200_000)
      }.to raise_error(ActiveRecord::RecordNotSaved, /Endorsements cannot be edited or deleted/)
    end

    it "raises error when trying to destroy" do
      expect {
        endorsement.destroy!
      }.to raise_error(ActiveRecord::RecordNotDestroyed, /Endorsements cannot be edited or deleted/)
    end
  end
end

require "rails_helper"

RSpec.describe Endorsement, type: :model do
  let(:policy) { create(:policy, lmg: 100_000.00, status: "active") }
  let(:endorsement) { create(:endorsement, policy: policy) }

  shared_examples "immutable endorsement" do |action, exception_class, update_attributes = nil|
    it "raises error when trying to #{action}" do
      if update_attributes
        expect {
          endorsement.public_send("#{action}!", update_attributes)
        }.to raise_error(exception_class, /Endorsements cannot be edited or deleted/)
      else
        expect {
          endorsement.public_send("#{action}!")
        }.to raise_error(exception_class, /Endorsements cannot be edited or deleted/)
      end
    end
  end

  describe "immutability" do
    include_examples "immutable endorsement", "update", ActiveRecord::RecordNotSaved, { new_sum_insured: 200_000 }

    include_examples "immutable endorsement", "destroy", ActiveRecord::RecordNotDestroyed
  end

  describe "automatic type detection" do
    it "assigns 'increase_sum_insured' when new sum is higher" do
      endorsement = create(:endorsement, policy: policy, new_sum_insured: 120_000, endorsement_type: nil)
      expect(endorsement.endorsement_type).to eq("increase_sum_insured")
    end

    it "assigns 'decrease_sum_insured' when new sum is lower" do
      endorsement = create(:endorsement, policy: policy, new_sum_insured: 80_000, endorsement_type: nil)
      expect(endorsement.endorsement_type).to eq("decrease_sum_insured")
    end
  end

  describe "#apply_to_policy" do
    it "updates the policy LMG when sum insured increases" do
      endorsement = create(:endorsement, policy: policy, new_sum_insured: 150_000)
      endorsement.apply_to_policy
      expect(policy.reload.lmg).to be_within(0.01).of(150_000.00)
    end

    it "sets policy to 'closed' when cancellation endorsement is applied" do
      endorsement = create(:endorsement, :cancellation, policy: policy)
      endorsement.apply_to_policy
      expect(policy.reload.status).to eq("closed")
    end
  end
end

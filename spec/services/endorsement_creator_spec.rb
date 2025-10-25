# frozen_string_literal: true

require "rails_helper"

RSpec.describe EndorsementCreator, type: :service do
  let(:policy) { create(:policy, lmg: 100_000.0, status: "active") }

  describe "#call" do
    context "when creating a simple increase sum insured endorsement" do
      it "creates and applies an increase_sum_insured endorsement" do
        params = { new_sum_insured: 120_000 }
        creator = described_class.new(policy, params)
        endorsement = creator.call

        expect(endorsement).to be_persisted
        expect(endorsement.endorsement_type).to eq("increase_sum_insured")
        expect(policy.reload.lmg).to eq(120_000)
      end
    end

    context "when creating a decrease sum insured endorsement" do
      it "creates and applies a decrease_sum_insured endorsement" do
        params = { new_sum_insured: 80_000 }
        creator = described_class.new(policy, params)
        endorsement = creator.call

        expect(endorsement).to be_persisted
        expect(endorsement.endorsement_type).to eq("decrease_sum_insured")
        expect(policy.reload.lmg).to eq(80_000)
      end
    end

    context "when creating a cancellation endorsement" do
      it "cancels the associated policy" do
        previous_endorsement = create(:endorsement, policy: policy, new_sum_insured: 120_000)

        cancellation_params = { endorsement_type: :cancellation }
        creator = described_class.new(policy, cancellation_params)
        cancellation = creator.call

        expect(cancellation).to be_persisted
        expect(cancellation.endorsement_type).to eq("cancellation")
        expect(cancellation.canceled_endorsement).to eq(previous_endorsement)
        expect(policy.reload.lmg).to eq(previous_endorsement.new_sum_insured)
      end
    end

    context "when params do not allow determining endorsement type" do
      it "raises ActiveRecord::RecordInvalid" do
        creator = described_class.new(policy, {})
        expect { creator.call }.to raise_error(ActiveRecord::RecordInvalid, /Cannot determine endorsement type/)
      end
    end
  end
end

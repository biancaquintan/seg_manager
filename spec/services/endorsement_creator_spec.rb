# frozen_string_literal: true

require "rails_helper"

RSpec.describe EndorsementCreator, type: :service do
  let(:policy) { create(:policy, sum_insured: 100_000.to_d, lmg: 100_000.to_d, issue_date: Date.today, start_date: Date.today + 1.day, end_date: Date.today + 30.days) }
  let(:service) { described_class.new(policy) }
  let(:issue_date) { policy.issue_date }

  describe '#call' do
    context 'when increasing sum insured' do
      it 'creates an endorsement and updates the policy sum_insured and lmg' do
        params = { endorsement_type: :increase_sum_insured, issue_date: issue_date, new_sum_insured: 120_000.to_d }

        endorsement = service.call(params)

        expect(endorsement).to be_persisted
        expect(endorsement.endorsement_type).to eq('increase_sum_insured')
        expect(policy.reload.sum_insured).to eq(120_000.to_d)
        expect(policy.lmg).to eq(120_000.to_d)
      end
    end

    context 'when decreasing sum insured' do
      it 'creates an endorsement and updates the policy sum_insured and lmg' do
        params = { endorsement_type: :decrease_sum_insured, issue_date: issue_date, new_sum_insured: 80_000.to_d }

        endorsement = service.call(params)

        expect(endorsement).to be_persisted
        expect(endorsement.endorsement_type).to eq('decrease_sum_insured')
        expect(policy.reload.sum_insured).to eq(80_000.to_d)
        expect(policy.lmg).to eq(80_000.to_d)
      end
    end

    context 'when changing term' do
      it 'creates an endorsement and updates the policy term dates' do
        new_start = policy.issue_date + 10.days
        new_end   = policy.end_date + 10.days

        params = { endorsement_type: :change_term, issue_date: issue_date, new_start_date: new_start, new_end_date: new_end }

        endorsement = service.call(params)

        expect(endorsement).to be_persisted
        expect(endorsement.endorsement_type).to eq('change_term')
        expect(policy.reload.start_date).to eq(new_start)
        expect(policy.end_date).to eq(new_end)
      end
    end

    context 'when increasing sum insured and changing term' do
      it 'updates both sum_insured/lmg and term dates' do
        new_start = policy.issue_date + 5.days
        new_end   = policy.end_date + 5.days

        params = {
          endorsement_type: :increase_and_change_term,
          issue_date: issue_date,
          new_sum_insured: 150_000.to_d,
          new_start_date: new_start,
          new_end_date: new_end
        }

        endorsement = service.call(params)

        expect(endorsement).to be_persisted
        expect(endorsement.endorsement_type).to eq('increase_and_change_term')
        expect(policy.reload.sum_insured).to eq(150_000.to_d)
        expect(policy.lmg).to eq(150_000.to_d)
        expect(policy.start_date).to eq(new_start)
        expect(policy.end_date).to eq(new_end)
      end
    end

    context 'when decreasing sum insured and changing term' do
      it 'updates both sum_insured/lmg and term dates' do
        new_start = policy.issue_date + 5.days
        new_end   = policy.end_date + 5.days

        params = {
          endorsement_type: :decrease_and_change_term,
          issue_date: issue_date,
          new_sum_insured: 90_000.to_d,
          new_start_date: new_start,
          new_end_date: new_end
        }

        endorsement = service.call(params)

        expect(endorsement).to be_persisted
        expect(endorsement.endorsement_type).to eq('decrease_and_change_term')
        expect(policy.reload.sum_insured).to eq(90_000.to_d)
        expect(policy.lmg).to eq(90_000.to_d)
        expect(policy.start_date).to eq(new_start)
        expect(policy.end_date).to eq(new_end)
      end
    end

    context 'when cancelling a policy' do
      it 'creates a cancellation endorsement and closes the policy' do
        params = { endorsement_type: :cancellation, issue_date: issue_date }

        endorsement = service.call(params)

        expect(endorsement).to be_persisted
        expect(endorsement.endorsement_type).to eq('cancellation')
        expect(policy.reload.status).to eq('closed')
      end
    end

    context 'with invalid parameters' do
      it 'raises validation error for missing sum insured' do
        params = { endorsement_type: :increase_sum_insured, issue_date: issue_date }

        expect { service.call(params) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'raises validation error for invalid term dates' do
        params = {
          endorsement_type: :change_term,
          issue_date: issue_date,
          new_start_date: policy.issue_date + 10.days,
          new_end_date: policy.issue_date + 5.days
        }

        expect { service.call(params) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end

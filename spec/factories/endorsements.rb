# frozen_string_literal: true

FactoryBot.define do
  factory :endorsement do
    association :policy
    issue_date { Date.current }

    endorsement_type { :increase_sum_insured }
    new_sum_insured { 120_000.0 }
    new_start_date { nil }
    new_end_date { nil }
    canceled_endorsement { nil }

    trait :increase_sum_insured do
      endorsement_type { :increase_sum_insured }
      new_sum_insured { 120_000.0 }
      new_start_date { nil }
      new_end_date { nil }
    end

    trait :decrease_sum_insured do
      endorsement_type { :decrease_sum_insured }
      new_sum_insured { 80_000.0 }
      new_start_date { nil }
      new_end_date { nil }
    end

    trait :change_term do
      endorsement_type { :change_term }
      new_sum_insured { nil }
      new_start_date { -> { policy.start_date + 10.days } }
      new_end_date { -> { policy.end_date + 10.days } }
    end

    trait :increase_and_change_term do
      endorsement_type { :increase_and_change_term }
      new_sum_insured { 150_000.0 }
      new_start_date { -> { policy.start_date + 5.days } }
      new_end_date { -> { policy.end_date + 5.days } }
    end

    trait :decrease_and_change_term do
      endorsement_type { :decrease_and_change_term }
      new_sum_insured { 90_000.0 }
      new_start_date { -> { policy.start_date + 5.days } }
      new_end_date { -> { policy.end_date + 5.days } }
    end

    trait :cancellation do
      endorsement_type { :cancellation }
      new_sum_insured { nil }
      new_start_date { nil }
      new_end_date { nil }
    end
  end
end

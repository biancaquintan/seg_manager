FactoryBot.define do
  factory :endorsement do
    association :policy
    issue_date { Date.today }
    endorsement_type { :increase_sum_insured }
    new_sum_insured { 120_000.00 }
    new_start_date { nil }
    new_end_date { nil }
    canceled_endorsement { nil }

    trait :change_term do
      endorsement_type { :change_term }
      new_sum_insured { nil }
      new_start_date { policy.start_date + 10.days }
      new_end_date { policy.end_date + 10.days }
    end

    trait :cancellation do
      endorsement_type { :cancellation }
      new_sum_insured { nil }
      new_start_date { nil }
      new_end_date { nil }
    end
  end
end

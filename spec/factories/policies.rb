# frozen_string_literal: true

FactoryBot.define do
  factory :policy do
    sequence(:number) { |n| "POL#{n}#{SecureRandom.hex(2).upcase}" }

    issue_date { Date.new(2025, 10, 25) }
    start_date { Date.new(2025, 10, 26) }
    end_date { Date.new(2026, 10, 26) }

    sum_insured { 100_000.0 }
    lmg { 100_000.0 }
    status { :active }

    trait :closed do
      status { :closed }
    end
  end
end

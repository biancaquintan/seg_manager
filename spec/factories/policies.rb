FactoryBot.define do
  factory :policy do
    number { Faker::Alphanumeric.unique.alphanumeric(number: 8).upcase }

    issue_date { Faker::Date.backward(days: 30) }

    start_date { issue_date + rand(0..30).days }

    end_date { start_date + 1.year }

    sum_insured { 100_000.00 }
    lmg { 100_000.00 }
    status { :active }

    trait :closed do
      status { :closed }
    end
  end
end

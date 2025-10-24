class PolicySerializer < ActiveModel::Serializer
  attributes :id, :number, :issue_date, :start_date, :end_date,
             :sum_insured, :lmg, :status, :created_at, :updated_at

  has_many :endorsements, serializer: EndorsementSerializer
end

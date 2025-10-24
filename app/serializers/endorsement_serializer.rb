class EndorsementSerializer < ActiveModel::Serializer
  attributes :id, :issue_date, :endorsement_type, :new_sum_insured,
             :new_start_date, :new_end_date, :canceled_endorsement_id,
             :created_at, :updated_at
end

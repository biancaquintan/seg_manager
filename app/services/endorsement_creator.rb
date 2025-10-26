# frozen_string_literal: true

class EndorsementCreator
  def initialize(policy)
    @policy = policy
  end

  def call(params)
    raise ActiveRecord::RecordInvalid.new(Endorsement.new), "Cannot create endorsement for a closed policy" if @policy.closed?

    ActiveRecord::Base.transaction do
      if params[:cancellation]
        endorsement = create_cancellation_endorsement(params[:issue_date])
        @policy.update!(status: "closed")
      else
        endorsement_type = determine_endorsement_type(params)
        endorsement = create_regular_endorsement(params, endorsement_type)
        apply_policy_changes(params)
      end

      endorsement
    end
  end

  private

  def create_cancellation_endorsement(issue_date)
    Endorsement.create!(
      policy: @policy,
      issue_date: issue_date,
      endorsement_type: :cancellation
    )
  end

  def create_regular_endorsement(params, endorsement_type)
    Endorsement.create!(
      policy: @policy,
      issue_date: params[:issue_date],
      endorsement_type: endorsement_type,
      new_sum_insured: params[:new_sum_insured]&.to_d,
      new_start_date: params[:new_start_date],
      new_end_date: params[:new_end_date]
    )
  end

  def determine_endorsement_type(params)
    changes = []
    changes << :increase_sum_insured if params[:new_sum_insured].present? && params[:new_sum_insured].to_d > @policy.sum_insured
    changes << :decrease_sum_insured if params[:new_sum_insured].present? && params[:new_sum_insured].to_d < @policy.sum_insured
    changes << :change_term if params[:new_start_date].present? && params[:new_end_date].present? &&
                               (params[:new_start_date] != @policy.start_date || params[:new_end_date] != @policy.end_date)

    if changes.empty?
      raise ActiveRecord::RecordInvalid.new(Endorsement.new), "No changes detected for endorsement"
    end

    if changes.include?(:increase_sum_insured) && changes.include?(:change_term)
      :increase_and_change_term
    elsif changes.include?(:decrease_sum_insured) && changes.include?(:change_term)
      :decrease_and_change_term
    elsif changes.include?(:increase_sum_insured)
      :increase_sum_insured
    elsif changes.include?(:decrease_sum_insured)
      :decrease_sum_insured
    else
      :change_term
    end
  end

  def apply_policy_changes(params)
    if params[:new_sum_insured].present?
      @policy.update!(sum_insured: params[:new_sum_insured].to_d, lmg: params[:new_sum_insured].to_d)
    end

    if params[:new_start_date].present? && params[:new_end_date].present?
      if params[:new_start_date] > params[:new_end_date]
        raise ActiveRecord::RecordInvalid.new(Endorsement.new), "Invalid term dates"
      end
      @policy.update!(start_date: params[:new_start_date], end_date: params[:new_end_date])
    end
  end
end

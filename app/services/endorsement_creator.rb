# frozen_string_literal: true

class EndorsementCreator
  def initialize(policy)
    @policy = policy
  end

  def call(params)
    Endorsement.transaction do
      endorsement = @policy.endorsements.create!(
        issue_date: params[:issue_date],
        endorsement_type: params[:endorsement_type],
        new_sum_insured: params[:new_sum_insured],
        new_start_date: params[:new_start_date],
        new_end_date: params[:new_end_date],
        canceled_endorsement_id: params[:canceled_endorsement_id]
      )

      apply_effects!(endorsement, params)
      endorsement
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  rescue StandardError => e
    raise ActiveRecord::Rollback, e.message
  end

  private

  attr_reader :policy

  def apply_effects!(endorsement, params)
    case endorsement.endorsement_type.to_sym
    when :increase_sum_insured, :decrease_sum_insured
      update_sum_insured!(params[:new_sum_insured])

    when :change_term
      update_term_dates!(params[:new_start_date], params[:new_end_date])

    when :increase_and_change_term, :decrease_and_change_term
      update_sum_insured!(params[:new_sum_insured])
      update_term_dates!(params[:new_start_date], params[:new_end_date])

    when :cancellation
      cancel_policy!
    else
      raise ArgumentError, "Tipo de endosso inválido"
    end
  end

  def update_sum_insured!(new_sum_insured)
    if new_sum_insured.blank? || new_sum_insured.to_f <= 0
      policy.errors.add(:sum_insured, "Novo valor de soma segurada é obrigatório")
      raise ActiveRecord::RecordInvalid.new(policy)
    end

    policy.apply_sum_insured!(new_sum_insured)
  end

  def update_term_dates!(new_start_date, new_end_date)
    if new_start_date.blank? || new_end_date.blank?
      policy.errors.add(:base, "Datas de vigência são obrigatórias")
      raise ActiveRecord::RecordInvalid.new(policy)
    end

    policy.apply_term!(new_start_date, new_end_date)
  end

  def cancel_policy!
    policy.mark_as_closed!
  end
end

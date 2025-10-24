class EndorsementCreator
  def initialize(policy, params)
    @policy = policy
    @params = params.dup.symbolize_keys
  end

  def call
    ActiveRecord::Base.transaction do
      prepare_params!
      endorsement = create_endorsement!
      apply_changes!(endorsement)
      endorsement
    end
  end

  private

  def prepare_params!
    @params[:issue_date] ||= Date.today

    return if @params[:endorsement_type].present?

    new_is = @params[:new_sum_insured]
    new_start = @params[:new_start_date]
    new_end = @params[:new_end_date]

    is_change = new_is.present? && new_is.to_d != @policy.sum_insured.to_d
    term_change = new_start.present? || new_end.present?

    if @params[:cancellation]
      @params[:endorsement_type] = "cancellation"
      @params.delete(:cancellation)
      return
    end

    if is_change && term_change
      @params[:endorsement_type] = new_is.to_d > @policy.sum_insured.to_d ? "increase_and_change_term" : "decrease_and_change_term"
    elsif is_change
      @params[:endorsement_type] = new_is.to_d > @policy.sum_insured.to_d ? "increase_sum_insured" : "decrease_sum_insured"
    elsif term_change
      @params[:endorsement_type] = "change_term"
    else
      raise ActiveRecord::RecordInvalid.new(build_temp_endorsement_with_errors("Cannot determine endorsement type"))
    end
  end

  def build_temp_endorsement_with_errors(msg)
    e = @policy.endorsements.build(@params)
    e.errors.add(:base, msg)
    e
  end

  def create_endorsement!
    @policy.endorsements.create!(@params)
  end

  def apply_changes!(endorsement)
    case endorsement.endorsement_type.to_s
    when "increase_sum_insured", "decrease_sum_insured"
      @policy.apply_sum_insured!(endorsement.new_sum_insured)
    when "change_term"
      @policy.apply_term!(endorsement.new_start_date, endorsement.new_end_date)
    when "increase_and_change_term", "decrease_and_change_term"
      @policy.apply_sum_insured!(endorsement.new_sum_insured)
      @policy.apply_term!(endorsement.new_start_date, endorsement.new_end_date)
    when "cancellation"
      apply_cancellation!(endorsement)
    else
      raise ArgumentError, "Unsupported endorsement type: #{endorsement.endorsement_type}"
    end
  end

  def apply_cancellation!(endorsement)
    previous = @policy.endorsements
                      .where.not(endorsement_type: :cancellation)
                      .where(canceled_endorsement_id: nil)
                      .order(:created_at).last

    unless previous
      endorsement.errors.add(:base, "No previous endorsement to cancel")
      raise ActiveRecord::RecordInvalid.new(endorsement)
    end

    endorsement.update_column(:canceled_endorsement_id, previous.id)

    new_lmg = @policy.endorsements
                     .where.not(endorsement_type: :cancellation)
                     .where(canceled_endorsement_id: nil)
                     .order(:created_at)
                     .pluck(:new_sum_insured)
                     .compact
                     .last || @policy.sum_insured

    if new_lmg.nil? || new_lmg < 0
      @policy.mark_as_baixada!
    else
      @policy.apply_sum_insured!(new_lmg)
    end
  end

  def compute_sum_insured_excluding(excluded)
    current = @policy.sum_insured
    @policy.endorsements.order(:created_at).each do |e|
      next if e == excluded
      next if e.cancellation?
      current = e.new_sum_insured if e.new_sum_insured.present?
    end
    current
  end
end

class Policy < ApplicationRecord
  has_many :endorsements, dependent: :restrict_with_error

  enum status: { active: 0, closed: 1 } # closed = baixada

  validates :number, presence: true, uniqueness: true
  validates :issue_date, :start_date, :end_date, :sum_insured, :lmg, presence: true
  validates :lmg, numericality: { greater_than_or_equal_to: 0 }
  validate :valid_term_dates
  validate :start_date_within_issue_period

  def apply_sum_insured!(new_sum_insured)
    if new_sum_insured.nil? || new_sum_insured.negative?
      errors.add(:sum_insured, "must be a positive number")
      raise ActiveRecord::RecordInvalid.new(self)
    end

    update!(sum_insured: new_sum_insured, lmg: new_sum_insured)
  end

  def apply_term!(new_start_date, new_end_date)
    if new_start_date.blank? || new_end_date.blank? || new_end_date <= new_start_date
      errors.add(:end_date, "must be after the start date")
      raise ActiveRecord::RecordInvalid.new(self)
    end

    update!(start_date: new_start_date, end_date: new_end_date)
  end

  def mark_as_closed!
    update!(status: :closed)
  end

  def last_valid_endorsement
    endorsements
      .where.not(endorsement_type: :cancellation)
      .where(canceled_endorsement_id: nil)
      .order(created_at: :desc)
      .first
  end

  def recalculate_lmg!
    last_valid = last_valid_endorsement
    new_value = last_valid&.new_sum_insured || sum_insured
    update!(lmg: new_value)
  end

  private

  def valid_term_dates
    return unless start_date && end_date
    errors.add(:end_date, "must be after the start date") if end_date <= start_date
  end

  def start_date_within_issue_period
    return unless issue_date && start_date

    if start_date < issue_date
      errors.add(:start_date, "cannot be before the issue date")
    elsif start_date > issue_date + 30.days
      errors.add(:start_date, "cannot be more than 30 days after the issue date")
    end
  end
end

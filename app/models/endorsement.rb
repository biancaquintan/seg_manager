class Endorsement < ApplicationRecord
  belongs_to :policy
  belongs_to :canceled_endorsement, class_name: "Endorsement", optional: true

  enum endorsement_type: {
    increase_sum_insured: 0,
    decrease_sum_insured: 1,
    change_term: 2,
    increase_and_change_term: 3,
    decrease_and_change_term: 4,
    cancellation: 5
  }

  validates :issue_date, presence: true
  validates :endorsement_type, presence: true

  before_validation :detect_endorsement_type, on: :create
  before_update :prevent_update
  before_destroy :prevent_destroy

  def apply_to_policy
    case endorsement_type
    when "increase_sum_insured", "decrease_sum_insured"
      policy.update!(lmg: new_sum_insured)
    when "cancellation"
      policy.update!(status: "closed")
    end
  end

  private

  def prevent_update
    raise ActiveRecord::RecordNotSaved, "Endorsements cannot be edited or deleted"
  end

  def prevent_destroy
    raise ActiveRecord::RecordNotDestroyed, "Endorsements cannot be edited or deleted"
  end

  def detect_endorsement_type
    return if endorsement_type.present?
    return if new_sum_insured.blank? || policy.blank?

    if new_sum_insured > policy.lmg
      self.endorsement_type = :increase_sum_insured
    elsif new_sum_insured < policy.lmg
      self.endorsement_type = :decrease_sum_insured
    end
  end
end

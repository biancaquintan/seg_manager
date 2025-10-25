# frozen_string_literal: true

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

  before_update :prevent_update
  before_destroy :prevent_destroy

  private

  def prevent_update
    raise ActiveRecord::RecordNotSaved, "Endorsements cannot be edited or deleted"
  end

  def prevent_destroy
    raise ActiveRecord::RecordNotDestroyed, "Endorsements cannot be edited or deleted"
  end
end

class CreateEndorsements < ActiveRecord::Migration[7.1]
  def change
    create_table :endorsements do |t|
      t.references :policy, null: false, foreign_key: true
      t.date :issue_date, null: false
      t.integer :endorsement_type, null: false
      t.decimal :new_sum_insured, precision: 15, scale: 2
      t.date :new_start_date
      t.date :new_end_date
      t.references :canceled_endorsement, foreign_key: { to_table: :endorsements }

      t.timestamps
    end
  end
end

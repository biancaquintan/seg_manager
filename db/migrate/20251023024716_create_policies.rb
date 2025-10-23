class CreatePolicies < ActiveRecord::Migration[7.1]
  def change
    create_table :policies do |t|
      t.string  :number, null: false
      t.date    :issue_date, null: false
      t.date    :start_date, null: false
      t.date    :end_date, null: false
      t.decimal :sum_insured, precision: 15, scale: 2, null: false
      t.decimal :lmg, precision: 15, scale: 2, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :policies, :number, unique: true
  end
end

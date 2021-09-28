class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.string :title
      t.integer :publisher_id
      t.date :proposal_date
      t.date :contract_date
      t.date :published_date
      t.integer :units_sold

      t.timestamps
    end
  end
end

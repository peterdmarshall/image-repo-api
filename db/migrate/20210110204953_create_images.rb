class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.belongs_to :user, null: false
      t.timestamps
    end
  end
end

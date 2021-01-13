class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.belongs_to :user, null: false
      t.string :object_key, null: false
      t.string :filename, null: false
      t.string :filetype, null: false
      t.boolean :private, null: false
      
      t.timestamps
    end
  end
end

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :auth0_uid

      t.timestamps
    end
  end
end

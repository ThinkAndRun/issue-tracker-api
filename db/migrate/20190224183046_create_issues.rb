class CreateIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :issues do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :manager, index: true
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'pending', limit: 30

      t.timestamps
    end
  end
end

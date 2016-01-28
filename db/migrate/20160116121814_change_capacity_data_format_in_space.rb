class ChangeCapacityDataFormatInSpace < ActiveRecord::Migration
  def up
   change_column :spaces, :capacity, :string
  end

  def down
   change_column :spaces, :capacity, :integer
  end
end

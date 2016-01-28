class ChangeFieldNameInSpace < ActiveRecord::Migration
  def change
    rename_column :spaces, :listing_name, :space_name
  end
end

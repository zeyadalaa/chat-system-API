class RemovePasswordFromApplications < ActiveRecord::Migration[7.0]
  def change

    remove_column :applications, :password if column_exists?(:applications, :password)
  end
end

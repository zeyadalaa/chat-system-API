class AddIndexToApplicationsToken < ActiveRecord::Migration[7.0]
  def change
    unless index_exists?(:applications, :token, unique: true)
      add_index :applications, :token, unique: true
    end
  end
end

class AddTokenToRecord < ActiveRecord::Migration
  def change
    add_column :records, :token, :string
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :username
      t.string  :password_digest
      t.boolean :admin, default: false
      t.string  :default_primary
      t.string  :default_postmaster

      t.timestamps
    end
    add_index :users, :username, unique: true

    create_table :domains_users, id: false do |t|
      t.belongs_to :domain
      t.belongs_to :user
    end
    add_index :domains_users, [:domain_id, :user_id], unique: true


    reversible do |dir|
      dir.up do
        %w(user domain).each do |object|
          execute <<-SQL
            ALTER TABLE domains_users
            ADD CONSTRAINT #{object}_exists
            FOREIGN KEY(#{object}_id)
            REFERENCES #{object}s(id)
            ON DELETE CASCADE
          SQL
        end
      end

      dir.down do
        %w(user domain).each do |object|
          execute <<-SQL
            ALTER TABLE domains_users
            DROP CONSTRAINT #{object}_exists
          SQL
        end
      end
    end
  end
end


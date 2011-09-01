class CreateShortenedUrlsTable < ActiveRecord::Migration
  def self.up
    create_table :shortened_urls do |t|
      
      t.integer :user_id # we can link this to a user for interesting things
      t.string :url, :null => false # the real url that we will redirect to
      t.string :unique_key, :null => false # the unique key 
      t.integer :use_count, :null => false, :default => 0 # how many times the link has been clicked

      t.timestamps
    end
    
    add_index :shortened_urls, :unique_key # we will lookup the links in the db with this 
    add_index :shortened_urls, :user_id # and this
  end

  def self.down
    remove_index :shortened_urls, :unique_key
    remove_index :shortened_urls, :user_id
    drop_table :shortened_urls
  end
end

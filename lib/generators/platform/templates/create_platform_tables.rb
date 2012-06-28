#--
# Copyright (c) 2010-2011 Michael Berkovich
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class CreatePlatformTables < ActiveRecord::Migration
  def self.up
    create_table :platform_developers do |t|
      t.integer :user_id, :limit => 8, :null => false
      t.string  :name, :null => false
      t.text    :about
      t.string  :url
      t.string  :email
      t.string  :phone
      t.timestamps
    end
    add_index :platform_developers, :user_id
    
    create_table :platform_applications do |t|
      t.integer :developer_id
      t.string  :name
      t.text    :description
      t.string  :state,             :default => "new"
      t.string  :locale
      t.string  :url
      t.string  :site_domain
      t.string  :support_url
      t.string  :callback_url
      t.string  :contact_email
      t.string  :privacy_policy_url
      t.string  :terms_of_service_url
      t.string  :permissions
      t.string  :key
      t.string  :secret
      t.integer :icon_id
      t.integer :logo_id
      t.string  :canvas_name
      t.string  :canvas_url
      t.boolean :auto_resize
      t.boolean :auto_login
      t.string  :mobile_application_type
      t.string  :ios_bundle_id
      t.string  :itunes_app_store_id
      t.string  :android_key_hash
      t.integer :rank
      t.boolean :auto_signin
      t.string  :deauthorize_callback_url
      t.string  :version
      t.string  :api_version
      t.integer :parent_id
      t.timestamps
    end
    add_index :platform_applications, :developer_id
    add_index :platform_applications, :key, :unique    
    add_index :platform_applications, :parent_id  
    
    create_table :platform_application_logs do |t|
      t.integer     :application_id
      t.integer     :user_id
      t.string      :event
      t.string      :controller
      t.string      :action
      t.string      :request_method 
      t.text        :data
      t.string      :user_agent
      t.integer     :duration
      t.string      :host
      t.string      :country
      t.string      :ip
      t.timestamps
    end
    add_index :platform_application_logs, [:application_id, :created_at]    
    
    create_table :platform_application_metrics do |t|
      t.string    :type
      t.timestamp :interval
      t.integer   :application_id
      t.integer   :active_user_count
      t.integer   :new_user_count
      t.timestamps
    end      
    add_index :platform_application_metrics, [:application_id, :interval]
    
    create_table :platform_application_usage_metrics do |t|
      t.string    :type
      t.timestamp :interval
      t.integer   :application_id
      t.string    :event
      t.integer   :count
      t.integer   :avg_response_time
      t.integer   :error_count
      t.timestamps
    end      
    add_index :platform_application_usage_metrics, [:application_id, :interval]

    create_table :platform_rollup_logs do |t|
      t.timestamp  :interval 
      t.timestamp  :started_at
      t.timestamp  :finished_at
      t.timestamps
    end
    add_index :platform_rollup_logs, :interval
    
    create_table :platform_media do |t|
      t.string  :type
      t.string  :file_location
      t.string  :content_type
      t.string  :file_name
      t.timestamps
    end    
    
    create_table :platform_application_developers do |t|
      t.integer :application_id
      t.integer :developer_id
      t.timestamps
    end
    add_index :platform_application_developers, :application_id
    add_index :platform_application_developers, :developer_id    
    
    create_table :platform_oauth_tokens do |t|
      t.string    :type,            :limit => 20
      t.integer   :user_id,         :limit=>8
      t.integer   :application_id
      t.string    :token,           :limit => 50
      t.string    :secret,          :limit => 50
      t.string    :verifier,        :limit => 20
      t.string    :callback_url
      t.string    :scope
      t.timestamp :valid_to
      t.timestamp :authorized_at, :invalidated_at
      t.timestamps
    end
    add_index :platform_oauth_tokens, :token, :unique
    
    create_table :platform_ratings do |t|
      t.integer   :user_id,         :limit => 8, :null => false 
      t.string    :object_type
      t.integer   :object_id
      t.integer   :value
      t.text      :comment
      t.timestamps
    end
    add_index :platform_ratings, :user_id
    add_index :platform_ratings, [:object_type, :object_id]    
    
    create_table :platform_categories do |t|
      t.string    :type
      t.string    :name
      t.string    :keyword
      t.integer   :position 
      t.date      :enable_on
      t.date      :disable_on
      t.integer   :parent_id 
      t.timestamps
    end
    add_index :platform_categories, :parent_id    
    
    create_table :platform_application_categories do |t|
      t.integer   :category_id,     :null => false
      t.integer   :application_id,  :null => false
      t.integer   :position
      t.boolean   :featured
      t.timestamps
    end
    add_index :platform_application_categories, :category_id
    add_index :platform_application_categories, [:category_id, :application_id]
    
    create_table :platform_forum_topics do |t|
      t.string  :subject_type
      t.integer :subject_id
      t.integer :user_id,         :null => false
      t.text    :topic,           :null => false
      t.timestamps
    end
    add_index :platform_forum_topics, [:subject_type, :subject_id]
    add_index :platform_forum_topics, [:user_id]    
    
    create_table :platform_forum_messages do |t|
      t.integer :forum_topic_id,  :null => false
      t.integer :user_id,         :null => false
      t.text    :message,         :null => false
      t.timestamps
    end
    add_index :platform_forum_messages, [:forum_topic_id]
    add_index :platform_forum_messages, [:user_id]
    
    create_table :platform_permissions do |t|
      t.string  :keyword,         :null => false
      t.text    :description,     :null => false
      t.timestamps
    end
    add_index :platform_permissions, [:keyword]    
    
    create_table :platform_application_permissions do |t|
      t.integer :application_id
      t.integer :permission_id
      t.timestamps
    end
    add_index :platform_application_permissions, :application_id
    
    create_table :platform_application_users do |t|
      t.integer :application_id,  :null => false
      t.integer :user_id,         :null => false
      t.text    :data
      t.timestamps
    end
    add_index :platform_application_users, [:application_id]
    add_index :platform_application_users, [:user_id]
    
    create_table :platform_users do |t|
      t.string  :name
      t.string  :gender
      t.string  :email
      t.string  :password
      t.string  :mugshot
      t.string  :link
      t.string  :locale
      t.timestamps
    end
    add_index :platform_users, [:email]
    add_index :platform_users, [:email, :password]     
    
    create_table :platform_admins do |t|
      t.integer :user_id
      t.integer :level
      t.timestamps
    end
    add_index :platform_admins, [:user_id]    
    
    create_table :platform_logged_exceptions do |t|
      t.column :exception_class, :string
      t.column :controller_name, :string
      t.column :action_name,     :string
      t.column :server,          :string
      t.column :message,         :text
      t.column :backtrace,       :text
      t.column :environment,     :text
      t.column :request,         :text
      t.column :session,         :text
      t.column :cause,           :binary
      t.column :user_id,         :integer  
      t.column :application_id,  :integer  
      t.timestamps
    end
  end

  def self.down
    drop_table :platform_developers
    drop_table :platform_applications
    drop_table :platform_application_logs
    drop_table :platform_application_metrics
    drop_table :platform_rollup_logs
    drop_table :platform_application_developers
    drop_table :platform_oauth_tokens
    drop_table :platform_ratings
    drop_table :platform_categories
    drop_table :platform_category_items
    drop_table :platform_forum_topics
    drop_table :platform_forum_messages
    drop_table :platform_permissions
    drop_table :platform_application_permissions
    drop_table :platform_application_users
    drop_table :platform_users
    drop_table :platform_admins
    drop_table :platform_logged_exceptions
  end
end

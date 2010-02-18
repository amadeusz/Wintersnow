# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_koliber_session',
  :secret      => '6ef7f2806d112a23b0c6202701c34452e134f8c99b2b0feaafb63323c2b0297540146ef700e895ac71db220775a0e5f04084dc5c46fa685af26901d8e49f8439'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

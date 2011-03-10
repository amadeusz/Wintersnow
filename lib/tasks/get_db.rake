task :get_db do
	puts `rsync koliber@appload:/home/koliber/db/production.sqlite3 /home/maciek/quests/koliber/development.sqlite3`
end

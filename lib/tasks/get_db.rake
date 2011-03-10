task :get_db do
	if (`hostname` == 'satan')
		puts `rsync koliber@appload:/home/koliber/db/production.sqlite3 /home/maciek/quests/koliber/db/development.sqlite3`
	end
	
	if (`hostname` == '')
		puts `rsync --help`
	end
end

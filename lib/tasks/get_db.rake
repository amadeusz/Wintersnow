task :get_db do
	if (`hostname` == "satan\n")
		puts `rsync koliber@appload.pl:/home/koliber/db/production.sqlite3 /home/maciek/quests/koliber/db/development.sqlite3`
	end
	
	if (`hostname` == '')
		puts `rsync --help`
	end
end

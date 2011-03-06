require 'active_record'
require 'nokogiri'
require 'mechanize'

def sprawdz_zawartosc_rss(user)
	user.addresses.each { |strona_w_db|
		polecenie_aktualizacji = strona_w_db.look_for_changes
	} if not user.addresses.empty? 
end

class RssController < ApplicationController
	skip_before_filter :require_admin_login, :only => [:web, :of, :update]
	skip_before_filter :require_login, :only => [:of]
	
	def of
		headers['Content-type'] = 'text/xml'
		sprawdz_zawartosc_rss(User.find_by_klucz(params[:id]))
		
		render :layout => false
	end
	
	def update
		sprawdz_zawartosc_rss(current_user)
		
		respond_to do |format|
			format.html { render :layout => false }
			format.xml	{ head :ok }
		end
	end
	
	def web
		respond_to do |format|
			format.html
			format.xml	{ head :ok }
		end
	end
	
end


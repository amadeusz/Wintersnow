class ApplicationController < ActionController::Base

	before_filter :require_login
	before_filter :require_admin_login
	
	protect_from_forgery

	def require_login
		unless logged_in?
			flash[:error] = "Musisz się zalogować"
			redirect_to root_path
		end
	end

	def require_admin_login
		unless admin_logged_in?
			flash[:error] = "Musisz posiadać uprawnienia administratora"
			redirect_to root_path
		end
	end

	def admin_logged_in?
		!!current_user.admin if !!current_user
	end

	def logged_in?
		!!current_user
	end

	def current_user
		@_current_user ||= session[:current_user_id] && User.find(session[:current_user_id])
	end
	
end

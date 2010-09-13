class LoginController < ApplicationController

	def authenticate(nazwa, haslo)
		return User.where(:klucz => nazwa, :haslo => haslo).first
	end

	def create
		if user = authenticate(params[:nazwa], params[:haslo])
			session[:current_user_id] = user.id
			flash[:notice] = "Zostałeś zalogowany"
			redirect_to root_url
		else
			flash[:error] = "Logowanie nie powiodło się, spróbuj ponownie"
			redirect_to root_url
		end
	end
	
	def destroy
		session[:current_user_id] = nil
		flash[:notice] = "Zostałeś wylogowany"
		redirect_to root_url
		# reset_session
	end
end

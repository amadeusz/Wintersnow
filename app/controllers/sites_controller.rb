class SitesController < ApplicationController

	def index
		@sites = Site.all

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @genotypes }
		end
	end

#	def show
#		@genotype = Genotype.find(params[:id])

#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml	{ render :xml => @genotype }
#		end
#	end

#	def new
#		@genotype = Genotype.new

#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml	{ render :xml => @genotype }
#		end
#	end

	def edit
		@site = Site.find(params[:id])
	end

#	def create
#		@genotype = Genotype.new(params[:genotype])

#		respond_to do |format|
#			if @genotype.save
#				format.html { redirect_to(genotypes_path, :notice => 'Genotype was successfully created.') }
#				format.xml	{ render :xml => @genotype, :status => :created, :location => @genotype }
#			else
#				format.html { render :action => "new" }
#				format.xml	{ render :xml => @genotype.errors, :status => :unprocessable_entity }
#			end
#		end
#	end

	def update
		@site = Site.find(params[:id])

		respond_to do |format|
			if @site.update_attributes(params[:site])
				format.html { redirect_to(sites_path, :notice => 'Site was successfully updated.') }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @site.errors, :status => :unprocessable_entity }
			end
		end
	end

#	def destroy
#		@genotype = Genotype.find(params[:id])
#		@genotype.destroy

#		respond_to do |format|
#			format.html { redirect_to(genotypes_url) }
#			format.xml	{ head :ok }
#		end
#	end
end

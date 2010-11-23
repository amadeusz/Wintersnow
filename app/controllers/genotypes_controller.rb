class GenotypesController < ApplicationController

	def index
		@new_genotype = Genotype.new
		@genotypes = Genotype.all

		respond_to do |format|
			format.html
			format.xml	{ render :xml => @genotypes }
		end
	end

	def show
		@genotype = Genotype.find(params[:id])

		respond_to do |format|
			format.html
			format.xml	{ render :xml => @genotype }
		end
	end

	def new
		@genotype = Genotype.new

		respond_to do |format|
			format.html
			format.xml	{ render :xml => @genotype }
		end
	end

	def edit
		@genotype = Genotype.find(params[:id])
	end

	def create
		@genotype = Genotype.new(params[:genotype])

		respond_to do |format|
			if @genotype.save
				format.html { redirect_to(genotypes_path, :notice => 'Genotype was successfully created.') }
				format.xml	{ render :xml => @genotype, :status => :created, :location => @genotype }
			else
				format.html { render :action => "new" }
				format.xml	{ render :xml => @genotype.errors, :status => :unprocessable_entity }
			end
		end
	end

	def update
		@genotype = Genotype.find(params[:id])

		respond_to do |format|
			if @genotype.update_attributes(params[:genotype])
				format.html { redirect_to(genotypes_path, :notice => 'Genotype was successfully updated.') }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @genotype.errors, :status => :unprocessable_entity }
			end
		end
	end

	def destroy
		@genotype = Genotype.find(params[:id])
		@genotype.destroy

		respond_to do |format|
			format.html { redirect_to(genotypes_url) }
			format.xml	{ head :ok }
		end
	end
	
end

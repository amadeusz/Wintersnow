class GenotypesController < ApplicationController
	# GET /genotypes
	# GET /genotypes.xml
	def index
		@new_genotype = Genotype.new
		@genotypes = Genotype.all

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @genotypes }
		end
	end

	# GET /genotypes/1
	# GET /genotypes/1.xml
	def show
		@genotype = Genotype.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @genotype }
		end
	end

	# GET /genotypes/new
	# GET /genotypes/new.xml
	def new
		@genotype = Genotype.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @genotype }
		end
	end

	# GET /genotypes/1/edit
	def edit
		@genotype = Genotype.find(params[:id])
	end

	# POST /genotypes
	# POST /genotypes.xml
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

	# PUT /genotypes/1
	# PUT /genotypes/1.xml
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

	# DELETE /genotypes/1
	# DELETE /genotypes/1.xml
	def destroy
		@genotype = Genotype.find(params[:id])
		@genotype.destroy

		respond_to do |format|
			format.html { redirect_to(genotypes_url) }
			format.xml	{ head :ok }
		end
	end
end

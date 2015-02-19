class ApiController < ApplicationController

	def random
		 cat =Cat.public.order('RANDOM()').first
		 render(json: cat)
	end

  def index
    cats = Cat.public.all
    render(json: cats)
  end

   def show
	   	errors = {:no_cat => "404 not found"}
		cat = Cat.public_info.find_by(id: params[:id])
	    if !cat
	    	render(json: errors, status: 404)
		else
			render(json: cat)
		end
	end


end

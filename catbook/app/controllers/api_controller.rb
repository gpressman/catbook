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
    cat = Cat.public.find_by(id: params[:id])
    render(json: cat)
   end


end

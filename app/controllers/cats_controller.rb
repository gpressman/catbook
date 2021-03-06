class CatsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :load_cat_of_the_month, only: :index
  before_action :load_cat, only: [:show, :edit, :update]
  # before_action :retrieve_cat_user, only: [ :index,  :edit_cat_user, :edit, :show, :update, :destroy]
  # before_action :redirect_logged_in, only: [ :new, :create, :login, :authenticate]
  before_action :cant_edit_other_cats, only: [:edit, :update]
  before_action :authenticate_cat!, except: [ :new,  :create, :login, :authenticate ]
  def index
    page  = params[:page].to_i || 1

   
        # page scope is provided by kamikari gem
    # https://github.com/amatsuda/kaminari/blob/master/lib/kaminari/models/active_record_model_extension.rb#L13
    @cats = Cat.visible.select(:id, :name, :birthday).page(page)
  end

  def api_index
    cats = Cat.visible.select(:id, :name, :birthday).all
    render(json: cats)
  end
 
  def new
    @cat = Cat.new

  end



  def create
    @new_cat_info=params.require(:cat).permit(:name, :email, :password)
    @cat = Cat.new(@new_cat_info)

    if !@cat.save 
      render ('new')
     else 
  redirect_to(login_path)
    end
  end

  def login
  @cat = Cat.new
  end

  def authenticate
    

    cat_login = params.require(:cat).permit(:email, :password)
    cat =Cat.find_by(email: cat_login[:email]).try(:authenticate, cat_login[:password])
    
    
    if !cat
      @cat=Cat.new(email: cat_login[:email])
      render('login')
    else
      session[:cat_id] = cat.id
      redirect_to(cats_path)
    end
  end


  def show
    cat = Cat.find_by(id: params[:id])
    render(json: [cat.name, cat.id, cat.birthday])
  end

  def edit
  end

  def edit_cat_user
    @cat = @cat_user
    render('edit')
  end

  def update

    if params[:id].to_i != current_cat.id
      redirect_to(edit_cat_user_path)
    
    elsif @cat.update(cats_params)
      flash[:notice] = "Cat updated successfully"

      redirect_to cat_path(@cat)
    else
      flash[:error]  = "Ops! We couldn't update the cat, please review the errors"

      render :edit
    end
  end

  def random
    # id
    # name
    # email
    # sign_in_count
    # breed
    cat =Cat.select(:id, :name, :email, :sign_in_count, :breed).order('RANDOM()').first

    render(json: cat)

  end





  private

  def load_cat
    @cat = Cat.where(id: params[:id]).visible.first

    render text: 'Not Found', status: '404' unless @cat
  end

  def cats_params
    { visible: true }.merge(params[:cat])
  end

  # Do you think this is a good place to put this logic?
  # Where would you move it?
  def load_cat_of_the_month
    month = DateTime.now.last_month.strftime('%Y-%B')
    @cat_of_the_month = Rails.cache.fetch("cat-of-the-month/#{month}", expires_in: 1.month) do

    last_month_follower_relation = FollowerRelation.where("EXTRACT(MONTH FROM created_at) = ? AND EXTRACT(YEAR FROM created_at) = ?", 1.month.ago.month, 1.month.ago.year)

    

    # First alternative
    # Retrieve results from database without order and use ruby function to order hash
    count_of_followers = last_month_follower_relation.group(:followed_cat_id).count
    # http://www.rubyinside.com/how-to/ruby-sort-hash
    cat_of_the_month_data = count_of_followers.sort_by { |k, v| -v }.first
    Cat.find(cat_of_the_month_data.first) if cat_of_the_month_data

    # # Second alternative
    # # Order the results with SQL query an retrieve one result
    # # I just googled "Order by group by count" to find this solution
    # cat_of_month_id = last_month_follower_relation.
    #   group(:followed_cat_id).
    #   select("followed_cat_id, COUNT(*) as followers_count").
    #   order("followers_count DESC").
    #   limit(1).first.try(:followed_cat_id)
    #
    # # http://apidock.com/rails/Object/try
    #
    # @cat_of_the_month = Cat.find(cat_of_month_id) if cat_of_month_id
   end
  end


  def cant_edit_other_cats
    unless params[:id].to_i == current_cat.id
      redirect_to(edit_cat_user_path)
    end
  end

  def retrieve_cat_user
    @cat_user = Cat.find_by(id: session[:cat_id])
    if @cat_user.nil?
      redirect_to(login_path)
    end
  end

  def redirect_logged_in
    @cat_user = Cat.find_by(id: session[:cat_id])
    if @cat_user.present?
      redirect_to(cats_path)
    end
  end
end

class UsersController < ApplicationController

  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :current_user?, only: [:edit, :destroy]

  def index
    if User.find_by(id: session[:user_id])
      @users = User.all
    else
      @users = User.where(merchant: true)
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
  end

  def show
      @user = User.find_by(id: params[:id])
  end

  def edit
    unless current_user?
      redirect_to root_path, :alert => "Members Only"
    end
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_path(@user.id)
      flash[:success] = "Successfully updated, you go Glen Coco! \u{1F389}"
    else
      render :edit, status: :bad_request
    end
  end

  def destroy
    if current_user?
      @user.destroy
      flash[:status] = :success
      flash[:result_text] = "Successfully destroyed #{@user.singularize} #{@user.id} \u{1F4A5}"
      redirect_to root_path
    else
      flash[:error] = "Must be logged in as this loser to do that."
      redirect_to root_path
    end
  else
    flash[:error] = "Members Only"
    redirect_to root_path
  end

  def userdash
    @products = @logged_in_user.products
    @orders = @logged_in_user.orders
  end

  def manage_orders
    @orders = @logged_in_user.merchant_orders

    if params[:status] == ""
      @title = "all_orders"
    elsif params[:status]
      @title = params[:status]
    else
      @title = "all_orders"
    end

    if params[:status] == "pending"
      @my_orders = @orders.where(status: "paid")
    elsif params[:status] == "shipped"
      @my_orders = @orders.where(status: "shipped")
    else
      @my_orders = @orders
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :username, :email, :merchant, :store_name, :store_banner_img, :store_location, :store_description, :bio)
  end
  def find_user
    @user = User.find_by(id: params[:id])
  end
  def current_user?
    @user == User.find_by(id: session[:user_id])
  end
end

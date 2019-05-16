class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    harrisGraphData = @user.calculate_harris_graph_data
    bookerGraphData = @user.calculate_booker_graph_data
    warrenGraphData = @user.calculate_warren_graph_data
    render json: { harrisGraphData: harrisGraphData, bookerGraphData: bookerGraphData, warrenGraphData: warrenGraphData }
  end

  # POST /users
  def create
    @user = User.find_or_initialize_by(user_params)
    @user.calculate_fmr unless @user.fmr
    @user.calculate_median_income unless @user.median_income
    if @user.save
      warren, bookerCredit, harrisCredit = nil, nil, nil
      begin
        warren = @user.qualifies_for_warren?
        bookerCredit = @user.calculate_booker_credit
        harrisCredit = @user.calculate_harris_credit
      rescue
        @user.errors.add(:credits, "are not available because of an error with @user.median_income")
      end
      if @user.errors.messages.empty?
        render json: @user.attributes.merge({ warren: warren, bookerCredit: bookerCredit, harrisCredit: harrisCredit }), status: :created, location: @user
      else
        render json: @user.errors, status: :error
      end
    else
      render json: @user.errors, status: :error
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      puts params
      params.require(:user).permit(:ip_address, :zipcode, :salary, :rent_cost, :utilities, :bedrooms)
    end
end

class JogsController < ApplicationController
  before_action :require_login # ログイン必須にする

  # その人のジョグ記録表示
  def index
    @user = User.find(params[:user_id])
    @jogs = Jog.where(shoe_id: @user.shoes.pluck(:id)).order(date: :desc)
  end

  def new
    @jog = Jog.new
    @shoes = current_user.shoes
  end

  def create
    @jog = Jog.new(jog_params)

    if @jog.save
      redirect_to user_jogs_path(current_user), notice: "ランニング記録を保存しました！"
    else
      @shoes = current_user.shoes
      flash.now[:danger] = "保存に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def jog_params
    params.require(:jog).permit(
      :shoe_id, :date, :distance, :heart_rate, 
      :time_hour, :time_minute, :time_second, :pace_minute, :pace_second, :memo
    )
  end
end
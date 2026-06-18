class JogsController < ApplicationController
  before_action :require_login # ログイン必須にする

  # その人のジョグ記録を新しい順に表示
  def index
    @user = User.find(params[:user_id])
    @jogs = Jog.where(shoe_id: @user.shoes.pluck(:id)).order(date: :desc, id: :desc)
  end

  def new
    @user = User.find(params[:user_id])
    @jog = Jog.new
    @shoes = @user.shoes
  end

  def create
    @user = User.find(params[:user_id])
    @jog = Jog.new(jog_params)

    if @jog.save
      redirect_to user_jogs_path(@user), notice: "ランニングを記録しました！"
    else
      @shoes = @user.shoes
      flash.now[:danger] = "保存に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
  @jog = Jog.find(params[:id])
  
  # 自分の靴（データ）の記録、または自分のログであるかを確認して削除
  if @jog.shoe.user_id == current_user.id
    @jog.destroy
    redirect_to user_jogs_path(user_id: current_user.id), notice: 'ランニング記録を削除しました。'
  else
    redirect_to root_path, alert: '他のユーザーの記録は削除できません。'
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
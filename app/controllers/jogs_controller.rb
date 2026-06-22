class JogsController < ApplicationController
  before_action :require_login # ログイン必須にする

  # その人のジョグ記録を表示（月ごとの絞り込み機能つき）
  def index
    @user = User.find(params[:user_id])
    base_jogs = Jog.where(shoe_id: @user.shoes.pluck(:id)).order(date: :desc, id: :desc)

    # 1. タブに表示するための「記録が存在する月」のリストを作成（重複排除して新しい順）
    @available_months = base_jogs.pluck(:date).compact.map(&:beginning_of_month).uniq.sort.reverse

    # 2. URLのパラメータ（?month=2026-06など）があればその月を、なければ「今月」を選択状態にする
    if params[:month].present?
      @selected_month = Date.parse(params[:month] + "-01")
    else
      @selected_month = Date.current.beginning_of_month
    end

    # 3. 選択された月（1日〜月末）のデータだけに絞り込んでビューに渡す
    @jogs = base_jogs.where(date: @selected_month.all_month)
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

  def edit
    @user = User.find(params[:user_id])
    @jog = Jog.find(params[:id])
  end

  def update
    @user = User.find(params[:user_id])
    @jog = Jog.find(params[:id])
    
    # 変更前の「古い距離」と「古いシューズ」をキープしておく
    old_distance = @jog.distance.to_f
    old_shoe = @jog.shoe
    
    if @jog.update(jog_params)
      # ① まず、編集前の古いシューズの累計距離から、古いジョグの距離を引く
      if old_shoe
        old_shoe.update(total_distance: old_shoe.total_distance.to_f - old_distance)
      end
      
      # ② 次に、編集後の新しいシューズ（同じ靴でもOK）に、新しいジョグの距離を足す
      new_shoe = @jog.shoe
      if new_shoe
        new_shoe.update(total_distance: new_shoe.total_distance.to_f + @jog.distance.to_f)
      end

      redirect_to user_jogs_path(@user), notice: "走行記録を更新しました！"
    else
      render :edit, status: :unprocessable_entity
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
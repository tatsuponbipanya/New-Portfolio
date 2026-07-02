class JogsController < ApplicationController
  before_action :require_login # ログイン必須にする

  # その人のジョグ記録を表示（月ごとの絞り込み機能つき）
  def index
    @user = User.find(params[:user_id])
    base_jogs = Jog.includes(:shoe).where(shoe_id: @user.shoes.pluck(:id)).order(date: :desc, id: :desc)

    # 1. タブに表示するための「記録が存在する月」のリストを作成（nilと重複を排除して新しい順）
    @available_months = base_jogs.pluck(:date).compact.map(&:beginning_of_month).uniq.sort.reverse

    # 2. URLのパラメータ（?month=2026-06など）があればその月を、なければ「今月」を選択状態にする
    @selected_month = if params[:month].present?
                        Date.parse(params[:month] + '-01')
                      elsif @available_months.include?(Date.current.beginning_of_month)
                        Date.current.beginning_of_month
                      else
                        @available_months.first || Date.current.beginning_of_month
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
      redirect_to user_jogs_path(@user), notice: 'ランニングを記録しました！'
    else
      @shoes = @user.shoes
      flash.now[:danger] = '保存に失敗しました。'
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
      old_shoe.update(total_distance: old_shoe.total_distance.to_f - old_distance) if old_shoe

      # ② 次に、編集後の新しいシューズ（同じ靴でもOK）に、新しいジョグの距離を足す
      new_shoe = @jog.shoe
      new_shoe.update(total_distance: new_shoe.total_distance.to_f + @jog.distance.to_f) if new_shoe

      redirect_to user_jogs_path(@user), notice: '走行記録を更新しました！'
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

  # 年間記録
  def annual
    @user = User.find(params[:user_id])
    base_jogs = Jog.where(shoe_id: @user.shoes.pluck(:id))

    # 1. 記録が存在する「年」のリストを作成（降順）
    @available_years = base_jogs.pluck(:date).compact.map(&:year).uniq.sort.reverse

    # 2. URLのパラメータ（?year=2026など）があればその年、なければ「今年」を選択
    @selected_year = params[:year].present? ? params[:year].to_i : Date.current.year

    # 3. 選択された1年分のデータを取得
    @jogs_of_year = base_jogs.where(date: Date.new(@selected_year, 1, 1)..Date.new(@selected_year, 12, 31))

    # 4. 年間の合計距離・時間を計算
    @total_distance = @jogs_of_year.sum(&:distance).round(2)
    total_seconds = @jogs_of_year.sum { |j| (j.time_hour.to_i * 3600) + (j.time_minute.to_i * 60) + j.time_second.to_i }
    @total_h = total_seconds / 3600
    @total_m = (total_seconds % 3600) / 60
    @total_s = total_seconds % 60

    # 5. 折れ線グラフ用のデータ作成（1月〜12月）
    monthly_data = @jogs_of_year.group_by { |j| j.date.month }

    # グラフを2つに分けるためのハッシュを用意
    @distance_chart_data = {}
    @time_chart_data = {}

    (1..12).each do |month|
      jogs_in_month = monthly_data[month] || []

      # その月の合計距離 (km)
      @distance_chart_data["#{month}月"] = jogs_in_month.sum(&:distance).round(2)

      # その月の合計時間 (分)
      @time_chart_data["#{month}月"] = jogs_in_month.sum do |j|
        (j.time_hour.to_i * 60) + j.time_minute.to_i + (j.time_second.to_f / 60)
      end.round(1)
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

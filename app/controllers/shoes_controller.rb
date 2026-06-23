class ShoesController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @shoes = @user.shoes.order(created_at: :desc)
  end

  def new
    @shoe = Shoe.new
  end

  def create
    @shoe = Shoe.new(shoe_params)
    @shoe.user_id = current_user.id

    # シューズの寿命は、500.0kmに設定
    @shoe.target_distance = 500.0

    # もし現在の走行距離が未入力（nilか空文字）なら、自動的に 0.0 をセットする
    @shoe.total_distance = 0.0 if @shoe.total_distance.blank?

    if @shoe.save
      flash[:success] = '新しいシューズを登録しました。'
      redirect_to user_shoes_path(current_user)
    else
      flash.now[:danger] = '登録に失敗しました。入力欄を確認してください。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @shoe = current_user.shoes.find(params[:id])
  end

  def update
    @shoe = current_user.shoes.find(params[:id])
    # ストロングパラメータ（shoe_params）を使って安全に更新
    if @shoe.update(shoe_params)
      redirect_to user_shoes_path(current_user), notice: 'シューズの情報を更新しました！'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shoe = current_user.shoes.find(params[:id])
    @shoe.destroy
    flash[:success] = 'シューズを削除しました。'
    redirect_to user_shoes_path(current_user), status: :see_other

  # 他ユーザーの靴IDを直接指定し、削除しようとした場合のガード
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '指定されたシューズが見つからないか、削除する権限がありません。', status: :see_other
  end

  private

  # 安全にデータを受け取るためのストロングパラメーター
  def shoe_params
    params.require(:shoe).permit(:name, :total_distance, :target_distance, :size, :width, :bought_on)
  end
end

require 'rails_helper'

RSpec.describe WorkoutForm, type: :model do
  let(:user) do
    User.create!(
      name: 'たつマジロ',
      email: 'test@example.com',
      password: 'password123'
    )
  end

  # バリデーションの「.values」や「set[:weight]」が100%正常に動くハッシュの形にする
  let(:valid_attributes) do
    {
      user_id: user.id,
      workout_date: Time.current,
      menu_type: 'ベンチプレス',
      sets_attributes: {
        0 => { weight: '83.0', reps: '5' },
        1 => { weight: '83.0', reps: '5' },
        2 => { weight: '83.0', reps: '4' }
      }
    }
  end

  describe '#save' do
    context '正しいデータが入力されているとき' do
      it '保存に成功すること' do
        form = WorkoutForm.new(valid_attributes)
        result = form.save

        unless result
          puts "\n=================================================="
          puts '【まだエラーが出る場合の生内容】'
          puts form.errors.full_messages
          puts "==================================================\n"
        end

        expect(result).to be true
      end

      it '実際にWorkoutLogのデータが3個増えること' do
        form = WorkoutForm.new(valid_attributes)
        expect { form.save }.to change(WorkoutLog, :count).by(3)
      end
    end

    context '不正なデータ（日付やメニューが空など）のとき' do
      let(:invalid_attributes) do
        {
          user_id: user.id,
          workout_date: '',
          menu_type: '',
          sets_attributes: {
            0 => { weight: '', reps: '' }
          }
        }
      end

      it '保存に失敗すること' do
        form = WorkoutForm.new(invalid_attributes)
        expect(form.save).to be false
      end
    end
  end
end

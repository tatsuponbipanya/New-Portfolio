require 'rails_helper'

RSpec.describe WorkoutForm, type: :model do

  let(:user) do
    User.create!(
      name: 'たつマジロ',
      email: 'test@example.com',
      password: 'password123',
    )
  end

  # RSpecのルールで、valid_attributes という名前の中に、このデータの塊（ハッシュ）を覚えさせておくという命令
  # valid（有効な、正しい、バリデーションを通る）
  # attributes（属性、入力項目のデータ）
  let(:valid_attributes) do
    {
      user_id: user.id,
      workout_date: Time.current,
      menu_type: 'ベンチプレス',
      sets_attributes: {
        '0' => { weight: '60', reps: '5' },
        '1' => { weight: '83', reps: '1' }
      }
    }
  end

  describe '#save' do
    context '正しいデータが入力されているとき' do
      it '保存に成功すること' do
        form = WorkoutForm.new(valid_attributes)
        result = form.save
        
        # もしこれでもWorkoutLog側でエラーが出る場合は、生のメッセージを出す
        unless result
          puts "WorkoutLogの生エラーメッセージ内容：#{form.errors.instance_variable_get(:@errors)&.map(&:message)}"
        end

        expect(result).to be true
      end

      it '実際にWorkoutLogのデータが2個増えること' do
        form = WorkoutForm.new(valid_attributes)
        expect { form.save }.to change(WorkoutLog, :count).by(2)
      end
    end
  end
end
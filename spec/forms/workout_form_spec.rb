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

    context '重量だけ・回数だけの片方入力があるとき' do
      # 重量はあるが回数が空 → blank_reps のエラーになること
      it '回数が空だと保存に失敗し、該当セットのエラーが出ること' do
        form = WorkoutForm.new(
          valid_attributes.merge(
            sets_attributes: { 0 => { weight: '80.0', reps: '' } }
          )
        )
        expect(form.save).to be false
        expect(form.errors[:base]).to include('1セット目の回数を入力してください')
      end

      # 回数はあるが重量が空 → blank_weight のエラーになること
      it '重量が空だと保存に失敗し、該当セットのエラーが出ること' do
        form = WorkoutForm.new(
          valid_attributes.merge(
            sets_attributes: { 0 => { weight: '', reps: '5' } }
          )
        )
        expect(form.save).to be false
        expect(form.errors[:base]).to include('1セット目の重量を入力してください')
      end
    end

    context '入力済みのセットと空のセットが混在するとき' do
      # 両方空のセットはスキップされ、埋まっているセットだけ保存されること
      it '空セットはスキップされ、埋まっているセットのみ保存されること' do
        form = WorkoutForm.new(
          valid_attributes.merge(
            sets_attributes: {
              0 => { weight: '83.0', reps: '5' },
              1 => { weight: '', reps: '' },
              2 => { weight: '80.0', reps: '6' }
            }
          )
        )
        expect { form.save }.to change(WorkoutLog, :count).by(2)
      end
    end

    context '保存途中でDBのバリデーション違反が起きたとき' do
      # 1セット目は正常、2セット目は reps=0 で WorkoutLog のバリデーション違反 →
      # トランザクションで全てロールバックされ、1件も保存されないこと
      it 'トランザクションで全てロールバックされ1件も保存されないこと' do
        form = WorkoutForm.new(
          valid_attributes.merge(
            sets_attributes: {
              0 => { weight: '83.0', reps: '5' },
              1 => { weight: '80.0', reps: '0' }
            }
          )
        )
        expect { form.save }.not_to change(WorkoutLog, :count)
        expect(form.save).to be false
      end
    end
  end

  # === テンプレート上書き保存（update_template）のテスト ===
  describe 'テンプレートの上書き保存' do
    # テンプレートと既存の2セットを用意する
    let(:template) do
      t = user.workout_templates.create!(name: 'マイベンチ')
      t.workout_template_sets.create!(menu_type: 'ベンチプレス', step_number: 1, default_weight: 60, default_reps: 10)
      t.workout_template_sets.create!(menu_type: 'ベンチプレス', step_number: 2, default_weight: 60, default_reps: 8)
      t
    end

    # update_template が true のとき、テンプレートの中身が今回の入力で書き換わること
    it 'update_templateが有効なとき既存セットが入力内容で更新されること' do
      form = WorkoutForm.new(
        valid_attributes.merge(
          template_id: template.id,
          update_template: true,
          sets_attributes: {
            0 => { weight: '90.0', reps: '5' },
            1 => { weight: '85.0', reps: '5' }
          }
        )
      )
      expect(form.save).to be true

      sets = template.workout_template_sets.order(:step_number)
      expect(sets.map(&:default_weight)).to eq [90.0, 85.0]
      expect(sets.map(&:default_reps)).to eq [5, 5]
    end

    # 入力セット数が減った場合、余ったテンプレートセットが削除されること
    it 'セット数が減った場合は余分なテンプレートセットが削除されること' do
      form = WorkoutForm.new(
        valid_attributes.merge(
          template_id: template.id,
          update_template: true,
          sets_attributes: { 0 => { weight: '100.0', reps: '3' } }
        )
      )
      expect { form.save }.to change { template.workout_template_sets.count }.from(2).to(1)
    end

    # update_template が false のときはテンプレートを書き換えないこと
    it 'update_templateが無効なときはテンプレートを変更しないこと' do
      original = template.workout_template_sets.order(:step_number).map(&:default_weight)
      form = WorkoutForm.new(
        valid_attributes.merge(
          template_id: template.id,
          update_template: false,
          sets_attributes: { 0 => { weight: '90.0', reps: '5' } }
        )
      )
      expect(form.save).to be true
      expect(template.workout_template_sets.order(:step_number).map(&:default_weight)).to eq original
    end
  end
end

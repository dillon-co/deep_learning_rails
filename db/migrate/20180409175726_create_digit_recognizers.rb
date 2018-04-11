class CreateDigitRecognizers < ActiveRecord::Migration[5.0]
  def change
    create_table :digit_recognizers do |t|

      t.integer :real_name
      t.integer :guess
      t.string :image_file_path
      t.string :image_file_name

      t.timestamps
    end
  end
end

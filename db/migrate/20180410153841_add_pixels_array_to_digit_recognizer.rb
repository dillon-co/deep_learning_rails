class AddPixelsArrayToDigitRecognizer < ActiveRecord::Migration[5.0]
  def change
    add_column :digit_recognizers, :pixels, :text, array: true, default: []
  end
end

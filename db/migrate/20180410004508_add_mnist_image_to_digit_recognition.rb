class AddMnistImageToDigitRecognition < ActiveRecord::Migration[5.0]
  def up
    add_attachment :digit_recognizers, :mnist_image
  end

  def down
    remove_attachment :digit_recognizers, :mnist_image
  end
end

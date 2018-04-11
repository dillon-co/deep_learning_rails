require 'pycall/import'
require 'RMagick'
include PyCall::Import
class DigitRecognizer < ApplicationRecord
  include Magick
  extend PyCall::Import

  has_attached_file :mnist_image, styles: {thumb: "28x28>", regular: "280x280>"}, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :mnist_image, content_type: /\Aimage\/.*\z/

   serialize :parties

  def mnist
    input_data.read_data_sets("/tmp/data", one_hot = True)
  end

  def hidden_dimensions
    500
  end

  def input_dimentions
    784
  end

  def batch_size
    100
  end

  def num_classes
    10
  end

  def x_placeholder
    tf.placeholder(tf.float32, [nil, input_dimentions],name:'nn_input_data')
  end

  def y_placeholder
    tf.placeholder(tf.float32, [nil, num_classes], name:'labels')
  end

  def neural_network_model(x, tf)
    puts "before the weights initializing works"
    hidden_layer_1 = {weights: tf.Variable.new(tf.random_normal([784, 800])),
                      biases: tf.Variable.new(tf.random_normal([800]))
                      }

    hidden_layer_2 = {weights: tf.Variable.new(tf.random_normal([800, 800])),
                       biases: tf.Variable.new(tf.random_normal([800]))
                      }
    # hidden_layer_3 = {weights: tf.Variable.new(tf.random_normal([784, 500])),
    #                    biases: tf.Variable.new(tf.random_normal([500]))
    #                   }

    output_layer = {weights: tf.Variable.new(tf.random_normal([800, 10])),
                    biases: tf.Variable.new(tf.random_normal([10]))
                    }

    puts 'weight initializing successful'
    # ba means 'before activation'
    print "running feed forward"
    layer_1_ba = tf.add(tf.matmul(x, hidden_layer_1[:weights]), hidden_layer_1[:biases])
    activated_layer_1 = tf.nn.relu(layer_1_ba)

    puts "layer 1 successful"

    layer_2_ba = tf.add(tf.matmul(activated_layer_1, hidden_layer_2[:weights]), hidden_layer_2[:biases])
    activated_layer_2 = tf.nn.relu(layer_2_ba)
    puts "layer 2 successful"

    # layer_3_ba = tf.add(tf.matmul(activated_layer_2, hidden_layer_3[:weights]), hidden_layer_3[:biases])
    # activated_layer_3 = tf.nn.sigmoid(layer_3_ba)

    puts "layer 3 successful"
    output = tf.add(tf.matmul(activated_layer_2, output_layer[:weights]), output_layer[:biases], name='nn_prediction')
    tf.global_variables
    puts "output successful"
    output
  end

  def train_neural_network(x, y, tf, input_data)
    puts "Running prediction\n\n"
    # tf.reset_default_graph
    prediction = neural_network_model(x, tf)
    puts "\n\nprediction successful\n\n"
    cost = tf.nn.softmax_cross_entropy_with_logits(logits: prediction, labels: y)
    optimizer = tf.train.AdamOptimizer.new().minimize(cost)

    puts 'optimizer initialization successful'
    mnist = input_data.read_data_sets("/tmp/data", one_hot: true)
    init = tf.global_variables_initializer()
    saver = tf.train.Saver.new

    sess = tf.Session.new()
    sess.run(init)

    num_epochs = 10
    num_epochs.times do |epoch_num|
      puts "epoch #{epoch_num+1}"
      epoch_loss = 0
      number_of_batches = (mnist.train.num_examples/batch_size)
      number_of_batches.times do |batch_number|
        batch = mnist.train.next_batch(batch_size)
        epoch_x, epoch_y = batch[0], batch[1]
        # puts epoch_x.shape
        opt, loss = sess.run([optimizer, cost], feed_dict:{y=>epoch_y, x=> epoch_x})
        epoch_loss += loss
        # if sess.run(tf.reduce_mean(epoch_loss) < 15)
        #   break
        # end
      end
      puts "Epoch #{epoch_num+1} completed out of #{num_epochs}.\n loss: #{sess.run(tf.reduce_mean(epoch_loss))}"
    end

    correct = tf.equal(tf.argmax(prediction,1), tf.argmax(y,1))
    accuracy = tf.reduce_mean(tf.cast(correct, 'float'))
    puts "Accuracy: #{sess.run(accuracy, feed_dict:{x=>mnist.test.images, y=>mnist.test.labels})}"
    saver.save(sess, './mnist_model')
  end

  def train_and_save_model
    # puts :tf
    pyimport 'tensorflow', as: 'tf'
    pyfrom 'tensorflow.examples.tutorials.mnist', import: 'input_data'
    puts "pyimports ready"
    tf.reset_default_graph
    train_neural_network(x_placeholder,  y_placeholder, tf, input_data)
  end

  def get_pixel_values_from_image
    img = ImageList.new("#{Rails.root}/public#{self.mnist_image.url(:thumb).split('?').first}")
    pixels = []
    img.each_pixel do |pix, c, r|
        r = pix.red/257
        g = pix.green/257
        b = pix.blue/257

        grayscale_val = (r+g+b).to_f/3
        pixels << grayscale_val
    end
    pixels
  end

  def classify_image
    pyimport 'tensorflow', as: 'tf'
    pyimport 'numpy', as: 'np'


    old_pixels = np.array(get_pixel_values_from_image)
    image_pixels = old_pixels.reshape([-1, 784]).astype(np.float32)


    sess = tf.Session.new
    puts "session started"
    sess.run(tf.global_variables_initializer)

    saver = tf.train.import_meta_graph("#{Rails.root}/mnist_model.meta")
    saver.restore(sess, tf.train.latest_checkpoint("#{Rails.root}/"))
    graph = tf.get_default_graph
    x = graph.get_tensor_by_name('nn_input_data:-0')
    prediction = graph.get_tensor_by_name("nn_prediction:-0")
    puts "model loaded"

    # puts "model restored"
    pred = sess.run(prediction, feed_dict:{x=>image_pixels})
    puts pred
    puts "\n\n\n\n\nprediction is #{np.argmax(pred, 1)[0]}\n\n\n\n\n"

    self.update(guess: np.argmax(pred, 1)[0])

  end



  def train_then_classify
    train_and_save_model
    classify_image
  end

end

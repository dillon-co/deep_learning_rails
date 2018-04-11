require 'RMagick'
include Magick
class DigitRecognizersController < ApplicationController
  before_action :set_digit_recognizer, only: [:show, :edit, :update, :destroy]

  # GET /digit_recognizers
  # GET /digit_recognizers.json
  def index
    @digit_recognizers = DigitRecognizer.all
  end

  # GET /digit_recognizers/1
  # GET /digit_recognizers/1.json
  def show
    @digit_recognizer = DigitRecognizer.find(params[:id])
  end

  # GET /digit_recognizers/new
  def new
    @digit_recognizer = DigitRecognizer.new
  end


  # GET /digit_recognizers/1/edit
  def edit
  end

  # POST /digit_recognizers
  # POST /digit_recognizers.json
  def create
    @digit_recognizer = DigitRecognizer.new(digit_recognizer_params)
    # @digit_recognizer.classify_image
    respond_to do |format|
      if @digit_recognizer.save
        @digit_recognizer.classify_image
        format.html { redirect_to @digit_recognizer, notice: 'Digit recognizer was successfully created.' }
        format.json { render :show, status: :created, location: @digit_recognizer }
      else
        format.html { render :new }
        format.json { render json: @digit_recognizer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /digit_recognizers/1
  # PATCH/PUT /digit_recognizers/1.json
  def update
    respond_to do |format|
      if @digit_recognizer.update(digit_recognizer_params)
        format.html { redirect_to @digit_recognizer, notice: 'Digit recognizer was successfully updated.' }
        format.json { render :show, status: :ok, location: @digit_recognizer }
      else
        format.html { render :edit }
        format.json { render json: @digit_recognizer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /digit_recognizers/1
  # DELETE /digit_recognizers/1.json
  def destroy
    @digit_recognizer.destroy
    respond_to do |format|
      format.html { redirect_to digit_recognizers_url, notice: 'Digit recognizer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_digit_recognizer
      @digit_recognizer = DigitRecognizer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def digit_recognizer_params
      params.require(:digit_recognizer).permit(:mnist_image)
    end

    def add_pixel_value(digit_recognizer)
      pixels = []
      img= ImageList.new(digit_recognizer.mnist_image.url(:thumb))
      img.each_pixel do |pix, c, r|
          puts pix
      end
    end
end

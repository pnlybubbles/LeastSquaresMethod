# encoding: utf-8

require "sinatra"
require "base64"
require "json"

class Sample < Sinatra::Base
  get "/" do
    if params[:type] == "base64"
      @data = Base64.decode64(params[:data]).split("\n").join(":")
    elsif params[:type] == "plain"
      @data = params[:data]
    end
    @debug_area = params.to_s
    @fewer_inputs = false
    if @data && @data.empty?.!
      @input_area = @data.split(":").join("\n")
      @x = @data.split(":").map { |v| v.split(",")[0].to_f }
      @y = @data.split(":").map { |v| v.split(",")[1].to_f }
      @n = @x.length
      if @n <= 2
        @fewer_inputs = true
      else
        @x_sum = @x.inject(:+)
        @x_sq_sum = @x.map { |v| v ** 2 }.inject(:+)
        @y_sum = @y.inject(:+)
        @x_sum_y_sum = (0...@n).map { |i| @x[i] * @y[i] }.inject(:+)
        @det = (@n * @x_sq_sum) - (@x_sum ** 2)
        @a = ((@y_sum * @x_sq_sum) - (@x_sum * @x_sum_y_sum)) / @det
        @b = ((@n * @x_sum_y_sum) - (@x_sum * @y_sum)) / @det
        @y_a_bx_sum = (0...@n).map { |i| (@y[i] - @a - @b * @x[i]) ** 2 }.inject(:+)
        @sig_y = Math.sqrt(Rational(1, (@n - 2)).to_f * @y_a_bx_sum)
        @sig_a = @sig_y * Math.sqrt((1 / @det) * @x_sq_sum)
        @sig_b = @sig_y * Math.sqrt(@n / @det)
        @plot_data = JSON.generate(@x.zip(@y))
      end
    end
    erb :index
  end

  get "/about" do
    erb :about
  end

  get "/help" do
    erb :help
  end
end

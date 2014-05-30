# encoding: utf-8

require "sinatra"
require "base64"
require "json"
require 'bigdecimal'

class Sample < Sinatra::Base
  get "/" do
    if params[:type] == "base64"
      @data = Base64.decode64(params[:data]).split("\n").join(":")
    elsif params[:type] == "plain"
      @data = params[:data]
    end
    if params[:scale] && params[:scale] != ""
      @scale = params[:scale].to_i
    else
      @scale = 10
    end
    @debug_area = params.to_s
    @fewer_inputs = false
    if @data && @data.empty?.!
      @input_area = @data.split(":").join("\n")
      @x = @data.split(":").map { |v| BigDecimal(v.split(",")[0]) }
      @y = @data.split(":").map { |v| BigDecimal(v.split(",")[1]) }
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
        @sig_y = (Rational(1, (@n - 2)) * @y_a_bx_sum) ** Rational(1, 2)
        @sig_a = @sig_y * (((1 / @det) * @x_sq_sum) ** Rational(1, 2))
        @sig_b = @sig_y * ((@n / @det) ** Rational(1, 2))
        # @plot_data = JSON.generate(@x.map { |v| v.to_s("f") }.zip(@y.map { |v| v.to_s("f") }))
        @plot_data = JSON.generate(@x.map(&:to_f).zip(@y.map(&:to_f)))
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

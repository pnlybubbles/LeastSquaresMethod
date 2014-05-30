# encoding: utf-8

require "sinatra"
require "base64"
require "json"
require 'bigdecimal'

class Worker < Sinatra::Base
  get "/" do
    @error = []
    @debug = []
    @debug << params.to_s
    if params[:type] == "base64"
      begin
        @data = Base64.decode64(params[:data]).split("\n").join(":")
      rescue Exception => e
        @error << :decode64_error
        @debug << e.to_s
      end
    elsif params[:type] == "plain"
      @data = params[:data]
    end
    @scale = 10
    if params[:scale] && params[:scale] != ""
      if params[:scale] =~ /[0-9]+/
        @scale = params[:scale].to_i
      else
        @error << :scale_nan
      end
    end
    @input_area = (@data || "").split(":").join("\n")
    if @data && @data.empty?.!
      begin
        @x = @data.split(":").map { |v| BigDecimal(v.split(",")[0]) }
        @y = @data.split(":").map { |v| BigDecimal(v.split(",")[1]) }
        @is_number = @data.split(":").map { |v| v.split(",") }.flatten.map { |v| v =~ /[0-9.]+/ }.all?
        @n = @x.length
        if @n <= 2
          @error << :fewer_inputs
        end
        unless @is_number
          @error << :data_nan
        end
        if @error.empty?
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
      rescue Exception => e
        @error << :parse_error
        @debug << e.to_s
      end
    else
      @error << :no_data
    end
    @debug_area = (@debug + @error).join("\n")
    erb :index
  end

  get "/about" do
    erb :about
  end

  get "/help" do
    erb :help
  end
end

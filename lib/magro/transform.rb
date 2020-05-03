# frozen_string_literal: true

module Magro
  # Transform module provide functions of image transfom.
  module Transform
    module_function

    # Resizes an image with bilinear interpolation method.
    #
    # @example
    #   require 'numo/narray'
    #   require 'magro'
    #
    #   image = Numo::UInt8.new(16, 16).seq
    #   resized = Magro::Transform.resize(image, height: 64, width: 64)
    #
    # @param image [Numo::UInt8] (shape: [height, width, n_channels] or [height, width]) Image data to be saved.
    # @param height [Integer] Requested height in pixels.
    # @param width [Integer] Requested width in pixels.
    # @return [Numo::UInt8] (shape: [height, width, n_channels] or [height, width]) Resized image data.
    def resize(image, height:, width:)
      n_channels = image.shape[2]

      if n_channels.nil?
        bilinear_resize(image, height, width)
      else
        resized = image.class.zeros(height, width, n_channels)
        n_channels.times { |c| resized[true, true, c] = bilinear_resize(image[true, true, c], height, width) }
        resized
      end
    end

    # private

    def bilinear_resize(image, new_height, new_width)
      height, width = image.shape

      y_ratio = height.fdiv(new_height)
      x_ratio = width.fdiv(new_width)

      y, x = Numo::Int32.new(new_height * new_width).seq.divmod(new_width)

      y_p = Numo::Int32.cast((y_ratio * (y + 0.5) - 0.5).floor).clip(0, height - 1)
      x_p = Numo::Int32.cast((x_ratio * (x + 0.5) - 0.5).floor).clip(0, width - 1)
      y_n = Numo::Int32.cast((y_ratio * (y + 0.5) - 0.5).ceil).clip(0, height - 1)
      x_n = Numo::Int32.cast((x_ratio * (x + 0.5) - 0.5).ceil).clip(0, width - 1)

      flt = image.flatten
      a = flt[y_p * width + x_p]
      b = flt[y_p * width + x_n]
      c = flt[y_n * width + x_p]
      d = flt[y_n * width + x_n]

      y_d = y_ratio * (y + 0.5) - 0.5
      x_d = x_ratio * (x + 0.5) - 0.5
      y_d = y_d.class.maximum(0, y_d - y_d.floor)
      x_d = x_d.class.maximum(0, x_d - x_d.floor)

      resized = a * (1 - x_d) * (1 - y_d) + b * x_d * (1 - y_d) + c * (1 - x_d) * y_d + d * x_d * y_d

      resized = resized.ceil.clip(image.class::MIN, image.class::MAX) if integer_narray?(image)
      resized = image.class.cast(resized) unless resized.is_a?(image.class)
      resized.reshape(new_height, new_width)
    end

    INTEGER_NARRAY = %w[Numo::Int8 Numo::Int16 Numo::Int32 Numo::Int64
                        Numo::UInt8 Numo::UInt16 Numo::UInt32 Numo::UInt64].freeze

    private_constant :INTEGER_NARRAY

    def integer_narray?(image)
      INTEGER_NARRAY.include?(image.class.to_s)
    end

    private_class_method :bilinear_resize, :integer_narray?
  end
end

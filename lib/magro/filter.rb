# frozen_string_literal: true

module Magro
  # Filter module provides functions for image filtering.
  module Filter
    module_function

    # Applies box filter to image.
    # This method performs zero padding as a preprocessing.
    #
    # @example
    #   image = Magro::IO.imread('foo.png')
    #   kernel = Numo::DFloat[
    #     [1, 1, 1],
    #     [1, 1, 1],
    #     [1, 1, 1]
    #   ]
    #   blured_image = Magro::Filter.filter2d(image, kernel)
    #   Magro::IO.imsave('bar.png', blured_image)
    #
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @param kernel [Numo::DFloat] (shape: [kernel_height, kernel_width]) Box filter.
    # @param scale [Float/Nil] Scale parameter for box filter. If nil is given, the box filter is normalized with sum of filter values.
    # @param offset [Integer] Offset value of filtered image.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def filter2d(image, kernel, scale: nil, offset: 0)
      raise ArgumentError, 'Expect class of image to be Numo::NArray.' unless image.is_a?(Numo::NArray)

      filter_h, filter_w = kernel.shape
      padded = zero_padding(image, filter_h, filter_w)
      n_channels = image.shape[2]
      if n_channels.nil?
        filter1ch(padded, kernel, scale, offset)
      else
        image.class.zeros(image.shape).tap do |filtered|
          n_channels.times do |c|
            filtered[true, true, c] = filter1ch(padded[true, true, c], kernel, scale, offset)
          end
        end
      end
    end

    # Convolve two 2-dimensional arrays.
    #
    # @param arr1 [Numo::NArray] (shape: [row1, col1]) First input array.
    # @param arr2 [Numo::NArray] (shape: [row2, col2]) Second input array.
    # @raise [ArgumentError] This error is raised when class of input array is not Numo::NArray.
    # @return [Numo::NArray] (shape: [row1 - row2 + 1, col1 - col2 + 1]) Convolution of arr1 with arr2.
    def convolve2d(arr1, arr2) # rubocop:disable Metrics/AbcSize
      raise ArgumentError, 'Expect class of first input array to be Numo::NArray.' unless arr1.is_a?(Numo::NArray)
      raise ArgumentError, 'Expect class of second input array to be Numo::NArray.' unless arr2.is_a?(Numo::NArray)
      raise ArgumentError, 'Expect first input array to be 2-dimensional array.' unless arr1.ndim == 2
      raise ArgumentError, 'Expect second input array to be 2-dimensional array.' unless arr2.ndim == 2

      row1, col1 = arr1.shape
      row2, col2 = arr2.shape
      # FIXME: lib/numo/narray/extra.rb:1098: warning: Using the last argument as keyword parameters is deprecated
      # convolved = im2col(arr1, row2, col2).dot(arr2.flatten)
      convolved = arr2.flatten.dot(im2col(arr1, row2, col2).transpose)
      convolved.reshape(row1 - row2 + 1, col1 - col2 + 1)
    end

    # private

    def zero_padding(image, filter_h, filter_w) # rubocop:disable Metrics/AbcSize
      image_h, image_w, n_channels = image.shape
      pad_h = filter_h / 2
      pad_w = filter_w / 2
      out_h = image_h + pad_h * 2
      out_w = image_w + pad_w * 2
      if n_channels.nil?
        image.class.zeros(out_h, out_w).tap do |padded|
          padded[pad_h...(pad_h + image_h), pad_w...(pad_w + image_w)] = image
        end
      else
        image.class.zeros(out_h, out_w, n_channels).tap do |padded|
          n_channels.times do |c|
            padded[pad_h...(pad_h + image_h), pad_w...(pad_w + image_w), c] = image[true, true, c]
          end
        end
      end
    end

    def filter1ch(image, kernel, scale, offset)
      scale ||= kernel.sum
      kernel *= scale.zero? ? 1.0 : 1.fdiv(scale)
      filtered = convolve2d(image, kernel)
      filtered = (filtered + offset).round.clip(image.class::MIN, image.class::MAX) if integer_narray?(image)
      filtered = image.class.cast(filtered) unless filtered.is_a?(image.class)
      filtered
    end

    def im2col(image, filter_h, filter_w)
      height, width = image.shape
      rows = height - filter_h + 1
      cols = width - filter_w + 1
      mat = image.class.zeros(filter_h, filter_w, rows, cols)
      filter_h.times do |y|
        y_end = y + rows
        filter_w.times do |x|
          x_end = x + cols
          mat[y, x, true, true] = image[y...y_end, x...x_end]
        end
      end
      mat.transpose(2, 3, 0, 1).reshape(rows * cols, filter_h * filter_w)
    end

    INTEGER_NARRAY = %w[Numo::Int8 Numo::Int16 Numo::Int32 Numo::Int64
                        Numo::UInt8 Numo::UInt16 Numo::UInt32 Numo::UInt64].freeze

    private_constant :INTEGER_NARRAY

    def integer_narray?(image)
      INTEGER_NARRAY.include?(image.class.to_s)
    end

    private_class_method :zero_padding, :filter1ch, :im2col, :integer_narray?
  end
end

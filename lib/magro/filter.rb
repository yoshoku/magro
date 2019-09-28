# frozen_string_literal: true

require 'numo/narray'
require 'numo/pocketfft'

module Magro
  # Filter module provides functions for image filtering.
  module Filter
    module_function

    # Blurs an image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def blur(image)
      raise ArgumentError, 'Expect class of image to be Numo::NArray.' unless image.is_a?(Numo::NArray)
      kernel = Numo::DFloat[
        [1, 1, 1, 1, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 1, 1, 1, 1]
      ]
      filter(image, kernel, scale: 16)
    end

    # Smooths an image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def smooth(image)
      kernel = Numo::DFloat[
        [1, 1, 1],
        [1, 5, 1],
        [1, 1, 1]
      ]
      filter(image, kernel, scale: 13)
    end

    # More smooths an image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def smooth_more(image)
      kernel = Numo::DFloat[
        [1, 1, 1, 1, 1],
        [1, 5, 5, 5, 1],
        [1, 5,44, 5, 1],
        [1, 5, 5, 5, 1],
        [1, 1, 1, 1, 1]
      ]
      filter(image, kernel, scale: 100)
    end

    # Sharpens an image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def sharpen(image)
      kernel = Numo::DFloat[
        [-2, -2, -2],
        [-2, 32, -2],
        [-2, -2, -2]
      ]
      filter(image, kernel, scale: 16)
    end

    # Details an image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def detail(image)
      kernel = Numo::DFloat[
        [ 0, -1,  0],
        [-1, 10, -1],
        [ 0, -1,  0]
      ]
      filter(image, kernel, scale: 6)
    end

    # Contours an image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def contour(image)
      kernel = Numo::DFloat[
        [-1, -1, -1],
        [-1,  8, -1],
        [-1, -1, -1]
      ]
      filter(image, kernel, scale: 1, offset: 255)
    end

    # Enhaces edges of image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def edge_enhance(image)
      kernel = Numo::DFloat[
        [-1, -1, -1],
        [-1, 10, -1],
        [-1, -1, -1]
      ]
      filter(image, kernel, scale: 2)
    end

    # More enhaces edges of image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def edge_enhance_more(image)
      kernel = Numo::DFloat[
        [-1, -1, -1],
        [-1,  9, -1],
        [-1, -1, -1]
      ]
      filter(image, kernel, scale: 1)
    end

    # Finds edges of image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def find_edges(image)
      kernel = Numo::DFloat[
        [-1, -1, -1],
        [-1,  8, -1],
        [-1, -1, -1]
      ]
      filter(image, kernel, scale: 1)
    end

    # Embosses an image using the box filter.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def emboss(image)
      kernel = Numo::DFloat[
       [-1, 0, 0],
       [ 0, 2, 0],
       [ 0, 0,-1]
       # [ 1, 2, 1],
       # [ 0, 0, 0],
       # [-1,-2,-1]
      ]
      #filter(image, kernel, scale: 1, offset: 128)
      filter(image, kernel, scale: 1, offset: 0)
    end

    # Applies box filter to image.
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Input image to be filtered.
    # @param kernel [Numo::DFloat] (shape: [kernel_height, kernel_width]) Box filter.
    # @param scale [Float/Nil] Scale parameter for box filter. If nil is given, the box filter is normalized with sum of filter values.
    # @param offset [Integer] Offset value of filtered image.
    # @raise [ArgumentError] This error is raised when class of input image is not Numo::NArray.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Filtered image.
    def filter(image, kernel, scale: nil, offset: 0)
      n_channels = image.shape[2]
      if n_channels.nil?
        partial_filter(image, kernel, scale, offset)
      else
        res = Numo::UInt8.zeros(*image.shape)
        n_channels.times { |c| res[true, true, c] = partial_filter(image[true, true, c], kernel, scale, offset) }
        res
      end
    end

    # @!visibility private
    def partial_filter(image, kernel, scale, offset)
      scale ||= kernel.sum
      normalizer = scale.zero? ? 1.0 : 1.fdiv(scale)
      padded = padding(image, *kernel.shape)
      p padded
      puts('---')
      filtered = Numo::Pocketfft.fftconvolve(image, kernel * normalizer)
      p filtered
      filtered = (filtered + offset).round.clip(0, 255)
      puts('---')
      image_h, image_w = image.shape
      start_y = (filtered.shape[0] - image_h) / 2
      start_x = (filtered.shape[1] - image_w) / 2
      end_y = image_h + start_y
      end_x = image_w + start_x
      Numo::UInt8.cast(filtered[start_y...end_y, start_x...end_x])
    end

    # @!visibility private
    def padding(image, filter_h, filter_w)
      image_h, image_w = image.shape
      res = image.dup
      if filter_w > 1
        #pad_l = res[true, 0...(filter_w - 1)].reverse(1)
        #pad_r = res[true, -filter_w...image_w].reverse(1)
        pad_l = res[true, 0].expand_dims(1) * Numo::DFloat.ones(filter_w * 2)
        pad_r = res[true,-1].expand_dims(1) * Numo::DFloat.ones(filter_w * 2)
        res = pad_l.concatenate(res.concatenate(pad_r, axis: 1), axis: 1)
      end
      if filter_h > 1
        #pad_t = res[0...(filter_h - 1), true].reverse(0)
        #pad_b = res[-filter_h...image_h, true].reverse(0)
        pad_t = res[ 0, true] * Numo::DFloat.ones(filter_h * 2).expand_dims(1)
        pad_b = res[-1, true] * Numo::DFloat.ones(filter_h * 2).expand_dims(1)
        res = pad_t.concatenate(res.concatenate(pad_b, axis: 0), axis: 0)
      end
      res
    end

    private_class_method :padding, :partial_filter
  end
end

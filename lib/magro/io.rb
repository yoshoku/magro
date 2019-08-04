# frozen_string_literal: true

module Magro
  # IO module provides functions for input and output of image file.
  module IO
    module_function

    # Loads an image from file.
    # @param filename [String] Path to image file to be loaded.
    #   Currently, the following file formats are support:
    #   Portbale Network Graphics (*.png) and JPEG files (*.jpeg, *.jpg, *jpe).
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Loaded image.
    def imread(filename)
      raise ArgumentError, 'Expect class of filename to be String.' unless filename.is_a?(String)
      return read_jpg(filename) if filename =~ /\.(jpeg|jpg|jpe)$/
      return read_png(filename) if filename =~ /\.png$/
    end

    # Saves an image to file.
    # @param filename [String] Path to image file to be saved.
    #   Currently, the following file formats are support:
    #   Portbale Network Graphics (*.png) and JPEG files (*.jpeg, *.jpg, *jpe).
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Image data to be saved.
    # @param quality [Integer] Quality parameter of jpeg image that takes a value between 0 to 100.
    # @return [Boolean] true if file save is successful.
    def imsave(filename, image, quality: nil)
      raise ArgumentError, 'Expect class of filename to be String.' unless filename.is_a?(String)
      raise ArgumentError, 'Expect class of image to be Numo::NArray.' unless image.is_a?(Numo::NArray)

      if filename =~ /\.(jpeg|jpg|jpe)$/
        unless quality.nil?
          raise ArgumentError, 'Expect class of quality to be Numeric.' unless quality.is_a?(Numeric)
          raise ArgumentError, 'Range of quality value between 0 to 100.' unless quality.between?(0, 100)
        end
        return save_jpg(filename, image, quality)
      end

      return save_png(filename, image) if filename =~ /\.png$/

      false
    end

    private_class_method :read_jpg, :read_png, :save_jpg, :save_png
  end
end

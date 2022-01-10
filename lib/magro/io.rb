# frozen_string_literal: true

require 'open-uri'
require 'tempfile'

module Magro
  # IO module provides functions for input and output of image file.
  module IO
    module_function

    # Loads an image from file.
    # @param filename [String] File path or URL of image file to be loaded.
    #   Currently, the following file formats are support:
    #   Portbale Network Graphics (*.png) and JPEG files (*.jpeg, *.jpg, *jpe).
    # @raise [ArgumentError] This error is raised when filename is not String.
    # @raise [IOError] This error is raised when failed to read image file.
    # @raise [NoMemoryError] If memory allocation of image data fails, this error is raised.
    # @return [Numo::UInt8] (shape: [height, width, n_channels]) Loaded image.
    def imread(filename)
      raise ArgumentError, 'Expect class of filename to be String.' unless filename.is_a?(String)

      unless url?(filename)
        return case filename.downcase
               when /\.(jpeg|jpg|jpe)$/
                 read_jpg(filename)
               when /\.png$/
                 read_png(filename)
               end
      end

      uri = URI.parse(filename)
      ext = File.extname(uri.path).downcase
      raise IOError, 'Failed to detect file extension from given URL.' unless ext =~ /\.(jpeg|jpg|jpe|png)$/

      uri.open do |file|
        temp = Tempfile.new(['magro_', ext])
        temp.binmode
        temp.write(file.read)
        temp.rewind
        imread(temp.path)
      end
    end

    # Saves an image to file.
    # @param filename [String] Path to image file to be saved.
    #   Currently, the following file formats are support:
    #   Portbale Network Graphics (*.png) and JPEG files (*.jpeg, *.jpg, *jpe).
    # @param image [Numo::UInt8] (shape: [height, width, n_channels]) Image data to be saved.
    # @param quality [Integer] Quality parameter of jpeg image that takes a value between 0 to 100.
    # @raise [ArgumentError] If filename is not String or image is not Numo::NArray, this error is raised.
    # @raise [IOError] This error is raised when failed to write image file.
    # @raise [NoMemoryError] If memory allocation of image data fails, this error is raised.
    # @return [Boolean] true if file save is successful.
    def imsave(filename, image, quality: nil)
      raise ArgumentError, 'Expect class of filename to be String.' unless filename.is_a?(String)
      raise ArgumentError, 'Expect class of image to be Numo::NArray.' unless image.is_a?(Numo::NArray)

      if filename.downcase =~ /\.(jpeg|jpg|jpe)$/
        unless quality.nil?
          raise ArgumentError, 'Expect class of quality to be Numeric.' unless quality.is_a?(Numeric)
          raise ArgumentError, 'Range of quality value between 0 to 100.' unless quality.between?(0, 100)
        end
        return save_jpg(filename, image, quality)
      end

      return save_png(filename, image) if filename.downcase =~ /\.png$/

      false
    end

    def url?(str)
      uri = URI.parse(str)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    end

    private_class_method :read_jpg, :read_png, :save_jpg, :save_png, :url?
  end
end

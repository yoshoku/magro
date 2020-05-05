# frozen_string_literal: true

RSpec.describe Magro::Filter do

  context 'when given image is grayscale image' do
    let(:image) do
      Numo::UInt8[
        [ 0,  32,   0,  32,  0],
        [32,   0, 128,   0, 32],
        [ 0, 128, 255, 128,  0],
        [32,   0, 128,   0, 32],
        [ 0,  32,   0,  32,  0]
      ]
    end

    let(:kernel) do
      Numo::DFloat[
        [1, 1, 1],
        [1, 5, 1],
        [1, 1, 1]
      ]
    end

    it 'applies box filter' do
      expect(described_class.filter2d(image, kernel)).to eq(Numo::UInt8[
        [ 5, 25,  15, 25,  5],
        [25, 44,  93, 44, 25],
        [15, 93, 137, 93, 15],
        [25, 44,  93, 44, 25],
        [ 5, 25,  15, 25,  5]
      ])
    end
  end

  context 'when given image is color image' do
    let(:image) do
      gray = Numo::UInt8[
        [0, 32, 0, 32, 0], [32, 0, 128, 0, 32], [0, 128, 255, 128, 0], [32, 0, 128, 0, 32], [0, 32, 0, 32, 0]
      ]
      Numo::UInt8.zeros(5, 5, 3).tap do |img|
        img[true, true, 0] = gray
        img[true, true, 1] = gray
        img[true, true, 2] = gray
      end
    end

    let(:kernel) do
      Numo::DFloat[
        [1, 1, 1],
        [1, 5, 1],
        [1, 1, 1]
      ]
    end

    it 'applies box filter' do
      expect(described_class.filter2d(image, kernel)).to eq(Numo::UInt8[
        [[5, 5, 5], [25, 25, 25], [15, 15, 15], [25, 25, 25], [5, 5, 5]],
        [[25, 25, 25], [44, 44, 44], [93, 93, 93], [44, 44, 44], [25, 25, 25]],
        [[15, 15, 15], [93, 93, 93], [137, 137, 137], [93, 93, 93], [15, 15, 15]],
        [[25, 25, 25], [44, 44, 44], [93, 93, 93], [44, 44, 44], [25, 25, 25]],
        [[5, 5, 5], [25, 25, 25], [15, 15, 15], [25, 25, 25], [5, 5, 5]]
      ])
    end
  end
end

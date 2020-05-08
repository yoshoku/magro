# frozen_string_literal: true

RSpec.describe Magro::Transform do
  describe '#resize' do
    let(:small) do
      Numo::UInt8[[56, 8],
                  [8, 32]]
    end

    let(:large) do
      Numo::UInt8[[56, 44, 20, 8],
                  [44, 37, 22, 14],
                  [20, 22, 25, 26],
                  [8,  14, 26, 32]]
    end

    let(:exp_small) do
      Numo::UInt8[[45, 16],
                  [16, 27]]
    end

    let(:exp_large) do
      Numo::UInt8[[56, 44, 20, 8],
                  [44, 37, 22, 14],
                  [20, 22, 25, 26],
                  [8,  14, 26, 32]]
    end

    context 'when given image is grayscale image' do
      let(:rsz_large) { described_class.resize(small, width: 4, height: 4) }
      let(:rsz_small) { described_class.resize(large, width: 2, height: 2) }

      it 'resizes image with bilinear interpolation method' do
        expect(rsz_large).to eq(exp_large)
        expect(rsz_large.class).to eq(Numo::UInt8)
        expect(rsz_small).to eq(exp_small)
        expect(rsz_small.class).to eq(Numo::UInt8)
      end
    end

    context 'when given image is color image' do
      let(:small_clr) do
        Numo::UInt8.zeros(2, 2, 3).tap do |img|
          img[true, true, 0] = small
          img[true, true, 1] = small
          img[true, true, 2] = small
        end
      end

      let(:large_clr) do
        Numo::UInt8.zeros(4, 4, 3).tap do |img|
          img[true, true, 0] = large
          img[true, true, 1] = large
          img[true, true, 2] = large
        end
      end

      let(:exp_small_clr) do
        Numo::UInt8.zeros(2, 2, 3).tap do |img|
          img[true, true, 0] = exp_small
          img[true, true, 1] = exp_small
          img[true, true, 2] = exp_small
        end
      end

      let(:exp_large_clr) do
        Numo::UInt8.zeros(4, 4, 3).tap do |img|
          img[true, true, 0] = exp_large
          img[true, true, 1] = exp_large
          img[true, true, 2] = exp_large
        end
      end

      let(:rsz_large_clr) { described_class.resize(small_clr, width: 4, height: 4) }
      let(:rsz_small_clr) { described_class.resize(large_clr, width: 2, height: 2) }

      it 'resizes image with bilinear interpolation method' do
        expect(rsz_large_clr).to eq(exp_large_clr)
        expect(rsz_large_clr.class).to eq(Numo::UInt8)
        expect(rsz_small_clr).to eq(exp_small_clr)
        expect(rsz_small_clr.class).to eq(Numo::UInt8)
      end
    end
  end
end

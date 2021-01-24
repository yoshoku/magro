# frozen_string_literal: true

RSpec.describe Magro::IO do
  let(:img_red) do
    Numo::UInt8[[255, 255, 255, 0, 0],
                [255, 255, 255, 0, 0],
                [255, 255, 0, 128, 128],
                [0, 0, 0, 255, 255],
                [0, 0, 0, 255, 255]]
  end
  let(:img_green) do
    Numo::UInt8[[0, 0, 255, 255, 255],
                [0, 0, 255, 255, 255],
                [0, 0, 0, 128, 128],
                [0, 0, 255, 255, 255],
                [0, 0, 255, 255, 255]]
  end
  let(:img_blue) do
    Numo::UInt8[[0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [255, 255, 0, 128, 128],
                [255, 255, 255, 255, 255],
                [255, 255, 255, 255, 255]]
  end
  let(:img_alpha) do
    Numo::UInt8[[128, 128, 128, 128, 128],
                [128, 255, 255, 255, 128],
                [128, 255, 255, 255, 128],
                [128, 255, 255, 255, 128],
                [128, 128, 128, 128, 128]]
  end
  let(:img_gray) do
    Numo::UInt8[[64, 64, 191, 64, 64],
                [64, 127, 255, 127, 64],
                [191, 255, 0, 128, 128],
                [64, 127, 255, 255, 255],
                [64, 64, 191, 255, 255]]
  end
  let(:img_rgb) do
    img = Numo::UInt8.zeros(5, 5, 3)
    img[true, true, 0] = img_red
    img[true, true, 1] = img_green
    img[true, true, 2] = img_blue
    img
  end
  let(:img_rgba) do
    img = Numo::UInt8.zeros(5, 5, 4)
    img[true, true, 0] = img_red
    img[true, true, 1] = img_green
    img[true, true, 2] = img_blue
    img[true, true, 3] = img_alpha
    img
  end

  it 'loads RGBA png file' do
    img = described_class.imread(File.expand_path(__dir__ + '/../files/test.png'))
    expect(img.shape).to eq([5, 5, 4])
    expect(img[true, true, 0]).to eq(img_red)
    expect(img[true, true, 1]).to eq(img_green)
    expect(img[true, true, 2]).to eq(img_blue)
    expect(img[true, true, 3]).to eq(img_alpha)
  end

  it 'loads RGB png file' do
    img = described_class.imread(File.expand_path(__dir__ + '/../files/test_rgb.png'))
    expect(img.shape).to eq([5, 5, 3])
    expect(img[true, true, 0]).to eq(img_red)
    expect(img[true, true, 1]).to eq(img_green)
    expect(img[true, true, 2]).to eq(img_blue)
  end

  it 'loads grayscale png file' do
    img = described_class.imread(File.expand_path(__dir__ + '/../files/test_gray.png'))
    expect(img.shape).to eq([5, 5])
    expect(img).to eq(img_gray)
  end

  it 'loads png file with upper case extension' do
    img = described_class.imread(File.expand_path(__dir__ + '/../files/TEST_UC.PNG'))
    expect(img.shape).to eq([5, 5, 4])
    expect(img[true, true, 0]).to eq(img_red)
    expect(img[true, true, 1]).to eq(img_green)
    expect(img[true, true, 2]).to eq(img_blue)
    expect(img[true, true, 3]).to eq(img_alpha)
  end

  it 'loads RGB jpeg file' do
    img = described_class.imread(File.expand_path(__dir__ + '/../files/test_rgb.jpg'))
    expect(img.shape).to eq([5, 5, 3])
  end

  it 'loads grayscale jpeg file' do
    img = described_class.imread(File.expand_path(__dir__ + '/../files/test_gray.jpg'))
    expect(img.shape).to eq([5, 5])
  end

  it 'loads jpeg file with upper case extension' do
    img = described_class.imread(File.expand_path(__dir__ + '/../files/TEST_RGB_UC.JPG'))
    expect(img.shape).to eq([5, 5, 3])
  end

  it 'loads png file from the Internet' do
    img = described_class.imread('https://raw.githubusercontent.com/yoshoku/magro/main/spec/files/TEST_UC.PNG')
    expect(img.shape).to eq([5, 5, 4])
    expect(img[true, true, 0]).to eq(img_red)
    expect(img[true, true, 1]).to eq(img_green)
    expect(img[true, true, 2]).to eq(img_blue)
    expect(img[true, true, 3]).to eq(img_alpha)
  end

  it 'loads jpeg file from the Internet' do
    img = described_class.imread('https://raw.githubusercontent.com/yoshoku/magro/main/spec/files/test_rgb.jpg')
    expect(img.shape).to eq([5, 5, 3])
  end

  it 'raises IOError when given no-extension URL' do
    expect { described_class.imread('https://github.com/yoshoku/magro') }.to raise_error(IOError)
  end

  it 'saves RGBA png file' do
    res = described_class.imsave(File.expand_path(__dir__ + '/../files/tmp.png'), img_rgba)
    img = described_class.imread(File.expand_path(__dir__ + '/../files/tmp.png'))
    expect(res).to be_truthy
    expect(img.shape).to eq([5, 5, 4])
    expect(img).to eq(img_rgba)
  end

  it 'saves RGB png file' do
    res = described_class.imsave(File.expand_path(__dir__ + '/../files/tmp.png'), img_rgba[true, true, 0..2])
    img = described_class.imread(File.expand_path(__dir__ + '/../files/tmp.png'))
    expect(res).to be_truthy
    expect(img.shape).to eq([5, 5, 3])
    expect(img).to eq(img_rgb)
  end

  it 'saves grayscale png file' do
    res = described_class.imsave(File.expand_path(__dir__ + '/../files/tmp.png'), img_gray)
    img = described_class.imread(File.expand_path(__dir__ + '/../files/tmp.png'))
    expect(res).to be_truthy
    expect(img.shape).to eq([5, 5])
    expect(img).to eq(img_gray)
  end

  it 'saves png file with uppper case extension' do
    res = described_class.imsave(File.expand_path(__dir__ + '/../files/tmp_UC.PNG'), img_rgba)
    img = described_class.imread(File.expand_path(__dir__ + '/../files/tmp_UC.PNG'))
    expect(res).to be_truthy
    expect(img.shape).to eq([5, 5, 4])
    expect(img).to eq(img_rgba)
  end

  it 'saves RGB jpeg file' do
    res = described_class.imsave(File.expand_path(__dir__ + '/../files/tmp.jpeg'), img_rgb, quality: 50)
    img = described_class.imread(File.expand_path(__dir__ + '/../files/tmp.jpeg'))
    err = Math.sqrt(((img_rgb - img)**2).sum.fdiv(img.shape.reduce(&:*)))
    expect(res).to be_truthy
    expect(img.shape).to eq([5, 5, 3])
    expect(err).to be <= 10
  end

  it 'saves grayscale jpeg file' do
    res = described_class.imsave(File.expand_path(__dir__ + '/../files/tmp.jpeg'), img_gray)
    img = described_class.imread(File.expand_path(__dir__ + '/../files/tmp.jpeg'))
    err = Math.sqrt(((img_gray - img)**2).sum.fdiv(img.shape.reduce(&:*)))
    expect(res).to be_truthy
    expect(img.shape).to eq([5, 5])
    expect(err).to be <= 2
  end

  it 'saves RGB jpeg file with uppser case extension' do
    res = described_class.imsave(File.expand_path(__dir__ + '/../files/tmp_UC.JPEG'), img_rgb, quality: 50)
    img = described_class.imread(File.expand_path(__dir__ + '/../files/tmp_UC.JPEG'))
    err = Math.sqrt(((img_rgb - img)**2).sum.fdiv(img.shape.reduce(&:*)))
    expect(res).to be_truthy
    expect(img.shape).to eq([5, 5, 3])
    expect(err).to be <= 10
  end

  it 'returns nil when given filename with unsupported extension on loading' do
    img = described_class.imread(File.expand_path(__dir__ + '/../files/test.txt'))
    expect(img).to be_nil
  end

  it 'returns false when given filename with unsupported extension on saving' do
    img = described_class.imsave(File.expand_path(__dir__ + '/../files/test.txt'), img_gray)
    expect(img).to be_falsy
  end

  it 'raises ArgumentError when given wrong arguments on loading' do
    expect { described_class.imread(nil) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError when given wrong arguments on saving' do
    filename = File.expand_path(__dir__ + '/../files/tmp.jpeg')
    expect { described_class.imsave(nil, img_gray) }.to raise_error(ArgumentError)
    expect { described_class.imsave(filename, img_gray, quality: 101) }.to raise_error(ArgumentError)
    expect { described_class.imsave(filename, img_gray, quality: -1) }.to raise_error(ArgumentError)
    expect { described_class.imsave(filename, nil, quality: 50) }.to raise_error(ArgumentError)
  end
end

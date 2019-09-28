# frozen_string_literal: true

RSpec.describe Magro::Filter do
  let(:image) do
    Numo::UInt8[
      [255, 255, 255, 255, 255, 255],
      [192, 192, 192, 192, 192, 192],
      [128, 128, 128, 128, 128, 128],
      [ 64,  64,  64,  64,  64,  64],
      [  0,   0,   0,   0,   0,   0]
    ]
  end

  # it do
  #   img = Magro::IO.imread(File.expand_path(__dir__ + '/files/lena.png'))
  #   #img = img.median(axis: 2)
  #   #img[0,true]  = 255
  #   #img[-1,true] = 255
  #   #img[true,0]  = 255
  #   #img[true,-1] = 255
  #   res = described_class.smooth_more(img)
  #   Magro::IO.imsave(File.expand_path(__dir__ + '/files/tmp.png'), res)
  # end

  it 'blurs an image' do
    p described_class.blur(image)
  end
end

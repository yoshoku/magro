# Magro

[![Build Status](https://travis-ci.org/yoshoku/magro.svg?branch=master)](https://travis-ci.org/yoshoku/magro)
[![Coverage Status](https://coveralls.io/repos/github/yoshoku/magro/badge.svg?branch=master)](https://coveralls.io/github/yoshoku/magro?branch=master)
[![Gem Version](https://badge.fury.io/rb/magro.svg)](https://badge.fury.io/rb/magro)
[![BSD 3-Clause License](https://img.shields.io/badge/License-BSD%203--Clause-orange.svg)](https://github.com/yoshoku/numo-liblinear/blob/master/LICENSE.txt)
[![Documentation](http://img.shields.io/badge/api-reference-blue.svg)](https://yoshoku.github.io/magro/doc/)

Magro is an image processing library in Ruby.
Magro uses [Numo::NArray](https://github.com/ruby-numo/numo-narray) arrays as image objects.

## Installation

Magro dependents libpng and libjpeg to provides functions loading image file.
It is recommended that using libpng version 1.6 or later.

macOS:

    $ brew install libpng libjpeg

Ubuntu (bionic):

    $ sudo apt-get install libpng-dev libjpeg-dev

Add this line to your application's Gemfile:

```ruby
gem 'magro'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install magro

## Documentation

- [Magro API Documentation](https://yoshoku.github.io/magro/doc/)

## Usage

```ruby
> require 'magro'
=> true
> image = Magro::IO.imread('lena.png')
=> Numo::UInt8#shape=[512,512,3]
> grayscale = image.median(axis: 2)
=> Numo::UInt8#shape=[512,512]
> Magro::IO.imsave('lena_gray.png', grayscale)
=> true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoshoku/magro.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Magro project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yoshoku/magro/blob/master/CODE_OF_CONDUCT.md).

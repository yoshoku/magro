# 0.6.1

- Refactor codes and configs with RuboCop.

# 0.6.0
- Reorganize native exntesion codes.
- Remove dependent gem's type declaration file from installation files.
- Update documentations.
- Introduce conventional commits.

# 0.5.1
- Fix version specifier of runtime dependencies.

# 0.5.0
- Add type declaration files.
- Refactor some codes.

# 0.4.3
- Fix imread method to read image from URL.
- Fix some configulation files.

# 0.4.2
- Add GC guard to reading and writing image methods.

# 0.4.1
- Add GC guard to narray given to native extension method.
- Fix some configulation files.

# 0.4.0
- Rename extension file for reading and writing image file.
- Update documentations.

# 0.3.0
- Add [filter module](https://yoshoku.github.io/magro/doc/Magro/Filter.html) consists of image filtering methods.
- Change to use round instead of ceil in [quantization of resize method](https://github.com/yoshoku/magro/commit/1b3308ddfb98a650889483af3cd2045aaf6b8837) when given integer image.

# 0.2.0
- Add [transform module](https://yoshoku.github.io/magro/doc/Magro/Transform.html) and resize method.
- Fix some configulation files.

# 0.1.2
- Fix bug that fails to read and save file with upper case file extension.

# 0.1.1
- Refactor extension codes.
- Fix to raise IOError when occured file reading / writing error.
- Fix to raise NoMemoryError when occured memory allocation error.
- Several documentation improvements.

# 0.1.0
- First release.

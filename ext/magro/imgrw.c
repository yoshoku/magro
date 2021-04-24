#include "imgrw.h"

RUBY_EXTERN VALUE mMagro;

/**
 * @!visibility private
 */
static VALUE magro_io_read_png(VALUE self, VALUE filename_) {
  char* filename = StringValuePtr(filename_);
  FILE* file_ptr = fopen(filename, "rb");
  unsigned char header[8];
  png_structp png_ptr;
  png_infop info_ptr;
  png_bytep* row_ptr_ptr;
  png_bytep row_ptr;
  png_uint_32 width, height;
  int color_type;
  int bit_depth;
  png_uint_32 y;
  int n_dims = 0;
  int n_ch;
  size_t shape[3] = {0};
  VALUE nary;
  uint8_t* nary_ptr;

  if (file_ptr == NULL) {
    rb_raise(rb_eIOError, "Failed to open file '%s'", filename);
    return Qnil;
  }

  if (fread(header, 1, 8, file_ptr) < 8) {
    fclose(file_ptr);
    rb_raise(rb_eIOError, "Failed to read header info '%s'", filename);
    return Qnil;
  }

  if (png_sig_cmp(header, 0, 8)) {
    fclose(file_ptr);
    rb_raise(rb_eIOError, "Failed to read header info '%s'", filename);
    return Qnil;
  }

  png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (png_ptr == NULL) {
    fclose(file_ptr);
    rb_raise(rb_eNoMemError, "Failed to allocate memory.");
    return Qnil;
  }
  info_ptr = png_create_info_struct(png_ptr);
  if (info_ptr == NULL) {
    png_destroy_read_struct(&png_ptr, NULL, NULL);
    fclose(file_ptr);
    rb_raise(rb_eNoMemError, "Failed to allocate memory.");
    return Qnil;
  }
  if (setjmp(png_jmpbuf(png_ptr))) {
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fclose(file_ptr);
    rb_raise(rb_eIOError, "Error happened while reading file '%s'", filename);
    return Qnil;
  }

  png_init_io(png_ptr, file_ptr);
  png_set_sig_bytes(png_ptr, 8);

  png_read_png(png_ptr, info_ptr, PNG_TRANSFORM_PACKING | PNG_TRANSFORM_EXPAND | PNG_TRANSFORM_STRIP_16, NULL);
  row_ptr_ptr = png_get_rows(png_ptr, info_ptr);
  png_get_IHDR(png_ptr, info_ptr, &width, &height, &bit_depth, &color_type, NULL, NULL, NULL);

  if (color_type == PNG_COLOR_TYPE_PALETTE) {
    png_set_palette_to_rgb(png_ptr);
    png_read_update_info(png_ptr, info_ptr);
    png_get_IHDR(png_ptr, info_ptr, &width, &height, &bit_depth, &color_type, NULL, NULL, NULL);
  }

  switch (color_type) {
  case PNG_COLOR_TYPE_GRAY:
    n_ch = 1;
    n_dims = 2;
    shape[0] = height;
    shape[1] = width;
    break;
  case PNG_COLOR_TYPE_GRAY_ALPHA:
    n_ch = 2;
    n_dims = 3;
    shape[0] = height;
    shape[1] = width;
    shape[2] = 2;
    break;
  case PNG_COLOR_TYPE_RGB:
    n_ch = 3;
    n_dims = 3;
    shape[0] = height;
    shape[1] = width;
    shape[2] = 3;
    break;
  case PNG_COLOR_TYPE_RGB_ALPHA:
    n_ch = 4;
    n_dims = 3;
    shape[0] = height;
    shape[1] = width;
    shape[2] = 4;
    break;
  default:
    n_dims = 0;
    break;
  }

  if (n_dims == 0) {
    fclose(file_ptr);
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    rb_raise(rb_eIOError, "Unsupported color type of input file '%s'", filename);
    return Qnil;
  }

  nary = rb_narray_new(numo_cUInt8, n_dims, shape);
  nary_ptr = (uint8_t*)na_get_pointer_for_write(nary);

  for (y = 0; y < height; y++) {
    row_ptr = row_ptr_ptr[y];
    memcpy(nary_ptr + y * width * n_ch, row_ptr, width * n_ch);
  }

  fclose(file_ptr);
  png_destroy_read_struct(&png_ptr, &info_ptr, NULL);

  RB_GC_GUARD(filename_);

  return nary;
}

/**
 * @!visibility private
 */
static VALUE magro_io_save_png(VALUE self, VALUE filename_, VALUE image) {
  char* filename = StringValuePtr(filename_);
  FILE* file_ptr = fopen(filename, "wb");
  png_structp png_ptr;
  png_infop info_ptr;
  png_bytep* row_ptr_ptr;
  png_uint_32 width, height;
  int color_type;
  int bit_depth = 8;
  png_uint_32 y;
  int n_ch;
  int n_dims;
  narray_t* image_nary;
  uint8_t* image_ptr;

  if (file_ptr == NULL) {
    rb_raise(rb_eIOError, "Failed to open file '%s'", filename);
    return Qfalse;
  }

  if (CLASS_OF(image) != numo_cUInt8) {
    image = rb_funcall(numo_cUInt8, rb_intern("cast"), 1, image);
  }
  if (!RTEST(nary_check_contiguous(image))) {
    image = nary_dup(image);
  }

  GetNArray(image, image_nary);
  n_dims = NA_NDIM(image_nary);
  height = (png_uint_32)NA_SHAPE(image_nary)[0];
  width = (png_uint_32)NA_SHAPE(image_nary)[1];
  image_ptr = (uint8_t*)na_get_pointer_for_read(image);

  n_ch = 1;
  if (n_dims == 3) {
    n_ch = (int)NA_SHAPE(image_nary)[2];
  }

  switch (n_ch) {
  case 4:
    color_type = PNG_COLOR_TYPE_RGBA;
    break;
  case 3:
    color_type = PNG_COLOR_TYPE_RGB;
    break;
  case 2:
    color_type = PNG_COLOR_TYPE_GRAY_ALPHA;
    break;
  default:
    color_type = PNG_COLOR_TYPE_GRAY;
    break;
  }

  png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (png_ptr == NULL) {
    fclose(file_ptr);
    rb_raise(rb_eNoMemError, "Failed to allocate memory.");
    return Qfalse;
  }
  info_ptr = png_create_info_struct(png_ptr);
  if (info_ptr == NULL) {
    png_destroy_read_struct(&png_ptr, NULL, NULL);
    fclose(file_ptr);
    rb_raise(rb_eNoMemError, "Failed to allocate memory.");
    return Qfalse;
  }
  if (setjmp(png_jmpbuf(png_ptr))) {
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fclose(file_ptr);
    return Qfalse;
  }

  png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, color_type, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT,
               PNG_FILTER_TYPE_DEFAULT);

  row_ptr_ptr = png_malloc(png_ptr, height * sizeof(png_bytep));
  for (y = 0; y < height; y++) {
    row_ptr_ptr[y] = png_malloc(png_ptr, width * n_ch * sizeof(png_byte));
    memcpy(row_ptr_ptr[y], image_ptr + y * width * n_ch, width * n_ch);
  }

  png_init_io(png_ptr, file_ptr);
  png_set_rows(png_ptr, info_ptr, row_ptr_ptr);
  png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

  fclose(file_ptr);
  for (y = 0; y < height; y++) {
    png_free(png_ptr, row_ptr_ptr[y]);
  }
  png_free(png_ptr, row_ptr_ptr);
  png_destroy_read_struct(&png_ptr, &info_ptr, NULL);

  RB_GC_GUARD(image);
  RB_GC_GUARD(filename_);

  return Qtrue;
}

struct my_error_mgr {
  struct jpeg_error_mgr pub;
  jmp_buf setjmp_buffer;
};

static void my_error_exit(j_common_ptr cinfo) {
  struct my_error_mgr* my_err = (struct my_error_mgr*)cinfo->err;
  (*cinfo->err->output_message)(cinfo);
  longjmp(my_err->setjmp_buffer, 1);
}

/**
 * @!visibility private
 */
static VALUE magro_io_read_jpg(VALUE self, VALUE filename_) {
  char* filename = StringValuePtr(filename_);
  FILE* file_ptr = fopen(filename, "rb");
  struct jpeg_decompress_struct jpeg;
  struct my_error_mgr err;
  unsigned int width, height;
  int n_colors;
  size_t shape[3] = {0};
  int n_dims;
  unsigned int y;
  VALUE nary;
  uint8_t* nary_ptr;
  JSAMPLE* tmp;

  if (file_ptr == NULL) {
    rb_raise(rb_eIOError, "Failed to open file '%s'", filename);
    return Qnil;
  }

  jpeg.err = jpeg_std_error(&err.pub);
  err.pub.error_exit = my_error_exit;
  if (setjmp(err.setjmp_buffer)) {
    rb_raise(rb_eIOError, "Error happened while reading file '%s'", filename);
    return Qnil;
  }

  jpeg_create_decompress(&jpeg);
  jpeg_stdio_src(&jpeg, file_ptr);
  jpeg_read_header(&jpeg, TRUE);
  jpeg_start_decompress(&jpeg);

  width = jpeg.output_width;
  height = jpeg.output_height;
  n_colors = jpeg.out_color_components;

  n_dims = n_colors == 1 ? 2 : 3;
  shape[0] = height;
  shape[1] = width;
  shape[2] = n_colors;
  nary = rb_narray_new(numo_cUInt8, n_dims, shape);
  nary_ptr = (uint8_t*)na_get_pointer_for_write(nary);

  for (y = 0; y < height; y++) {
    tmp = nary_ptr + y * width * n_colors;
    jpeg_read_scanlines(&jpeg, &tmp, 1);
  }

  fclose(file_ptr);
  jpeg_finish_decompress(&jpeg);
  jpeg_destroy_decompress(&jpeg);

  RB_GC_GUARD(filename_);

  return nary;
}

/**
 * @!visibility private
 */
static VALUE magro_io_save_jpg(int argc, VALUE* argv, VALUE self) {
  VALUE filename_;
  VALUE image;
  VALUE quality_;
  char* filename;
  FILE* file_ptr;
  struct jpeg_compress_struct jpeg;
  struct my_error_mgr err;
  narray_t* image_nary;
  int quality;
  int n_dims, n_ch;
  unsigned int width, height, y;
  uint8_t* image_ptr;
  JSAMPLE* tmp;

  rb_scan_args(argc, argv, "21", &filename_, &image, &quality_);

  if (NIL_P(quality_)) {
    quality = 95;
  } else {
    quality = NUM2INT(quality_);
  }

  filename = StringValuePtr(filename_);

  if (CLASS_OF(image) != numo_cUInt8) {
    image = rb_funcall(numo_cUInt8, rb_intern("cast"), 1, image);
  }
  if (!RTEST(nary_check_contiguous(image))) {
    image = nary_dup(image);
  }

  jpeg.err = jpeg_std_error(&err.pub);
  err.pub.error_exit = my_error_exit;
  if (setjmp(err.setjmp_buffer)) {
    return Qfalse;
  }

  jpeg_create_compress(&jpeg);

  file_ptr = fopen(filename, "wb");
  if (file_ptr == NULL) {
    rb_raise(rb_eIOError, "Failed to open file '%s'", filename);
    jpeg_destroy_compress(&jpeg);
    return Qfalse;
  }

  GetNArray(image, image_nary);
  n_dims = NA_NDIM(image_nary);
  height = (unsigned int)NA_SHAPE(image_nary)[0];
  width = (unsigned int)NA_SHAPE(image_nary)[1];
  image_ptr = (uint8_t*)na_get_pointer_for_read(image);

  n_ch = 1;
  if (n_dims == 3) {
    n_ch = (int)NA_SHAPE(image_nary)[2];
  }

  jpeg_stdio_dest(&jpeg, file_ptr);

  jpeg.image_height = height;
  jpeg.image_width = width;
  jpeg.input_components = n_ch;

  switch (n_ch) {
  case 3:
    jpeg.in_color_space = JCS_RGB;
    break;
  case 1:
    jpeg.in_color_space = JCS_GRAYSCALE;
    break;
  default:
    jpeg.in_color_space = JCS_UNKNOWN;
    break;
  }

  jpeg_set_defaults(&jpeg);

  jpeg_set_quality(&jpeg, quality, TRUE);

  jpeg_start_compress(&jpeg, TRUE);

  for (y = 0; y < height; y++) {
    tmp = image_ptr + y * width * n_ch;
    jpeg_write_scanlines(&jpeg, &tmp, 1);
  }

  jpeg_finish_compress(&jpeg);
  jpeg_destroy_compress(&jpeg);

  fclose(file_ptr);

  RB_GC_GUARD(image);
  RB_GC_GUARD(filename_);

  return Qtrue;
}

void init_io_module() {
  VALUE mIO = rb_define_module_under(mMagro, "IO");
  rb_define_module_function(mIO, "read_png", magro_io_read_png, 1);
  rb_define_module_function(mIO, "save_png", magro_io_save_png, 2);
  rb_define_module_function(mIO, "read_jpg", magro_io_read_jpg, 1);
  rb_define_module_function(mIO, "save_jpg", magro_io_save_jpg, -1);
}

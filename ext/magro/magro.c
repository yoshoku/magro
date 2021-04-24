#include "magro.h"

VALUE mMagro;

void Init_magro() {
  mMagro = rb_define_module("Magro");

  init_io_module();
}

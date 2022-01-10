require 'mkmf'
require 'numo/narray'

$LOAD_PATH.each do |lp|
  if File.exist?(File.join(lp, 'numo/numo/narray.h'))
    $INCFLAGS = "-I#{lp}/numo #{$INCFLAGS}"
    break
  end
end

abort 'numo/narray.h not found.' unless have_header('numo/narray.h')

if RUBY_PLATFORM =~ /mswin|cygwin|mingw/
  $LOAD_PATH.each do |lp|
    if File.exist?(File.join(lp, 'numo/libnarray.a'))
      $LDFLAGS = "-L#{lp}/numo #{$LDFLAGS}"
      break
    end
  end
  abort 'libnarray.a not found.' unless have_library('narray', 'nary_new')
end

abort 'setjmp.h not found.' unless have_header('setjmp.h')
abort 'png.h not found.' unless have_header('png.h')
abort 'libpng not found.' unless have_library('png')

abort 'jpeglib.h not found.' unless have_header('jpeglib.h')
abort 'libjpeg not found.' unless have_library('jpeg')

create_makefile('magro/magro')

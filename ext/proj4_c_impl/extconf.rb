# -----------------------------------------------------------------------------
#
# Makefile builder for Proj4 wrapper
#
# -----------------------------------------------------------------------------

if ::RUBY_DESCRIPTION =~ /^jruby\s/

  ::File.open("Makefile", "w") { |f_| f_.write(".PHONY: install\ninstall:\n") }

else

  require "mkmf"

  header_dirs_ =
    [
      ::RbConfig::CONFIG["includedir"],
    ]
  lib_dirs_ =
    [
      ::RbConfig::CONFIG["libdir"],
    ]
  header_dirs_.delete_if { |path_| !::File.directory?(path_) }
  lib_dirs_.delete_if { |path_| !::File.directory?(path_) }

  found_proj_ = false
  header_dirs_, lib_dirs_ = dir_config("proj", header_dirs_, lib_dirs_)
  dflag = "-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
  if have_header("proj_api.h", nil, dflag)
    $libs << " -lproj"
    if have_func("pj_init_plus", "proj_api.h", dflag)
      found_proj_ = true
    else
      $libs.gsub!(" -lproj", "")
    end
  end
  unless found_proj_
    puts "**** WARNING: Unable to find Proj headers or Proj version is too old."
    puts "**** Compiling without Proj support."
  end
  create_makefile("rgeo/coord_sys/proj4_c_impl")

end

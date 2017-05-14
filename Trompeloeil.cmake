function(get_trompeloeil)
  set(_prefix "_arg")
  set(_options "")
  set(_one_value_keywords
    VERSION
  )

  set(_multi_value_keywords "")
  set(_multi_value_keywords "")
  cmake_parse_arguments(PARSE_ARGV 0 "${_prefix}" "${_options}" "${_one_value_keywords}" "${_multi_value_keywords}")

  if(NOT DEFINED _arg_VERSION)
    set(_version "master")
  elseif(_arg_VERSION MATCHES "^(0|[1-9][0-9]*)$")
    set(_version "v${_arg_VERSION}")
  elseif(_arg_VERSION MATCHES "^[0-9a-f]+$")
    set(_version "${_arg_VERSION}")
  else()
    message(FATAL_ERROR "'${_arg_VERSION}' is not a valid VERSION or commit hash for GET_TROMPELOEIL().")
  endif()

  set(_host "https://raw.githubusercontent.com")
  set(_repo "rollbear/trompeloeil")
  set(_file_path "trompeloeil.hpp")
  set(_url "${_host}/${_repo}/${_version}/${_file_path}")

  set(_output_dir "${CMAKE_BINARY_DIR}/trompeloeil")
  set(_output_file "trompeloeil.hpp")
  set(_output_path "${_output_dir}/${_output_file}")

  file(DOWNLOAD "${_url}" "${_output_path}"
    STATUS _status
  )
  list(GET _status 0 _status_code)
  list(GET _status 1 _status_string)

  if(NOT _status_code EQUAL 0)
    if(EXISTS "${_output_path}")
      set(_level WARNING)
    else()
      set(_level FATAL_ERROR)
    endif()
    message(${_level}
      "Failed to download file from \n"
      "    ${_url}\n"
      "Error ${_status_code}: ${_status_string}"
    )
  endif()

  add_library(Trompeloeil INTERFACE)
  target_include_directories(Trompeloeil
    INTERFACE ${_output_dir}
  )

  add_library(Trompeloeil::Trompeloeil ALIAS Trompeloeil)
endfunction()

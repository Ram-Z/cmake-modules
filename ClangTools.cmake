find_program(CLANG_TIDY_EXECUTABLE
  NAMES clang-tidy
  DOC "ClangTidy executable"
)

find_program(CLANG_FORMAT_EXECUTABLE
  NAMES clang-format
  DOC "ClangFormat executable"
)

function(clang_tidy target)
  set(_prefix "_arg")
  set(_options "")
  set(_one_value_keywords
    CLANG_TIDY_EXECUTABLE
    CLANG_TIDY_ARGS
  )
  set(_multi_value_keywords "")
  cmake_parse_arguments(PARSE_ARGV 1 "${_prefix}" "${_options}" "${_one_value_keywords}" "${_multi_value_keywords}")

  if (NOT TARGET ${target})
    message(FATAL_ERROR "${target} is not a target")
  endif()

  if(DEFINED _arg_CLANG_TIDY_EXECUTABLE)
    set(CLANG_TIDY_EXECUTABLE "${_arg_CLANG_TIDY_EXECUTABLE}")
  elseif(NOT CLANG_TIDY_EXECUTABLE)
    message(FATAL_ERROR "ClangTidy executable not found")
  endif()

  if (NOT TARGET tidy)
    add_custom_target(tidy)
  endif()

  get_target_property(_tgt_sources ${target} SOURCES)

  add_custom_target(${target}_tidy
    COMMAND "${CLANG_TIDY_EXECUTABLE}" -p ${CMAKE_BINARY_DIR} ${_tgt_sources}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  )

  add_dependencies(tidy ${target}_tidy)
endfunction()

function(clang_format target)
  set(_prefix "_arg")
  set(_options "")
  set(_one_value_keywords
    CLANG_FORMAT_EXECUTABLE
    CLANG_FORMAT_ARGS
  )
  set(_multi_value_keywords
    ADDITIONAL_FILES
  )
  cmake_parse_arguments(PARSE_ARGV 1 "${_prefix}" "${_options}" "${_one_value_keywords}" "${_multi_value_keywords}")

  if (NOT TARGET ${target})
    message(FATAL_ERROR "${target} is not a target")
  endif()

  if(DEFINED _arg_CLANG_FORMAT_EXECUTABLE)
    set(CLANG_FORMAT_EXECUTABLE "${_arg_CLANG_FORMAT_EXECUTABLE}")
  elseif(NOT CLANG_FORMAT_EXECUTABLE)
    message(FATAL_ERROR "ClangFormat executable not found")
  endif()


  if (NOT TARGET format)
    add_custom_target(format)
  endif()

  get_target_property(_tgt_sources ${target} SOURCES)
  foreach(_source IN LISTS _tgt_sources)
    get_filename_component(_basename "${_source}" NAME_WE)
    foreach(_ext "hpp" "h")
      file(GLOB_RECURSE _header "${_basename}.${_ext}")
      list(APPEND _tgt_headers ${_header})
    endforeach()
  endforeach()
  set(_files ${_tgt_sources} ${_tgt_headers} ${_arg_ADDITIONAL_FILES})

  add_custom_target(${target}_format
    COMMAND "${CLANG_FORMAT_EXECUTABLE}" -i ${CLANG_FORMAT_ARGS} ${_files}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  )

  add_dependencies(format ${target}_format)
endfunction()

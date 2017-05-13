# GitDescribe
# -----------
#
# ::
#
#   GIT_DESCRIBE(PREFIX <prefix>
#     [GIT_EXECUTABLE </path/to/git>]
#     )
#
# Get the version string from `git describe`, expects there to be a tag of format "v?[0-9]*.[0-9]*"
#
# It populates the following variables:
#   <PREFIX>_VERSION_MAJOR:   major version of last tag
#   <PREFIX>_VERSION_MINOR:   minor version of last tag
#   <PREFIX>_VERSION_PATCH:   number of commits since last tag
#   <PREFIX>_VERSION_HASH:    hash of current object
#   <PREFIX>_VERSION_STRING:  <PREFIX>_VERSION_MAJOR.<PREFIX>_VERSION_MINOR-<PREFIX>_VERSION_PATCH-g<PREFIX>_VERSION_HASH
#   <PREFIX>_VERSION:         <PREFIX>_VERSION_MAJOR.<PREFIX>_VERSION_MINOR.<PREFIX>_VERSION_PATCH
#
# The <PREFIX>_VERSION is formatted in such a way it can be used as a VERSION for a `project()`
#
function(git_describe)
  set(_prefix "_arg")
  set(_options "")
  set(_one_value_keywords
    PREFIX
    GIT_EXECUTABLE
  )
  set(_multi_value_keywords "")
  cmake_parse_arguments(PARSE_ARGV 0 "${_prefix}" "${_options}" "${_one_value_keywords}" "${_multi_value_keywords}")

  if(NOT DEFINED _arg_PREFIX)
    message(FATAL_ERROR "No PREFIX specified for GIT_DESCRIBE()")
  endif()

  if(DEFINED _arg_GIT_EXECUTABLE)
    set(GIT_EXECUTABLE "${_arg_GIT_EXECUTABLE}")
  else()
    find_package(Git REQUIRED)
  endif()

  execute_process(
    COMMAND           "${GIT_EXECUTABLE}" describe --tags --long
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    RESULT_VARIABLE   _git_result
    OUTPUT_VARIABLE   _git_long
    ERROR_VARIABLE    _git_error
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
  )

  if(NOT _git_result EQUAL 0)
    message(FATAL_ERROR "Error running git: ${_git_error}")
  endif()

  if(_git_long MATCHES "^v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)-([0-9]+)-g([0-9a-f]*)$")
    set(_version_major   "${CMAKE_MATCH_1}")
    set(_version_minor   "${CMAKE_MATCH_2}")
    set(_version_patch   "${CMAKE_MATCH_3}")
    set(_version_hash    "${CMAKE_MATCH_4}")
  else()
    message(FATAL_ERROR "Could not extract version from tag: ${_git_long}")
  endif()

  set(${_arg_PREFIX}_VERSION_MAJOR  "${_version_major}" PARENT_SCOPE)
  set(${_arg_PREFIX}_VERSION_MINOR  "${_version_minor}" PARENT_SCOPE)
  set(${_arg_PREFIX}_VERSION_PATCH  "${_version_patch}" PARENT_SCOPE)
  set(${_arg_PREFIX}_VERSION_HASH   "${_version_hash}"  PARENT_SCOPE)
  set(${_arg_PREFIX}_VERSION        "${_version_major}.${_version_minor}.${_version_patch}" PARENT_SCOPE)
  set(${_arg_PREFIX}_VERSION_STRING "${_version_major}.${_version_minor}-${_version_patch}-g${_version_hash}" PARENT_SCOPE)
endfunction()

# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.23)
project(cmake-docs-l10n NONE)

#[================[
  Cache Variables.
#]================]

set(LANGUAGE "all"
    CACHE STRING "Language Code for the Sphinx documentation system.")
    # Possible values are "all" and languages listed in languages.json.
    # See https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-language for details.

set(VERSION "git-master"
    CACHE STRING "Current version for the CMake documentation.")
    # Possible values are "git-master", "latest", and "v3.x".

set(UPDATE_MODE "NEVER"
    CACHE STRING "Mode of updating .pot/.po files.")
    # Possible values are "NEVER", "COMPARE", and "ALWAYS".
    # 1) NEVER:   Update .pot/.po files only if the current reference is missing.
    # 2) COMPARE: Update .pot/.po files only if the current reference is different than the latest one.
    # 3) ALWAYS:  Update .pot/.po files even if the current reference is the same as    the latest one.

set(INSTALL_MODE "COMPARE"
    CACHE STRING "Mode of installing the requirements.")
    # Possible values are "COMPARE" and "ALWAYS".
    # 1) COMPARE: Install the requirements only if the current reference is different than the previous one.
    # 2) ALWAYS:  Install the requirements even if the current reference is the same as    the previous one.

set(AUTO_DEPEND ON
    CACHE BOOL "Enable automatic dependency management for specific build targets.")

set(REMOVE_REDUNDANT ON
    CACHE BOOL "Removing redundant files after building documentation.")

set(VERSION_COMPENDIUM "git-master"
    CACHE STRING "Version of compendium that the current version merges translations from.")

set(VERSION_OF_PYTHON ""
    CACHE STRING "Python version to install.")

set(VERSION_OF_SPHINX ""
    CACHE STRING "Sphinx version to install.")

set(SPHINX_CONSOLE_LOCALE "en_US.UTF-8"
    CACHE STRING "Locale setting for the console.")

set(CMAKE_JOB_NUMBER "1"
    CACHE STRING "")
    # See https://cmake.org/cmake/help/latest/manual/cmake.1.html#cmdoption-cmake-build-j for details.

set(GETTEXT_WRAP_WIDTH 79
    CACHE STRING "Gettext wrap width for .pot/.po files.")

set(GETTEXT_ADDITIONAL_TARGETS "index,literal-block"
    CACHE STRING "Gettext additional targets for building the Sphinx documentation system.")
    # Possible values are "index", "literal-block", "doctest-block", "raw", and "image".
    # A comma-separated list
    # See https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-gettext_additional_targets for details.

set(SPHINX_BUILDER "html"
    CACHE STRING "Builder for the Sphinx documentation system.")
    # Possible values are "html".
    # See https://www.sphinx-doc.org/en/master/usage/builders/index.html for details.

set(SPHINX_VERBOSE_LEVEL "1"
    CACHE STRING "")
    # Possible values are "0", "1", "2", and "3".
    # See https://www.sphinx-doc.org/en/master/man/sphinx-build.html#cmdoption-sphinx-build-v for details.

set(SPHINX_JOB_NUMBER "1"
    CACHE STRING "")
    # Possible values are "auto", "1", "2",...etc.
    # See https://www.sphinx-doc.org/en/master/man/sphinx-build.html#cmdoption-sphinx-build-j for details.

set(GIT_REMOTE_URL "https://gitlab.kitware.com/cmake/cmake.git"
    CACHE STRING "Remote URL of the upstream Git repository.")

set(GIT_L10N_REMOTE_URL "https://github.com/hwhsu1231/cmake-docs-l10n-draft6.git"
    CACHE STRING "Remote URL of the l10n Git repository.")

set(GIT_DOCS_REMOTE_URL "https://gitlab.kitware.com/cmake/cmake.git"
    CACHE STRING "Remote URL of the docs Git repository.")

set(BASEURL_HREF "https://hwhsu1231.github.io/cmake-docs-l10n-draft6"
    CACHE STRING "Base URL of the deployed documentation.")

#[============================[
  Directory-Related Variables.
#]============================]

set(PROJ_SOURCE_DIR                 "${PROJECT_SOURCE_DIR}")
set(PROJ_BINARY_DIR                 "${PROJECT_BINARY_DIR}")
set(PROJ_CMAKE_MODULES_DIR          "${PROJ_SOURCE_DIR}/cmake/modules")
set(PROJ_CMAKE_SCRIPTS_DIR          "${PROJ_SOURCE_DIR}/cmake/scripts")
set(PROJ_CMAKE_TEMPLATES_DIR        "${PROJ_SOURCE_DIR}/cmake/templates")
set(PROJ_VENV_DIR                   "${PROJ_SOURCE_DIR}/.venv")
set(PROJ_OUT_DIR                    "${PROJ_SOURCE_DIR}/out")
set(PROJ_OUT_REPO_DIR               "${PROJ_OUT_DIR}/repo")
set(PROJ_OUT_REPO_SPHINX_DIR        "${PROJ_OUT_REPO_DIR}/Utilities/Sphinx")
set(PROJ_OUT_REPO_DOCS_CONFIG_DIR   "${PROJ_OUT_REPO_DIR}/Help")
set(PROJ_OUT_REPO_DOCS_SOURCE_DIR   "${PROJ_OUT_REPO_DIR}/Help")
set(PROJ_OUT_REPO_DOCS_LOCALE_DIR   "${PROJ_OUT_REPO_DIR}/Help/locale")
set(PROJ_OUT_BUILDER_DIR            "${PROJ_OUT_DIR}/${SPHINX_BUILDER}")
set(PROJ_L10N_DIR                   "${PROJ_SOURCE_DIR}/l10n")
set(PROJ_L10N_VERSION_DIR           "${PROJ_L10N_DIR}/${VERSION}")
set(PROJ_L10N_VERSION_LOCALE_DIR    "${PROJ_L10N_VERSION_DIR}/locale")
set(PROJ_L10N_VERSION_CROWDIN_DIR   "${PROJ_L10N_VERSION_DIR}/.crowdin")

#[====================[
  Configuration Files.
#]====================]

set(LANGUAGES_JSON_PATH             "${PROJ_SOURCE_DIR}/languages.json")
set(REFERENCES_JSON_PATH            "${PROJ_L10N_VERSION_DIR}/reference.json")
set(CROWDIN_YML_PATH                "${PROJ_L10N_VERSION_DIR}/crowdin.yml")
set(STATISTIC_TXT_PATH              "${PROJ_L10N_VERSION_DIR}/statistic.txt")
set(PREVIOUS_FREEZE_TXT_PATH        "${PROJ_VENV_DIR}/prev/freeze.txt")
set(PREVIOUS_REFERENCE_TXT_PATH     "${PROJ_VENV_DIR}/prev/reference.txt")

set(CMAKE_MODULE_PATH 
    "${PROJ_CMAKE_MODULES_DIR}"
    "${PROJ_CMAKE_MODULES_DIR}/common")
include(JsonUtils)
include(LogUtils)

#[========================================[
  Read LANGUAGES_LIST from languages.json.
#]========================================]

file(READ "${LANGUAGES_JSON_PATH}"  LANGUAGES_JSON_CNT)
get_members_of_json_object(
    IN_JSON_OBJECT      "${LANGUAGES_JSON_CNT}"
    OUT_MEMBER_NAMES    LANGUAGES_LIST)

#[====================================[
  Validate the VERSION cache variable.
  - For "git-master":
    - Set VERSION_TYPE to "branch"
    - Set BRANCH_NAME  to "master"
  - For "latest":
    - Set VERSION_TYPE to "tag"
    - Set TAG_PATTERN  to "v3.*"
  - For "v3.x":
    - Set VERSION_TYPE to "tag"
    - Set TAG_PATTERN  to "v3.x.*"
#]====================================]

if (VERSION MATCHES     "^git-master$")
    set(VERSION_TYPE    "branch")
    set(BRANCH_NAME     "master")
elseif(VERSION MATCHES  "^latest$")
    set(VERSION_TYPE    "tag")
    set(TAG_PATTERN     "v([0-9]+)\\.([0-9]+)\\.([0-9]+)")
elseif(VERSION MATCHES  "^v([0-9]+)\\.([0-9]+)$")
    set(VERSION_TYPE    "tag")
    string(REGEX REPLACE "\\." "\\\\." VERSION_ESCAPED "${VERSION}")
    set(TAG_PATTERN     "${VERSION_ESCAPED}\\.([0-9]+)")
else()
    message(FATAL_ERROR "Invalid VERSION value. (${VERSION})")
endif()

#[=====================================[
  Validate the LANGUAGE cache variable.
#]=====================================]

set(LANGUAGE_IS_VALID FALSE)
if(LANGUAGE STREQUAL "all")
    set(LANGUAGE_IS_VALID TRUE)
else()
    foreach(_LANGUAGE ${LANGUAGES_LIST})
        if(LANGUAGE STREQUAL _LANGUAGE)
            set(LANGUAGE_IS_VALID TRUE)
        endif()
    endforeach()
    unset(_LANGUAGE)
endif()
if(NOT LANGUAGE_IS_VALID)
    message(FATAL_ERROR "Invalid LANGUAGE value. (${LANGUAGE})")
endif()

#[========================================[
  Validate the UPDATE_MODE cache variable.
#]========================================]

if (NOT UPDATE_MODE STREQUAL "COMPARE" AND 
    NOT UPDATE_MODE STREQUAL "ALWAYS" AND 
    NOT UPDATE_MODE STREQUAL "NEVER")
    message(FATAL_ERROR "Invalid UPDATE_MODE value. (${UPDATE_MODE})")
endif()

#[=========================================[
  Validate the INSTALL_MODE cache variable.
#]=========================================]

if (NOT INSTALL_MODE STREQUAL "COMPARE" AND 
    NOT INSTALL_MODE STREQUAL "ALWAYS")
    message(FATAL_ERROR "Invalid INSTALL_MODE value. (${INSTALL_MODE})")
endif()

#[======================================================[
  Set SPHINX_VERBOSE_ARGS based on SPHINX_VERBOSE_LEVEL.
#]======================================================]

if(NOT DEFINED SPHINX_VERBOSE_LEVEL OR SPHINX_VERBOSE_LEVEL STREQUAL "")
    set(SPHINX_VERBOSE_LEVEL 0)
endif()
set(SPHINX_VERBOSE_ARGS "")
if(SPHINX_VERBOSE_LEVEL GREATER 0)
    set(SPHINX_VERBOSE_ARGS "-")
    math(EXPR REPEAT_COUNT "${SPHINX_VERBOSE_LEVEL} - 1")
    foreach(INDEX RANGE ${REPEAT_COUNT})
        set(SPHINX_VERBOSE_ARGS "${SPHINX_VERBOSE_ARGS}v")
    endforeach()
    unset(INDEX)
    unset(REPEAT_COUNT)
endif()

#[====================[
  Check prerequisites.
#]====================]

set(FIND_PACKAGE_PYTHON_ARGS)
if(VERSION_OF_PYTHON)
    set(VERSION_OF_PYTHON_ARGS ${VERSION_OF_PYTHON} EXACT)
else()
    set(VERSION_OF_PYTHON_ARGS)
endif()
set(FIND_PACKAGE_PYTHON_ARGS
    ${VERSION_OF_PYTHON_ARGS})



find_package(Git      MODULE QUIET)
find_package(Conda    MODULE QUIET)
find_package(Gettext  MODULE QUIET)
find_package(Crowdin  MODULE QUIET)

#[==========================================================[
  Create Git Worktree for 'l10n' branch in ${PROJ_L10N_DIR}.
#]==========================================================]

if(EXISTS "${PROJ_L10N_DIR}/.git")
    message(STATUS "Git Working Tree exists: ${PROJ_L10N_DIR}")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} status
        WORKING_DIRECTORY ${PROJ_L10N_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    execute_process(
        # COMMAND ${Git_EXECUTABLE} show --no-patch --format=%s
        # COMMAND ${Git_EXECUTABLE} show --no-patch --format=short
        # COMMAND ${Git_EXECUTABLE} show --no-patch --format=medium
        COMMAND ${Git_EXECUTABLE} show --no-patch --format=full
        WORKING_DIRECTORY ${PROJ_L10N_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    restore_cmake_message_indent()
else()
    message(STATUS "Git Working Tree doesn't exist: ${PROJ_L10N_DIR}")
    execute_process(
        COMMAND ${Git_EXECUTABLE} ls-remote --heads ${GIT_L10N_REMOTE_URL} l10n
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0 AND OUT_VAR)
        message(STATUS "There exists 'l10n' branch in the remote. Prepare to create a worktree.")
        execute_process(
            COMMAND ${Git_EXECUTABLE} remote
            WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
            set(REMOTE_NAME "${OUT_VAR}")
        else()
            message(FATAL_ERROR "${ERR_VAR}")
        endif()
        message(STATUS "Adding fetch refspec 'refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n'...")
        remove_cmake_message_indent()
        message("")
        execute_process(
            COMMAND ${Git_EXECUTABLE} config --get-all
                    remote.${REMOTE_NAME}.fetch
                    refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n
            WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
            # Fetch refspec 'refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n' already exists.
        elseif(RES_VAR EQUAL 1)
            # Fetch refspec 'refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n' doesn't exist.
            execute_process(
                COMMAND ${Git_EXECUTABLE} config --add
                        remote.${REMOTE_NAME}.fetch 
                        +refs/heads/l10n:refs/remotes/${REMOTE_NAME}/l10n
                WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
                ECHO_OUTPUT_VARIABLE
                ECHO_ERROR_VARIABLE
                COMMAND_ERROR_IS_FATAL ANY)
        else()
            message(FATAL_ERROR "${ERR_VAR}")
        endif()
        execute_process(
            COMMAND ${Git_EXECUTABLE} config --get-all
                    remote.${REMOTE_NAME}.fetch
            WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        message("")
        restore_cmake_message_indent()
        message(STATUS "Fetching/Tracking the remote branch 'l10n' to the local branch 'l10n'...")
        remove_cmake_message_indent()
        message("")
        execute_process(
            COMMAND ${Git_EXECUTABLE} fetch ${REMOTE_NAME} l10n:l10n --verbose --update-head-ok
            WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        execute_process(
            COMMAND ${Git_EXECUTABLE} branch --set-upstream-to=${REMOTE_NAME}/l10n l10n
            WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        message("")
        restore_cmake_message_indent()
        message(STATUS "Creating a git worktree for 'l10n' branch in ${PROJ_L10N_DIR}...")
        remove_cmake_message_indent()
        message("")
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E rm -rf ${PROJ_L10N_DIR}
            WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        execute_process(
            COMMAND ${Git_EXECUTABLE} worktree prune
            WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        execute_process(
            COMMAND ${Git_EXECUTABLE} worktree add ${PROJ_L10N_DIR} l10n
            WORKING_DIRECTORY ${PROJ_SOURCE_DIR}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
        message("")
        restore_cmake_message_indent()
        unset(REMOTE_NAME)
    else()
        message(STATUS "There is no 'l10n' branch in the remote. Need to create a worktree.")
    endif()
endif()

#[=============================================================[
  Initialize a reference.json file in ${PROJ_L10N_VERSION_DIR}.
#]=============================================================]

init_references_json_file(
    IN_FILEPATH     "${REFERENCES_JSON_PATH}"
    IN_VERSION      "${VERSION}"
    IN_TYPE         "${VERSION_TYPE}"
    IN_MODE         "language"
    IN_LANGUAGE     "${LANGUAGES_LIST}")

#[=========================================================[
  Configure a crowdin.yml file in ${PROJ_L10N_VERSION_DIR}.
#]=========================================================]

configure_file(
    "${PROJ_CMAKE_TEMPLATES_DIR}/crowdin.yml.in"
    "${CROWDIN_YML_PATH}"
    COPYONLY)

#[==================[
  Print Information.
#]==================]

message(STATUS "---------- Cache Variables ----------")
message(STATUS "VERSION                       = ${VERSION}")
message(STATUS "LANGUAGE                      = ${LANGUAGE}")
message(STATUS "UPDATE_MODE                   = ${UPDATE_MODE}")
message(STATUS "INSTALL_MODE                  = ${INSTALL_MODE}")
message(STATUS "AUTO_DEPEND                   = ${AUTO_DEPEND}")
message(STATUS "REMOVE_REDUNDANT              = ${REMOVE_REDUNDANT}")
message(STATUS "GIT_REMOTE_URL                = ${GIT_REMOTE_URL}")
message(STATUS "BASEURL_HREF                  = ${BASEURL_HREF}")
message(STATUS "VERSION_COMPENDIUM            = ${VERSION_COMPENDIUM}")
message(STATUS "VERSION_OF_PYTHON             = ${VERSION_OF_PYTHON}")
message(STATUS "VERSION_OF_SPHINX             = ${VERSION_OF_SPHINX}")
message(STATUS "GETTEXT_WRAP_WIDTH            = ${GETTEXT_WRAP_WIDTH}")
message(STATUS "GETTEXT_ADDITIONAL_TARGETS    = ${GETTEXT_ADDITIONAL_TARGETS}")
message(STATUS "SPHINX_BUILDER                = ${SPHINX_BUILDER}")
message(STATUS "SPHINX_CONSOLE_LOCALE         = ${SPHINX_CONSOLE_LOCALE}")
message(STATUS "SPHINX_VERBOSE_LEVEL          = ${SPHINX_VERBOSE_LEVEL}")
message(STATUS "SPHINX_JOB_NUMBER             = ${SPHINX_JOB_NUMBER}")
message(STATUS "---------- Directory-Related Variables ----------")
message(STATUS "PROJ_SOURCE_DIR               = ${PROJ_SOURCE_DIR}")
message(STATUS "PROJ_BINARY_DIR               = ${PROJ_BINARY_DIR}")
message(STATUS "PROJ_CMAKE_MODULES_DIR        = ${PROJ_CMAKE_MODULES_DIR}")
message(STATUS "PROJ_CMAKE_SCRIPTS_DIR        = ${PROJ_CMAKE_SCRIPTS_DIR}")
message(STATUS "PROJ_CMAKE_TEMPLATES_DIR      = ${PROJ_CMAKE_TEMPLATES_DIR}")
message(STATUS "PROJ_VENV_DIR                 = ${PROJ_VENV_DIR}")
message(STATUS "PROJ_OUT_DIR                  = ${PROJ_OUT_DIR}")
message(STATUS "PROJ_OUT_REPO_DIR             = ${PROJ_OUT_REPO_DIR}")
message(STATUS "PROJ_OUT_REPO_SPHINX_DIR      = ${PROJ_OUT_REPO_SPHINX_DIR}")
message(STATUS "PROJ_OUT_REPO_DOCS_CONFIG_DIR = ${PROJ_OUT_REPO_DOCS_CONFIG_DIR}")
message(STATUS "PROJ_OUT_REPO_DOCS_SOURCE_DIR = ${PROJ_OUT_REPO_DOCS_SOURCE_DIR}")
message(STATUS "PROJ_OUT_REPO_DOCS_LOCALE_DIR = ${PROJ_OUT_REPO_DOCS_LOCALE_DIR}")
message(STATUS "PROJ_OUT_BUILDER_DIR          = ${PROJ_OUT_BUILDER_DIR}")
message(STATUS "PROJ_L10N_DIR                 = ${PROJ_L10N_DIR}")
message(STATUS "PROJ_L10N_VERSION_DIR         = ${PROJ_L10N_VERSION_DIR}")
message(STATUS "PROJ_L10N_VERSION_LOCALE_DIR  = ${PROJ_L10N_VERSION_LOCALE_DIR}")
message(STATUS "PROJ_L10N_VERSION_CROWDIN_DIR = ${PROJ_L10N_VERSION_CROWDIN_DIR}")
message(STATUS "---------- Configuration Files ----------")
message(STATUS "LANGUAGES_JSON_PATH           = ${LANGUAGES_JSON_PATH}")
message(STATUS "REFERENCES_JSON_PATH          = ${REFERENCES_JSON_PATH}")
message(STATUS "CROWDIN_YML_PATH              = ${CROWDIN_YML_PATH}")
message(STATUS "STATISTIC_TXT_PATH            = ${STATISTIC_TXT_PATH}")
message(STATUS "PREVIOUS_FREEZE_TXT_PATH      = ${PREVIOUS_FREEZE_TXT_PATH}")
message(STATUS "PREVIOUS_REFERENCE_TXT_PATH   = ${PREVIOUS_REFERENCE_TXT_PATH}")
message(STATUS "---------- Other Variables ----------")
message(STATUS "LANGUAGES_LIST                = ${LANGUAGES_LIST}")
message(STATUS "VERSION_TYPE                  = ${VERSION_TYPE}")
message(STATUS "BRANCH_NAME                   = ${BRANCH_NAME}")
message(STATUS "TAG_PATTERN                   = ${TAG_PATTERN}")
message(STATUS "SPHINX_VERBOSE_ARGS           = ${SPHINX_VERBOSE_ARGS}")
message(STATUS "FIND_PACKAGE_GIT_ARGS         = ${FIND_PACKAGE_GIT_ARGS}")
message(STATUS "FIND_PACKAGE_CONDA_ARGS       = ${FIND_PACKAGE_CONDA_ARGS}")
message(STATUS "FIND_PACKAGE_PYTHON_ARGS      = ${FIND_PACKAGE_PYTHON_ARGS}")
message(STATUS "FIND_PACKAGE_GETTEXT_ARGS     = ${FIND_PACKAGE_GETTEXT_ARGS}")
message(STATUS "FIND_PACKAGE_CROWDIN_ARGS     = ${FIND_PACKAGE_CROWDIN_ARGS}")
message(STATUS "---------- Prerequisites ----------")
message(STATUS "CMAKE_VERSION                 = ${CMAKE_VERSION}")
message(STATUS "CMAKE_COMMAND                 = ${CMAKE_COMMAND}")
message(STATUS "CMAKE_GENERATOR               = ${CMAKE_GENERATOR}")
message(STATUS "Git_FOUND                     = ${Git_FOUND}")
message(STATUS "Git_VERSION                   = ${Git_VERSION}")
message(STATUS "Git_EXECUTABLE                = ${Git_EXECUTABLE}")
message(STATUS "Conda_FOUND                   = ${Conda_FOUND}")
message(STATUS "Conda_VERSION                 = ${Conda_VERSION}")
message(STATUS "Conda_EXECUTABLE              = ${Conda_EXECUTABLE}")
message(STATUS "Gettext_FOUND                 = ${Gettext_FOUND}")
message(STATUS "Gettext_VERSION               = ${Gettext_VERSION}")
message(STATUS "Gettext_XGETTEXT_EXECUTABLE   = ${Gettext_XGETTEXT_EXECUTABLE}")
message(STATUS "Crowdin_FOUND                 = ${Crowdin_FOUND}")
message(STATUS "Crowdin_VERSION               = ${Crowdin_VERSION}")
message(STATUS "Crowdin_EXECUTABLE            = ${Crowdin_EXECUTABLE}")
message(STATUS "----------------------------------------")

#[=========================================[
  Escape ';' characters for list variables.
#]=========================================]

string(REPLACE ";" "\\\\;" LANGUAGES_LIST "${LANGUAGES_LIST}")
string(REPLACE ";" "\\\\;" FIND_PACKAGE_GIT_ARGS "${FIND_PACKAGE_GIT_ARGS}")
string(REPLACE ";" "\\\\;" FIND_PACKAGE_CONDA_ARGS "${FIND_PACKAGE_CONDA_ARGS}")
string(REPLACE ";" "\\\\;" FIND_PACKAGE_PYTHON_ARGS "${FIND_PACKAGE_PYTHON_ARGS}")
string(REPLACE ";" "\\\\;" FIND_PACKAGE_GETTEXT_ARGS "${FIND_PACKAGE_GETTEXT_ARGS}")
string(REPLACE ";" "\\\\;" FIND_PACKAGE_CROWDIN_ARGS "${FIND_PACKAGE_CROWDIN_ARGS}")

#[===========================================[
  Cache variables passed to script mode '-E'.
#]===========================================]

set(SCRIPT_MODE_CACHE
    # [Cache Variables]
    -D LANGUAGE=${LANGUAGE}
    -D VERSION=${VERSION}
    -D AUTO_DEPEND=${AUTO_DEPEND}
    -D UPDATE_MODE=${UPDATE_MODE}
    -D INSTALL_MODE=${INSTALL_MODE}
    -D REMOVE_REDUNDANT=${REMOVE_REDUNDANT}
    -D VERSION_COMPENDIUM=${VERSION_COMPENDIUM}
    -D VERSION_OF_PYTHON=${VERSION_OF_PYTHON}
    -D VERSION_OF_SPHINX=${VERSION_OF_SPHINX}
    -D GIT_REMOTE_URL=${GIT_REMOTE_URL}
    -D BASEURL_HREF=${BASEURL_HREF}
    -D SPHINX_BUILDER=${SPHINX_BUILDER}
    -D SPHINX_CONSOLE_LOCALE=${SPHINX_CONSOLE_LOCALE}
    -D SPHINX_VERBOSE_LEVEL=${SPHINX_VERBOSE_LEVEL}
    -D SPHINX_JOB_NUMBER=${SPHINX_JOB_NUMBER}
    -D GETTEXT_WRAP_WIDTH=${GETTEXT_WRAP_WIDTH}
    -D GETTEXT_ADDITIONAL_TARGETS=${GETTEXT_ADDITIONAL_TARGETS}
    # [Directory-Related Variables]
    -D PROJ_SOURCE_DIR=${PROJ_SOURCE_DIR}
    -D PROJ_BINARY_DIR=${PROJ_BINARY_DIR}
    -D PROJ_CMAKE_MODULES_DIR=${PROJ_CMAKE_MODULES_DIR}
    -D PROJ_CMAKE_SCRIPTS_DIR=${PROJ_CMAKE_SCRIPTS_DIR}
    -D PROJ_CMAKE_TEMPLATES_DIR=${PROJ_CMAKE_TEMPLATES_DIR}
    -D PROJ_VENV_DIR=${PROJ_VENV_DIR}
    -D PROJ_OUT_DIR=${PROJ_OUT_DIR}
    -D PROJ_OUT_REPO_DIR=${PROJ_OUT_REPO_DIR}
    -D PROJ_OUT_REPO_SPHINX_DIR=${PROJ_OUT_REPO_SPHINX_DIR}
    -D PROJ_OUT_REPO_DOCS_CONFIG_DIR=${PROJ_OUT_REPO_DOCS_CONFIG_DIR}
    -D PROJ_OUT_REPO_DOCS_SOURCE_DIR=${PROJ_OUT_REPO_DOCS_SOURCE_DIR}
    -D PROJ_OUT_REPO_DOCS_LOCALE_DIR=${PROJ_OUT_REPO_DOCS_LOCALE_DIR}
    -D PROJ_OUT_BUILDER_DIR=${PROJ_OUT_BUILDER_DIR}
    -D PROJ_L10N_DIR=${PROJ_L10N_DIR}
    -D PROJ_L10N_VERSION_DIR=${PROJ_L10N_VERSION_DIR}
    -D PROJ_L10N_VERSION_LOCALE_DIR=${PROJ_L10N_VERSION_LOCALE_DIR}
    -D PROJ_L10N_VERSION_CROWDIN_DIR=${PROJ_L10N_VERSION_CROWDIN_DIR}
    # [Configuration Files]
    -D LANGUAGES_JSON_PATH=${LANGUAGES_JSON_PATH}
    -D REFERENCES_JSON_PATH=${REFERENCES_JSON_PATH}
    -D CROWDIN_YML_PATH=${CROWDIN_YML_PATH}
    -D STATISTIC_TXT_PATH=${STATISTIC_TXT_PATH}
    -D PREVIOUS_FREEZE_TXT_PATH=${PREVIOUS_FREEZE_TXT_PATH}
    -D PREVIOUS_REFERENCE_TXT_PATH=${PREVIOUS_REFERENCE_TXT_PATH}
    # [Other Variables]
    -D LANGUAGES_LIST=${LANGUAGES_LIST}
    -D VERSION_TYPE=${VERSION_TYPE}
    -D BRANCH_NAME=${BRANCH_NAME}
    -D TAG_PATTERN=${TAG_PATTERN}
    -D SPHINX_VERBOSE_ARGS=${SPHINX_VERBOSE_ARGS}
    -D FIND_PACKAGE_GIT_ARGS=${FIND_PACKAGE_GIT_ARGS}
    -D FIND_PACKAGE_CONDA_ARGS=${FIND_PACKAGE_CONDA_ARGS}
    -D FIND_PACKAGE_PYTHON_ARGS=${FIND_PACKAGE_PYTHON_ARGS}
    -D FIND_PACKAGE_GETTEXT_ARGS=${FIND_PACKAGE_GETTEXT_ARGS}
    -D FIND_PACKAGE_CROWDIN_ARGS=${FIND_PACKAGE_CROWDIN_ARGS})

#[====================[
  Fundamental targets.
#]====================]

add_custom_target(prepare_repositories
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE} 
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/prepare_repositories.cmake
    VERBATIM)

add_custom_target(install_requirements
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE} 
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/install_requirements.cmake
    VERBATIM)

add_custom_target(sphinx_update_pot
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE} 
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/sphinx_update_pot.cmake
    VERBATIM)

add_custom_target(gettext_update_po
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE} 
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/gettext_update_po.cmake
    VERBATIM)

add_custom_target(sphinx_build_docs
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE} 
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/sphinx_build_docs.cmake
    VERBATIM)

#[=================[
  Optional targets.
#]=================]

add_custom_target(gettext_statistic_po
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/gettext_statistic_po.cmake
    VERBATIM)

add_custom_target(crowdin_upload_pot
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE} 
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/crowdin_upload_pot.cmake
    VERBATIM)

add_custom_target(crowdin_download_po
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE} 
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/crowdin_download_po.cmake
    VERBATIM)

add_custom_target(gettext_compend_po
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/gettext_compend_po.cmake
    VERBATIM)

add_custom_target(readthedocs_symlinks
    COMMAND ${CMAKE_COMMAND}
            ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/readthedocs_symlinks.cmake
    VERBATIM)

if(AUTO_DEPEND)
    add_dependencies(install_requirements   prepare_repositories)
    add_dependencies(sphinx_update_pot      install_requirements)
    add_dependencies(gettext_update_po      sphinx_update_pot)
    add_dependencies(sphinx_build_docs      gettext_update_po)
endif()


# set(VERSION       "2")
# set(VERSION_TYPE  "tag")
# init_references_json_file(
#     IN_FILEPATH     "${PROJ_OUT_DIR}/${VERSION}/reference.json"
#     IN_VERSION      "${VERSION}"
#     IN_TYPE         "${VERSION_TYPE}"
#     IN_MODE         "language"
#     IN_LANGUAGE     "${LANGUAGES_LIST}"
#     )
# init_references_json_file(
#     IN_FILEPATH     "${PROJ_OUT_DIR}/${VERSION}/reference.json"
#     IN_VERSION      "${VERSION}"
#     IN_TYPE         "${VERSION_TYPE}"
#     IN_MODE         "repository"
#     IN_REPOSITORY   "conan"
#     )
# init_references_json_file(
#     IN_FILEPATH     "${PROJ_OUT_DIR}/develop2/docs.json"
#     IN_VERSION      "2"
#     IN_TYPE         "branch"
#     IN_MODE         "language"
#     IN_LANGUAGE     "${LANGUAGES_LIST}"
#     )
# init_references_json_file(
#     IN_FILEPATH     "${PROJ_OUT_DIR}/develop2/conan.json"
#     IN_VERSION      "2"
#     IN_TYPE         "branch"
#     IN_MODE         "repository"
#     IN_REPOSITORY   "conan"
#     )

# init_references_json_file(
#     IN_FILEPATH     "${PROJ_OUT_DIR}/git-master/docs.json"
#     IN_VERSION      "git-master"
#     IN_TYPE         "branch"
#     IN_MODE         "language"
#     IN_LANGUAGE     "${LANGUAGES_LIST}"
#     )
# init_references_json_file(
#     IN_FILEPATH     "${PROJ_OUT_DIR}/git-master/conan.json"
#     IN_VERSION      "git-master"
#     IN_TYPE         "branch"
#     IN_MODE         "repository"
#     IN_REPOSITORY   "torchdistx;torchvision"
#     )

# find_package(Sphinx)
# execute_process(
#     COMMAND ${Sphinx_BUILD_EXECUTABLE} --version
#     RESULT_VARIABLE _Sphinx_VERSION_RESULT
#     OUTPUT_VARIABLE _Sphinx_VERSION_OUTPUT  OUTPUT_STRIP_TRAILING_WHITESPACE
#     ERROR_VARIABLE  _Sphinx_VERSION_ERROR   ERROR_STRIP_TRAILING_WHITESPACE)
# message(STATUS "_Sphinx_VERSION_RESULT = ${_Sphinx_VERSION_RESULT}")
# message(STATUS "_Sphinx_VERSION_OUTPUT = ${_Sphinx_VERSION_OUTPUT}")
# message(STATUS "_Sphinx_VERSION_ERROR  = ${_Sphinx_VERSION_ERROR}")


set(SPHINX_VERBOSE_LEVEL "3")
# Set the default value for SPHINX_VERBOSE_LEVEL if not set
if(NOT DEFINED SPHINX_VERBOSE_LEVEL OR SPHINX_VERBOSE_LEVEL STREQUAL "")
    set(SPHINX_VERBOSE_LEVEL 0)
endif()
set(SPHINX_VERBOSE_ARGS "")
if(SPHINX_VERBOSE_LEVEL GREATER 0)
    set(SPHINX_VERBOSE_ARGS "-")
    math(EXPR REPEAT_COUNT "${SPHINX_VERBOSE_LEVEL} - 1")
    foreach(INDEX RANGE ${REPEAT_COUNT})
        set(SPHINX_VERBOSE_ARGS "${SPHINX_VERBOSE_ARGS}v")
    endforeach()
    unset(INDEX)
    unset(REPEAT_COUNT)
endif()
message(STATUS "SPHINX_VERBOSE_ARGS = ${SPHINX_VERBOSE_ARGS}")


# set(SPHINX_VERBOSE_LEVEL "2")
# message(STATUS "SPHINX_VERBOSE_LEVEL = ${SPHINX_VERBOSE_LEVEL}")
# # Set the default value for SPHINX_VERBOSE_LEVEL if not set
# if(NOT DEFINED SPHINX_VERBOSE_LEVEL OR SPHINX_VERBOSE_LEVEL STREQUAL "")
#     set(SPHINX_VERBOSE_LEVEL 0)
# endif()
# message(STATUS "SPHINX_VERBOSE_LEVEL = ${SPHINX_VERBOSE_LEVEL}")
# # Function to generate verbosity flags for sphinx-build
# function(get_sphinx_verbose_flags verbose_level output_var)
#     message(STATUS "verbose_level = ${verbose_level}")
#     if(verbose_level GREATER 0)
#         set(verbose_flags "-")
#         math(EXPR repeat_count "${verbose_level} - 1")
#         foreach(i RANGE ${repeat_count})
#             set(verbose_flags "${verbose_flags}v")
#         endforeach()
#         set(${output_var} "${verbose_flags}" PARENT_SCOPE)
#     else()
#         set(${output_var} "" PARENT_SCOPE)
#     endif()
# endfunction()
# get_sphinx_verbose_flags(${SPHINX_VERBOSE_LEVEL} SPHINX_VERBOSE_ARGS)
# message(STATUS "SPHINX_VERBOSE_ARGS = ${SPHINX_VERBOSE_ARGS}")

# set(TAG_LIST "v3.30.1;v3.30.0-rc4;v3.30.0-rc3;v3.30.0-rc2;v3.30.0-rc1;v3.30.0;v3.29.7;v3.29.6;v3.29.5;v3.29.4;v3.29.3;v3.29.2;v3.29.1;v3.29.0-rc4;v3.29.0-rc3;v3.29.0-rc2;v3.29.0-rc1;v3.29.0;v3.28.6;v3.28.5;v3.28.4;v3.28.3;v3.28.2;v3.28.1;v3.28.0-rc6;v3.28.0-rc5;v3.28.0-rc4;v3.28.0-rc3;v3.28.0-rc2;v3.28.0-rc1;v3.28.0;v3.27.9;v3.27.8;v3.27.7;v3.27.6;v3.27.5;v3.27.4;v3.27.3;v3.27.2;v3.27.1;v3.27.0-rc5;v3.27.0-rc4;v3.27.0-rc3;v3.27.0-rc2;v3.27.0-rc1;v3.27.0;v3.26.6;v3.26.5;v3.26.4;v3.26.3;v3.26.2;v3.26.1;v3.26.0-rc6;v3.26.0-rc5;v3.26.0-rc4;v3.26.0-rc3;v3.26.0-rc2;v3.26.0-rc1;v3.26.0;v3.25.3;v3.25.2;v3.25.1;v3.25.0-rc4;v3.25.0-rc3;v3.25.0-rc2;v3.25.0-rc1;v3.25.0;v3.24.4;v3.24.3;v3.24.2;v3.24.1;v3.24.0-rc5;v3.24.0-rc4;v3.24.0-rc3;v3.24.0-rc2;v3.24.0-rc1;v3.24.0;v3.23.5;v3.23.4;v3.23.3;v3.23.2;v3.23.1;v3.23.0-rc5;v3.23.0-rc4;v3.23.0-rc3;v3.23.0-rc2;v3.23.0-rc1;v3.23.0;v3.22.6;v3.22.5;v3.22.4;v3.22.3;v3.22.2;v3.22.1;v3.22.0-rc3;v3.22.0-rc2;v3.22.0-rc1;v3.22.0;v3.21.7;v3.21.6;v3.21.5;v3.21.4;v3.21.3;v3.21.2;v3.21.1;v3.21.0-rc3;v3.21.0-rc2;v3.21.0-rc1;v3.21.0;v3.20.6;v3.20.5;v3.20.4;v3.20.3;v3.20.2;v3.20.1;v3.20.0-rc5;v3.20.0-rc4;v3.20.0-rc3;v3.20.0-rc2;v3.20.0-rc1;v3.20.0;v3.19.8;v3.19.7;v3.19.6;v3.19.5;v3.19.4;v3.19.3;v3.19.2;v3.19.1;v3.19.0-rc3;v3.19.0-rc2;v3.19.0-rc1;v3.19.0;v3.18.6;v3.18.5;v3.18.4;v3.18.3;v3.18.2;v3.18.1;v3.18.0-rc4;v3.18.0-rc3;v3.18.0-rc2;v3.18.0-rc1;v3.18.0;v3.17.5;v3.17.4;v3.17.3;v3.17.2;v3.17.1;v3.17.0-rc3;v3.17.0-rc2;v3.17.0-rc1;v3.17.0;v3.16.9;v3.16.8;v3.16.7;v3.16.6;v3.16.5;v3.16.4;v3.16.3;v3.16.2;v3.16.1;v3.16.0-rc4;v3.16.0-rc3;v3.16.0-rc2;v3.16.0-rc1;v3.16.0;v3.15.7;v3.15.6;v3.15.5;v3.15.4;v3.15.3;v3.15.2;v3.15.1;v3.15.0-rc4;v3.15.0-rc3;v3.15.0-rc2;v3.15.0-rc1;v3.15.0;v3.14.7;v3.14.6;v3.14.5;v3.14.4;v3.14.3;v3.14.2;v3.14.1;v3.14.0-rc4;v3.14.0-rc3;v3.14.0-rc2;v3.14.0-rc1;v3.14.0;v3.13.5;v3.13.4;v3.13.3;v3.13.2;v3.13.1;v3.13.0-rc3;v3.13.0-rc2;v3.13.0-rc1;v3.13.0;v3.12.4;v3.12.3;v3.12.2;v3.12.1;v3.12.0-rc3;v3.12.0-rc2;v3.12.0-rc1;v3.12.0;v3.11.4;v3.11.3;v3.11.2;v3.11.1;v3.11.0-rc4;v3.11.0-rc3;v3.11.0-rc2;v3.11.0-rc1;v3.11.0;v3.10.3;v3.10.2;v3.10.1;v3.10.0-rc5;v3.10.0-rc4;v3.10.0-rc3;v3.10.0-rc2;v3.10.0-rc1;v3.10.0;v3.9.6;v3.9.5;v3.9.4;v3.9.3;v3.9.2;v3.9.1;v3.9.0-rc6;v3.9.0-rc5;v3.9.0-rc4;v3.9.0-rc3;v3.9.0-rc2;v3.9.0-rc1;v3.9.0;v3.8.2;v3.8.1;v3.8.0-rc4;v3.8.0-rc3;v3.8.0-rc2;v3.8.0-rc1;v3.8.0;v3.7.2;v3.7.1;v3.7.0-rc3;v3.7.0-rc2;v3.7.0-rc1;v3.7.0;v3.6.3;v3.6.2;v3.6.1;v3.6.0-rc4;v3.6.0-rc3;v3.6.0-rc2;v3.6.0-rc1;v3.6.0;v3.5.2;v3.5.1;v3.5.0-rc3;v3.5.0-rc2;v3.5.0-rc1;v3.5.0;v3.4.3;v3.4.2;v3.4.1;v3.4.0-rc3;v3.4.0-rc2;v3.4.0-rc1;v3.4.0;v3.3.2;v3.3.1;v3.3.0-rc4;v3.3.0-rc3;v3.3.0-rc2;v3.3.0-rc1;v3.3.0;v3.2.3;v3.2.2;v3.2.1;v3.2.0-rc2;v3.2.0-rc1;v3.2.0;v3.1.3;v3.1.2;v3.1.1;v3.1.0-rc3;v3.1.0-rc2;v3.1.0-rc1;v3.1.0;v3.0.2;v3.0.1;v3.0.0-rc6;v3.0.0-rc5;v3.0.0-rc4;v3.0.0-rc3;v3.0.0-rc2;v3.0.0-rc1;v3.0.0;v2.8.12.2;v2.8.12.1;v2.8.12;v2.8.11.2;v2.8.11.1;v2.8.11;v2.8.10.2;v2.8.10.1;v2.8.10;v2.8.9;v2.8.8;v2.8.7;v2.8.6;v2.8.5;v2.8.4;v2.8.3;v2.8.2;v2.8.1;v2.8.0;v2.6.4;v2.6.3;v2.6.2;v2.6.1;v2.6.0;v2.4.8;v2.4.7;v2.4.6;v2.4.5;v2.4.4;v2.4.3;v2.4.2;v2.4.1;v2.4.0")
# set(TAG_PATTERN "v3\\.2\\.")
# message(STATUS "TAG_PATTERN = ${TAG_PATTERN}")
# list(FILTER TAG_LIST INCLUDE REGEX "${TAG_PATTERN}")
# message(STATUS "TAG_LIST = ${TAG_LIST}")

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

set(MODE_OF_UPDATE "NEVER"
    CACHE STRING "Mode of updating .pot/.po files.")
    # Possible values are "NEVER", "COMPARE", and "ALWAYS".
    # 1) NEVER:   Update .pot/.po files only if the current reference is missing.
    # 2) COMPARE: Update .pot/.po files only if the current reference is different than the latest one.
    # 3) ALWAYS:  Update .pot/.po files even if the current reference is the same as    the latest one.

set(MODE_OF_INSTALL "COMPARE"
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

set(VERSION_OF_PYTHON "[default]"
    CACHE STRING "Python version to install.")

set(VERSION_OF_SPHINX "[default]"
    CACHE STRING "Sphinx version to install.")

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

set(SPHINX_CONSOLE_LOCALE "en_US.UTF-8"
    CACHE STRING "Locale setting for the console.")

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
set(REFERENCES_JSON_PATH            "${PROJ_L10N_VERSION_DIR}/references.json")
set(CROWDIN_YML_PATH                "${PROJ_L10N_VERSION_DIR}/crowdin.yml")
set(STATISTIC_TXT_PATH              "${PROJ_L10N_VERSION_DIR}/statistic.txt")
set(PREV_ENVIRONMENTS_YML_PATH      "${PROJ_VENV_DIR}/prev/environments.yml")
set(PREV_REFERENCE_TXT_PATH         "${PROJ_VENV_DIR}/prev/reference.txt")

set(CMAKE_MODULE_PATH "${PROJ_CMAKE_MODULES_DIR}")
include(JsonUtils)
include(LogUtils)

#[========================================[
  Read LANGUAGE_LIST from languages.json.
#]========================================]

file(READ "${LANGUAGES_JSON_PATH}"  LANGUAGES_JSON_CNT)
get_members_of_json_object(
    IN_JSON_OBJECT      "${LANGUAGES_JSON_CNT}"
    OUT_MEMBER_NAMES    LANGUAGE_LIST)

#[====================================[
  Validate the VERSION cache variable.
  - For "git-master":
    - Set VERSION_TYPE    to "branch"
    - Set BRANCH_NAME     to "master"
  - For "latest":
    - Set VERSION_TYPE    to "tag"
    - Set TAG_PATTERN     to "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)(-rc[1-9][0-9]*)?$"
    - Set TAG_SUFFIX      to "-rc"
  - For "v3.x":
    - Set VERSION_TYPE    to "tag"
    - Set TAG_PATTERN     to "^v3\\.x\\.([0-9]+)(-rc[1-9][0-9]*)?$"
    - Set TAG_SUFFIX      to "-rc"
#]====================================]

if (VERSION MATCHES     "^git-master$")
    set(VERSION_TYPE    "branch")
    set(BRANCH_NAME     "master")
elseif(VERSION MATCHES  "^latest$")
    set(VERSION_TYPE    "tag")
    set(TAG_PATTERN     "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)(-rc[1-9][0-9]*)?$")
    set(TAG_SUFFIX      "-rc")
elseif(VERSION MATCHES  "^v([0-9]+)\\.([0-9]+)$")
    set(VERSION_TYPE    "tag")
    string(REGEX REPLACE "\\." "\\\\." VERSION_ESCAPED "${VERSION}")
    set(TAG_PATTERN     "^${VERSION_ESCAPED}\\.([0-9]+)(-rc[1-9][0-9]*)?$")
    set(TAG_SUFFIX      "-rc")
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
    foreach(_LANGUAGE ${LANGUAGE_LIST})
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
  Validate the MODE_OF_UPDATE cache variable.
#]========================================]

if (NOT MODE_OF_UPDATE STREQUAL "COMPARE" AND 
    NOT MODE_OF_UPDATE STREQUAL "ALWAYS" AND 
    NOT MODE_OF_UPDATE STREQUAL "NEVER")
    message(FATAL_ERROR "Invalid MODE_OF_UPDATE value. (${MODE_OF_UPDATE})")
endif()

#[=========================================[
  Validate the MODE_OF_INSTALL cache variable.
#]=========================================]

if (NOT MODE_OF_INSTALL STREQUAL "COMPARE" AND 
    NOT MODE_OF_INSTALL STREQUAL "ALWAYS")
    message(FATAL_ERROR "Invalid MODE_OF_INSTALL value. (${MODE_OF_INSTALL})")
endif()

#[====================================================================[
  Initialize VERSION_OF_XXX if CACHE{VERSION_OF_XXX} is "[default]".
  Set VERSION_OF_XXX to $CACHE{VERSION_OF_XX} if it's not "[default]".
#]====================================================================]

if (VERSION MATCHES "^git-master$")
    set(VERSION_OF_PYTHON "3.10")
    set(VERSION_OF_SPHINX "6.2")
elseif (VERSION MATCHES "^latest$")
    set(VERSION_OF_PYTHON "3.10")
    set(VERSION_OF_SPHINX "6.2")
elseif (VERSION MATCHES  "^v([0-9]+)\\.([0-9]+)$")
    string(SUBSTRING "${VERSION}" 1 -1 VERSION_NO_V)
    if (VERSION_NO_V VERSION_LESS "3.9")        # For v3.0~v3.8
        set(VERSION_OF_PYTHON "3.6")
        set(VERSION_OF_SPHINX "1.6")
    elseif (VERSION_NO_V VERSION_LESS "3.19")   # For v3.9~v3.18
        set(VERSION_OF_PYTHON "3.6")
        set(VERSION_OF_SPHINX "2.4")
    elseif (VERSION_NO_V VERSION_LESS "3.28")   # For v3.19~v3.27
        set(VERSION_OF_PYTHON "3.10")
        set(VERSION_OF_SPHINX "5.3")
    else()                                      # For v3.28~
        set(VERSION_OF_PYTHON "3.10")
        set(VERSION_OF_SPHINX "6.2")
    endif()
endif()
if(NOT "$CACHE{VERSION_OF_PYTHON}" STREQUAL "[default]")
    set(VERSION_OF_PYTHON "$CACHE{VERSION_OF_PYTHON}")
endif()
if(NOT "$CACHE{VERSION_OF_SPHINX}" STREQUAL "[default]")
    set(VERSION_OF_SPHINX "$CACHE{VERSION_OF_SPHINX}")
endif()

#[====================[
  Check prerequisites.
#]====================]

find_package(Git      MODULE QUIET)
find_package(Conda    MODULE QUIET)
find_package(Gettext  MODULE QUIET)
find_package(Crowdin  MODULE QUIET)

#[==========================================================[
  Create Git Worktree for 'l10n' branch in ${PROJ_L10N_DIR}.
#]==========================================================]

execute_process(
    COMMAND ${Git_EXECUTABLE} ls-remote --heads --exit-code ${GIT_L10N_REMOTE_URL}
    RESULT_VARIABLE RES_VAR
    OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
if(NOT RES_VAR EQUAL 0)
    message(STATUS "The remote '${GIT_L10N_REMOTE_URL}' doesn't exist.")
else()
    message(STATUS "The remote '${GIT_L10N_REMOTE_URL}' exists. Check if 'l10n' branch exists.")
    execute_process(
        COMMAND ${Git_EXECUTABLE} ls-remote --heads --exit-code ${GIT_L10N_REMOTE_URL} l10n
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(NOT RES_VAR EQUAL 0)
        message(STATUS "The branch 'l10n' doesn't exist in the remote.")
    else()
        message(STATUS "The branch 'l10n' exist in the remote. Check if the git working tree exist.")
        if(EXISTS "${PROJ_L10N_DIR}/.git")
            message(STATUS "The git working tree exists: ${PROJ_L10N_DIR}")
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
            message(STATUS "The git working tree doesn't exist: ${PROJ_L10N_DIR}")
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
        endif()
    endif()
endif()

#[==============================================================[
  Initialize a references.json file in ${PROJ_L10N_VERSION_DIR}.
#]==============================================================]

init_references_json_file(
    IN_FILEPATH     "${REFERENCES_JSON_PATH}"
    IN_VERSION      "${VERSION}"
    IN_TYPE         "${VERSION_TYPE}"
    IN_MODE         "language"
    IN_LANGUAGE     "${LANGUAGE_LIST}")

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
message(STATUS "MODE_OF_UPDATE                   = ${MODE_OF_UPDATE}")
message(STATUS "MODE_OF_INSTALL                  = ${MODE_OF_INSTALL}")
message(STATUS "AUTO_DEPEND                   = ${AUTO_DEPEND}")
message(STATUS "REMOVE_REDUNDANT              = ${REMOVE_REDUNDANT}")
message(STATUS "GIT_REMOTE_URL                = ${GIT_REMOTE_URL}")
message(STATUS "BASEURL_HREF                  = ${BASEURL_HREF}")
message(STATUS "VERSION_COMPENDIUM            = ${VERSION_COMPENDIUM}")
message(STATUS "VERSION_OF_PYTHON             = ${VERSION_OF_PYTHON} (CACHE: $CACHE{VERSION_OF_PYTHON})")
message(STATUS "VERSION_OF_SPHINX             = ${VERSION_OF_SPHINX} (CACHE: $CACHE{VERSION_OF_SPHINX})")
message(STATUS "SPHINX_BUILDER                = ${SPHINX_BUILDER}")
message(STATUS "SPHINX_CONSOLE_LOCALE         = ${SPHINX_CONSOLE_LOCALE}")
message(STATUS "SPHINX_VERBOSE_LEVEL          = ${SPHINX_VERBOSE_LEVEL}")
message(STATUS "SPHINX_JOB_NUMBER             = ${SPHINX_JOB_NUMBER}")
message(STATUS "GETTEXT_WRAP_WIDTH            = ${GETTEXT_WRAP_WIDTH}")
message(STATUS "GETTEXT_ADDITIONAL_TARGETS    = ${GETTEXT_ADDITIONAL_TARGETS}")
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
message(STATUS "PREV_ENVIRONMENTS_YML_PATH    = ${PREV_ENVIRONMENTS_YML_PATH}")
message(STATUS "PREV_REFERENCE_TXT_PATH       = ${PREV_REFERENCE_TXT_PATH}")
message(STATUS "---------- Other Variables ----------")
message(STATUS "LANGUAGE_LIST                 = ${LANGUAGE_LIST}")
message(STATUS "VERSION_TYPE                  = ${VERSION_TYPE}")
message(STATUS "BRANCH_NAME                   = ${BRANCH_NAME}")
message(STATUS "TAG_PATTERN                   = ${TAG_PATTERN}")
message(STATUS "TAG_SUFFIX                    = ${TAG_SUFFIX}")
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

string(REPLACE ";" "\\\\;" LANGUAGE_LIST "${LANGUAGE_LIST}")

#[============================================[
  Environment variables passed to script mode.
#]============================================]

set(SCRIPT_MODE_ENV
    PYTHONNOUSERSITE=1)

#[======================================[
  Cache variables passed to script mode.
#]======================================]

set(SCRIPT_MODE_CACHE
    # [Cache Variables]
    -D LANGUAGE=${LANGUAGE}
    -D VERSION=${VERSION}
    -D AUTO_DEPEND=${AUTO_DEPEND}
    -D MODE_OF_UPDATE=${MODE_OF_UPDATE}
    -D MODE_OF_INSTALL=${MODE_OF_INSTALL}
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
    -D PREV_ENVIRONMENTS_YML_PATH=${PREV_ENVIRONMENTS_YML_PATH}
    -D PREV_REFERENCE_TXT_PATH=${PREV_REFERENCE_TXT_PATH}
    # [Other Variables]
    -D LANGUAGE_LIST=${LANGUAGE_LIST}
    -D VERSION_TYPE=${VERSION_TYPE}
    -D BRANCH_NAME=${BRANCH_NAME}
    -D TAG_PATTERN=${TAG_PATTERN}
    -D TAG_SUFFIX=${TAG_SUFFIX})

#[====================[
  Fundamental targets.
#]====================]

add_custom_target(prepare_repositories
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/prepare_repositories.cmake
    VERBATIM)

add_custom_target(install_requirements
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/install_requirements.cmake
    VERBATIM)

add_custom_target(sphinx_update_pot
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/sphinx_update_pot.cmake
    VERBATIM)

add_custom_target(gettext_update_po
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/gettext_update_po.cmake
    VERBATIM)

add_custom_target(sphinx_build_docs
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/sphinx_build_docs.cmake
    VERBATIM)

#[=================[
  Optional targets.
#]=================]

add_custom_target(gettext_statistic_po
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/gettext_statistic_po.cmake
    VERBATIM)

add_custom_target(crowdin_upload_pot
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/crowdin_upload_pot.cmake
    VERBATIM)

add_custom_target(crowdin_download_po
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/crowdin_download_po.cmake
    VERBATIM)

add_custom_target(gettext_compend_po
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/gettext_compend_po.cmake
    VERBATIM)

add_custom_target(readthedocs_symlinks
    COMMAND ${CMAKE_COMMAND} -E env ${SCRIPT_MODE_ENV}
            ${CMAKE_COMMAND} ${SCRIPT_MODE_CACHE}
            -P ${PROJ_CMAKE_SCRIPTS_DIR}/readthedocs_symlinks.cmake
    VERBATIM)

if(AUTO_DEPEND)
    add_dependencies(install_requirements   prepare_repositories)
    add_dependencies(sphinx_update_pot      install_requirements)
    add_dependencies(gettext_update_po      sphinx_update_pot)
    add_dependencies(sphinx_build_docs      gettext_update_po)
endif()

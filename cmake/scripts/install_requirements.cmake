# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH "${PROJ_CMAKE_MODULES_DIR}")
find_package(Git      MODULE REQUIRED)
find_package(Conda    MODULE REQUIRED)
include(GitUtils)
include(JsonUtils)
include(LogUtils)


message(STATUS "Determining which reference to switch to...")
file(READ "${REFERENCES_JSON_PATH}" REFERENCES_JSON_CNT)
get_json_value_by_dot_notation(
    IN_JSON_OBJECT      "${REFERENCES_JSON_CNT}"
    IN_DOT_NOTATION     ".pot"
    OUT_JSON_VALUE      CURRENT_POT_OBJECT)
if(VERSION_TYPE STREQUAL "branch")
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT          "${CURRENT_POT_OBJECT}"
        IN_DOT_NOTATION         ".commit.hash"
        OUT_JSON_VALUE          CURRENT_POT_COMMIT_HASH)
    get_git_latest_commit_on_branch_name(
        IN_REPO_PATH            "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE          "local"
        IN_BRANCH_NAME          "${BRANCH_NAME}"
        OUT_COMMIT_DATE         LATEST_POT_COMMIT_DATE
        OUT_COMMIT_HASH         LATEST_POT_COMMIT_HASH
        OUT_COMMIT_TITLE        LATEST_POT_COMMIT_TITLE)
    set_members_of_commit_json_object(
        IN_MEMBER_DATE          "\"${LATEST_POT_COMMIT_DATE}\""
        IN_MEMBER_HASH          "\"${LATEST_POT_COMMIT_HASH}\""
        IN_MEMBER_TITLE         "\"${LATEST_POT_COMMIT_TITLE}\""
        OUT_JSON_OBJECT         COMMIT_CNT)
    set_members_of_reference_json_object(
        IN_TYPE                 "branch"
        IN_MEMBER_BRANCH        "\"${BRANCH_NAME}\""
        IN_MEMBER_COMMIT        "${COMMIT_CNT}"
        OUT_JSON_OBJECT         LATEST_POT_OBJECT)
    set(CURRENT_POT_REFERENCE   "${CURRENT_POT_COMMIT_HASH}")
    set(LATEST_POT_REFERENCE    "${LATEST_POT_COMMIT_HASH}")
else()
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT          "${CURRENT_POT_OBJECT}"
        IN_DOT_NOTATION         ".tag"
        OUT_JSON_VALUE          CURRENT_POT_TAG)
    get_git_latest_tag_on_tag_pattern(
        IN_REPO_PATH            "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE          "local"
        IN_TAG_PATTERN          "${TAG_PATTERN}"
        IN_TAG_SUFFIX           "${TAG_SUFFIX}"
        OUT_TAG                 LATEST_POT_TAG)
    set_members_of_reference_json_object(
        IN_TYPE                 "tag"
        IN_MEMBER_TAG           "\"${LATEST_POT_TAG}\""
        OUT_JSON_OBJECT         LATEST_POT_OBJECT)
    set(CURRENT_POT_REFERENCE   "${CURRENT_POT_TAG}")
    set(LATEST_POT_REFERENCE    "${LATEST_POT_TAG}")
endif()
if(UPDATE_MODE STREQUAL "COMPARE")
    if(NOT CURRENT_POT_REFERENCE STREQUAL LATEST_POT_REFERENCE)
        set(SWITCH_REFERENCE    "${LATEST_POT_REFERENCE}")
    else()
        set(SWITCH_REFERENCE    "${CURRENT_POT_REFERENCE}")
    endif()
elseif(UPDATE_MODE STREQUAL "ALWAYS")
    set(SWITCH_REFERENCE        "${LATEST_POT_REFERENCE}")
elseif(UPDATE_MODE STREQUAL "NEVER")
    if(NOT CURRENT_POT_REFERENCE)
        set(SWITCH_REFERENCE    "${LATEST_POT_REFERENCE}")
    else()
        set(SWITCH_REFERENCE    "${CURRENT_POT_REFERENCE}")
    endif()
else()
    message(FATAL_ERROR "Invalid UNPDATE_MODE value. (${UPDATE_MODE})")
endif()
remove_cmake_message_indent()
message("")
message("latest = ${LATEST_POT_OBJECT}")
message("pot = ${CURRENT_POT_OBJECT}")
message("UPDATE_MODE            = ${UPDATE_MODE}")
message("LATEST_POT_REFERENCE   = ${LATEST_POT_REFERENCE}")
message("CURRENT_POT_REFERENCE  = ${CURRENT_POT_REFERENCE}")
message("SWITCH_REFERENCE       = ${SWITCH_REFERENCE}")
message("")
restore_cmake_message_indent()


message(STATUS "Switching to the reference '${SWITCH_REFERENCE}' on the local branch 'current'...")
remove_cmake_message_indent()
message("")
if(EXISTS "${PROJ_OUT_REPO_DIR}/.gitmodules")
    execute_process(
        COMMAND ${Git_EXECUTABLE} submodule deinit --all --force
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E rm -rf .git/modules
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("Remove directory '.git/modules'")
    message("")
endif()
execute_process(
    COMMAND ${Git_EXECUTABLE} checkout -B current
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} fetch origin
            ${SWITCH_REFERENCE}
            --depth=1
            --verbose
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} reset --hard FETCH_HEAD
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
if(EXISTS "${PROJ_OUT_REPO_DIR}/.gitmodules")
    execute_process(
        COMMAND ${Git_EXECUTABLE} submodule sync
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} submodule update
                --init
                --recursive
                --depth=1
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
endif()
restore_cmake_message_indent()


#[======================================================================[
  1. Determining whether to install the requirements.
  2. Run 'conda install' command to intall dependencies.
  3. Run 'pip install' command to install the requirements.
#]======================================================================]


message(STATUS "Determining whether to install the requirements...")
set(CURRENT_REFERENCE "${SWITCH_REFERENCE}")
if(EXISTS "${PREV_REFERENCE_TXT_PATH}")
    file(READ "${PREV_REFERENCE_TXT_PATH}" PREVIOUS_REFERENCE)
else()
    set(PREVIOUS_REFERENCE "")
endif()
if(INSTALL_MODE STREQUAL "COMPARE")
    if(NOT CURRENT_REFERENCE STREQUAL PREVIOUS_REFERENCE)
        set(INSTALL_REQUIRED ON)
    else()
        set(INSTALL_REQUIRED OFF)
    endif()
elseif(INSTALL_MODE STREQUAL "ALWAYS")
    set(INSTALL_REQUIRED ON)
else()
    message(FATAL_ERROR "Invalid INSTALL_MODE value. (${INSTALL_MODE})")
endif()
remove_cmake_message_indent()
message("")
message("INSTALL_MODE       = ${INSTALL_MODE}")
message("CURRENT_REFERENCE  = ${CURRENT_REFERENCE}")
message("PREVIOUS_REFERENCE = ${PREVIOUS_REFERENCE}")
message("INSTALL_REQUIRED   = ${INSTALL_REQUIRED}")
message("")
restore_cmake_message_indent()


if(NOT INSTALL_REQUIRED)
    message(STATUS "No need to install the requirements.")
    return()
else()
    message(STATUS "Prepare to install the requirements.")
endif()


message(STATUS "Running 'conda create' command to (re)create the virtual environemnt...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Conda_EXECUTABLE} create
            --prefix ${PROJ_VENV_DIR}
            --channel conda-forge
            --yes
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    RESULT_VARIABLE RES_VAR
    OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
if(RES_VAR EQUAL 0)
    if(ERR_VAR)
        string(APPEND WARNING_REASON
        "The command succeeded with warnings.\n"
        "    result:\n${RES_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message("${WARNING_REASON}")
    endif()
else()
    string(APPEND FAILURE_REASON
    "The command failed with fatal errors.\n"
    "    result:\n${RES_VAR}\n"
    "    stderr:\n${ERR_VAR}")
    message(FATAL_ERROR "${FAILURE_REASON}")
endif()
message("")
restore_cmake_message_indent()

#[[
message(STATUS "Creating 'pyvenv.cfg' in the virtual environment...")
set(PYVENV_CFG_PATH "${PROJ_VENV_DIR}/pyvenv.cfg")
if(NOT EXISTS "${PYVENV_CFG_PATH}")
    set(PYVENV_CFG_CONTENTS "include-system-site-packages = false\n")
else()
    file(READ "${PYVENV_CFG_PATH}" PYVENV_CFG_CONTENTS)
    if(PYVENV_CFG_CONTENTS MATCHES "include-system-site-packages")
        if(PYVENV_CFG_CONTENTS MATCHES "include-system-site-packages[ ]*=[ ]*true")
            string(REGEX REPLACE 
                "include-system-site-packages[ ]*=[ ]*true"
                "include-system-site-packages = false" 
                PYVENV_CFG_CONTENTS "${PYVENV_CFG_CONTENTS}")
        endif()
    else()
        string(APPEND PYVENV_CFG_CONTENTS "include-system-site-packages = false\n")
    endif()
endif()
file(WRITE "${PYVENV_CFG_PATH}" "${PYVENV_CFG_CONTENTS}")
remove_cmake_message_indent()
message("")
message("${PYVENV_CFG_PATH}")
message("${PYVENV_CFG_CONTENTS}")
message("")
restore_cmake_message_indent()
#]]

message(STATUS "Running 'conda install' command to install dependencies...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Conda_EXECUTABLE} install
            python=${VERSION_OF_PYTHON}
            sphinx=${VERSION_OF_SPHINX}
            --prefix ${PROJ_VENV_DIR}
            --channel conda-forge
            --yes
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    RESULT_VARIABLE RES_VAR
    OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
if(RES_VAR EQUAL 0)
    if(ERR_VAR)
        string(APPEND WARNING_REASON
        "The command succeeded with warnings.\n"
        "    result:\n${RES_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message("${WARNING_REASON}")
    endif()
else()
    string(APPEND FAILURE_REASON
    "The command failed with fatal errors.\n"
    "    result:\n${RES_VAR}\n"
    "    stderr:\n${ERR_VAR}")
    message(FATAL_ERROR "${FAILURE_REASON}")
endif()
message("")
restore_cmake_message_indent()


set(Python_ROOT_DIR "${PROJ_VENV_DIR}")
find_package(Python   MODULE REQUIRED)
message(STATUS "Running 'python -c \"import sys; print('\\n'.join(sys.path))\"' command to check python system paths...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Python_EXECUTABLE} -c "import sys; print('\\n'.join(sys.path))"
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE)
message("")
restore_cmake_message_indent()
set(Sphinx_ROOT_DIR "${PROJ_VENV_DIR}")
find_package(Sphinx   MODULE REQUIRED)


file(WRITE "${PREV_REFERENCE_TXT_PATH}" "${CURRENT_REFERENCE}")
execute_process(
    COMMAND ${Conda_EXECUTABLE} env export --prefix ${PROJ_VENV_DIR}
    OUTPUT_FILE "${PREV_ENVIRONMENTS_YML_PATH}")
# execute_process(
#     COMMAND ${Conda_EXECUTABLE} list --export --prefix ${PROJ_VENV_DIR}
#     OUTPUT_FILE "${PROJ_VENV_DIR}/prev/packages.txt")

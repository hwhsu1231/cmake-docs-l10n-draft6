# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.23)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH 
    "${PROJ_CMAKE_MODULES_DIR}"
    "${PROJ_CMAKE_MODULES_DIR}/common")
find_package(Git    MODULE ${FIND_PACKAGE_GIT_ARGS}    REQUIRED)
find_package(Python MODULE ${FIND_PACKAGE_PYTHON_ARGS} REQUIRED)
include(GitUtils)
include(JsonUtils)
include(LogUtils)


message(STATUS "Determining which reference to checkout...")
file(READ "${REFERENCE_JSON_PATH}" REFERENCE_JSON_CNT)
get_json_value_by_dot_notation(
    IN_JSON_OBJECT      "${REFERENCE_JSON_CNT}"
    IN_DOT_NOTATION     ".pot"
    OUT_JSON_VALUE      CURRENT_POT_OBJECT)
if(VERSION_TYPE STREQUAL "branch")
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT      "${CURRENT_POT_OBJECT}"
        IN_DOT_NOTATION     ".commit.hash"
        OUT_JSON_VALUE      CURRENT_POT_COMMIT_HASH)
    get_git_latest_commit_on_branch_name(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "local"
        IN_BRANCH_NAME      "${BRANCH_NAME}"
        OUT_COMMIT_DATE     LATEST_POT_COMMIT_DATE
        OUT_COMMIT_HASH     LATEST_POT_COMMIT_HASH
        OUT_COMMIT_TITLE    LATEST_POT_COMMIT_TITLE)
    set_members_of_commit_json_object(
        IN_MEMBER_DATE      "\"${LATEST_POT_COMMIT_DATE}\""
        IN_MEMBER_HASH      "\"${LATEST_POT_COMMIT_HASH}\""
        IN_MEMBER_TITLE     "\"${LATEST_POT_COMMIT_TITLE}\""
        OUT_JSON_OBJECT     COMMIT_CNT)
    set_members_of_language_json_object(
        IN_TYPE             "branch"
        IN_MEMBER_BRANCH    "\"${BRANCH_NAME}\""
        IN_MEMBER_COMMIT    "${COMMIT_CNT}"
        OUT_JSON_OBJECT     LATEST_POT_OBJECT)
    set(CURRENT_POT_REFERENCE   ${CURRENT_POT_COMMIT_HASH})
    set(LATEST_POT_REFERENCE    ${LATEST_POT_COMMIT_HASH})
else()
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT      "${CURRENT_POT_OBJECT}"
        IN_DOT_NOTATION     ".tag"
        OUT_JSON_VALUE      CURRENT_POT_TAG)
    get_git_latest_tag_on_tag_pattern(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "local"
        IN_TAG_PATTERN      "${TAG_PATTERN}"
        OUT_TAG             LATEST_POT_TAG)
    set_members_of_language_json_object(
        IN_TYPE             "tag"
        IN_MEMBER_TAG       "\"${LATEST_POT_TAG}\""
        OUT_JSON_OBJECT     LATEST_POT_OBJECT)
    set(CURRENT_POT_REFERENCE   ${CURRENT_POT_TAG})
    set(LATEST_POT_REFERENCE    ${LATEST_POT_TAG})
endif()
if(UPDATE_MODE STREQUAL "COMPARE")
    if(NOT CURRENT_POT_REFERENCE STREQUAL LATEST_POT_REFERENCE)
        set(CHECKOUT_REFERENCE  ${LATEST_POT_REFERENCE})
    else()
        set(CHECKOUT_REFERENCE  ${CURRENT_POT_REFERENCE})
    endif()
elseif(UPDATE_MODE STREQUAL "ALWAYS")
    set(CHECKOUT_REFERENCE      ${LATEST_POT_REFERENCE})
elseif(UPDATE_MODE STREQUAL "NEVER")
    if(NOT CURRENT_POT_REFERENCE)
        set(CHECKOUT_REFERENCE  ${LATEST_POT_REFERENCE})
    else()
        set(CHECKOUT_REFERENCE  ${CURRENT_POT_REFERENCE})
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
message("CHECKOUT_REFERENCE     = ${CHECKOUT_REFERENCE}")
message("")
restore_cmake_message_indent()


message(STATUS "Running 'git checkout -B' command to switch to the 'current' branch...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND 
        ${Git_EXECUTABLE} checkout -B current
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()
message(STATUS "Running 'git fetch' command to fetch the '${CHECKOUT_REFERENCE}' commit to FETCH_HEAD...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} fetch origin
            ${CHECKOUT_REFERENCE}
            --depth=1
            --verbose
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()
message(STATUS "Running 'git reset --hard' command to reset the 'current' branch from FETCH_HEAD...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} reset --hard FETCH_HEAD
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()


message(STATUS "Determining whether to remove the virtual environment...")
set(CURRENT_PYTHON_VERSION "${Python_VERSION}")
set(PYVENV_CFG_PATH "${PROJ_VENV_DIR}/pyvenv.cfg")
if(EXISTS "${PYVENV_CFG_PATH}")
    file(READ "${PYVENV_CFG_PATH}" PYVENV_CFG_CONTENT)
    string(REGEX MATCH    "version = [0-9]+\\.[0-9]+\\.[0-9]+" VERSION_LINE "${PYVENV_CFG_CONTENT}")
    string(REGEX REPLACE  "version = ([0-9]+\\.[0-9]+\\.[0-9]+)" "\\1" PREVIOUS_PYTHON_VERSION "${VERSION_LINE}")
    if(NOT CURRENT_PYTHON_VERSION STREQUAL PREVIOUS_PYTHON_VERSION)
        set(REMOVE_VENV_REQUIRED ON)
    else()
        set(REMOVE_VENV_REQUIRED OFF)
    endif()
else()
    set(REMOVE_VENV_REQUIRED OFF)
endif()
remove_cmake_message_indent()
message("")
message("CURRENT_PYTHON_VERSION   = ${CURRENT_PYTHON_VERSION}")
message("PREVIOUS_PYTHON_VERSION  = ${PREVIOUS_PYTHON_VERSION}")
message("REMOVE_VENV_REQUIRED     = ${REMOVE_VENV_REQUIRED}")
message("")
restore_cmake_message_indent()
if(REMOVE_VENV_REQUIRED)
    file(REMOVE_RECURSE "${PROJ_VENV_DIR}")
    message(STATUS "Removing the virtual environment '${PROJ_VENV_DIR}'...")
else()
    message(STATUS "No need to remove the virtual environment.")
endif()


message(STATUS "Running 'python -m venv' command to install a virtual environemnt...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Python_EXECUTABLE} -m venv ${PROJ_VENV_DIR}
    RESULT_VARIABLE RES_VAR
    OUTPUT_VARIABLE OUT_VAR
    ERROR_VARIABLE  ERR_VAR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE)
if(RES_VAR EQUAL 0)
    if(NOT ERR_VAR)
        message("The virtual environment is installed in:")
        message("${PROJ_VENV_DIR}")
    else()
        message("")
        message("---------- RES ----------")
        message("")
        message("${RES_VAR}")
        message("")
        message("---------- ERR ----------")
        message("")
        message("${ERR_VAR}")
        message("")
        message("-------------------------")
    endif()
else()
    message("")
    message("---------- RES ----------")
    message("")
    message("${RES_VAR}")
    message("")
    message("---------- OUT ----------")
    message("")
    message("${OUT_VAR}")
    message("")
    message("---------- ERR ----------")
    message("")
    message("${ERR_VAR}")
    message("")
    message("-------------------------")
    message("")
    message(FATAL_ERROR "Fatal error occurred.")
endif()
message("")
restore_cmake_message_indent()


message(STATUS "Determining whether to install the requirements...")
set(CURRENT_REFERENCE "${CHECKOUT_REFERENCE}")
if(EXISTS "${PREVIOUS_REFERENCE_TXT_PATH}")
    file(READ "${PREVIOUS_REFERENCE_TXT_PATH}" PREVIOUS_REFERENCE)
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
endif()


unset(Python_EXECUTABLE)
set(Python_ROOT_DIR "${PROJ_VENV_DIR}")
find_package(Python MODULE ${FIND_PACKAGE_PYTHON_ARGS} REQUIRED)


message(STATUS "Running 'pip install --upgrade' command to upgrade pip in the virtual environment...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Python_EXECUTABLE} -m pip install pip
            --upgrade
            --progress-bar off
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    RESULT_VARIABLE RES_VAR
    OUTPUT_VARIABLE OUT_VAR
    ERROR_VARIABLE  ERR_VAR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE)
if(RES_VAR EQUAL 0)
    if(ERR_VAR)
        # Success, but there might be some warnings.
        message("")
        message("---------- RES ----------")
        message("")
        message("${RES_VAR}")
        message("")
        message("---------- ERR ----------")
        message("")
        message("${ERR_VAR}")
        message("")
        message("-------------------------")
    endif()
else()
    message("")
    message("---------- RES ----------")
    message("")
    message("${RES_VAR}")
    message("")
    message("---------- ERR ----------")
    message("")
    message("${ERR_VAR}")
    message("")
    message("-------------------------")
    message("")
    message(FATAL_ERROR "Fatal error occurred!")
endif()
message("")
restore_cmake_message_indent()


if(EXISTS "${PREVIOUS_FREEZE_TXT_PATH}")
    message(STATUS "Running 'pip uninstall' command to uninstall the previous packages...")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Python_EXECUTABLE} -m pip uninstall -y
                --requirement ${PREVIOUS_FREEZE_TXT_PATH}
        ECHO_OUTPUT_VARIABLE
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR
        ERROR_VARIABLE  ERR_VAR
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
        if(ERR_VAR)
            # Success, but there might be some warnings.
            message("")
            message("---------- RES ----------")
            message("")
            message("${RES_VAR}")
            message("")
            message("---------- ERR ----------")
            message("")
            message("${ERR_VAR}")
            message("")
            message("-------------------------")
        endif()
    else()
        message("---------- RES ----------")
        message("")
        message("${RES_VAR}")
        message("")
        message("---------- ERR ----------")
        message("")
        message("${ERR_VAR}")
        message("")
        message("-------------------------")
        message("")
        message(FATAL_ERROR "Fatal error occurred.")
    endif()
    message("")
    restore_cmake_message_indent()
endif()


if(VERSION MATCHES "^git-master$")
    set(SPHINX_VERSION "6.2.1")
elseif(VERSION MATCHES "^latest$")
    set(SPHINX_VERSION "6.2.1")
else()
    string(SUBSTRING "${VERSION}" 1 -1 VERSION_NO_V)
    if(VERSION_NO_V VERSION_LESS "3.9")
        set(SPHINX_VERSION "1.6.1")           # For v3.0~v3.8
    elseif(VERSION_NO_V VERSION_LESS "3.19")
        set(SPHINX_VERSION "2.4.5")           # For v3.9~v3.18
    elseif(VERSION_NO_V VERSION_LESS "3.28")
        set(SPHINX_VERSION "5.3.0")           # For v3.19~v3.27
    else()
        set(SPHINX_VERSION "6.2.1")           # For v3.28~
    endif()
endif()
set(REQUIREMENTS_PATH "${PROJ_SOURCE_DIR}/requirements/sphinx-${SPHINX_VERSION}.txt")
file(READ "${REQUIREMENTS_PATH}" REQUIREMENTS_CNT)
message(STATUS "The requirements used will be:")
remove_cmake_message_indent()
message("")
message("${REQUIREMENTS_PATH}")
message("${REQUIREMENTS_CNT}")
message("")
restore_cmake_message_indent()


message(STATUS "Running 'pip install' command to install the requirements...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Python_EXECUTABLE} -m pip install 
            --progress-bar off
            --force-reinstall
            --requirement ${REQUIREMENTS_PATH}
    ECHO_OUTPUT_VARIABLE
    RESULT_VARIABLE RES_VAR
    OUTPUT_VARIABLE OUT_VAR
    ERROR_VARIABLE  ERR_VAR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE)
if(RES_VAR EQUAL 0)
    if(ERR_VAR)
        # Success, but there might be some warnings.
        message("")
        message("---------- RES ----------")
        message("")
        message("${RES_VAR}")
        message("")
        message("---------- ERR ----------")
        message("")
        message("${ERR_VAR}")
        message("")
        message("-------------------------")
    endif()
else()
    message("---------- RES ----------")
    message("")
    message("${RES_VAR}")
    message("")
    message("---------- ERR ----------")
    message("")
    message("${ERR_VAR}")
    message("")
    message("-------------------------")
    message("")
    message(FATAL_ERROR "Fatal error occurred.")
endif()
message("")
restore_cmake_message_indent()


file(WRITE "${PREVIOUS_REFERENCE_TXT_PATH}" ${CURRENT_REFERENCE})
execute_process(
    COMMAND ${Python_EXECUTABLE} -m pip freeze
    OUTPUT_FILE "${PREVIOUS_FREEZE_TXT_PATH}")

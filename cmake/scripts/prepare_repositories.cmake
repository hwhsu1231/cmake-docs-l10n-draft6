# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH 
    "${PROJ_CMAKE_MODULES_DIR}"
    "${PROJ_CMAKE_MODULES_DIR}/common")
find_package(Git MODULE REQUIRED)
include(GitUtils)
include(JsonUtils)
include(LogUtils)


message(STATUS "Running 'git clone' command to clone the upstream repository...")
if(NOT EXISTS "${PROJ_OUT_REPO_DIR}/.git")
    file(MAKE_DIRECTORY "${PROJ_OUT_REPO_DIR}")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} clone
                --depth=1
                --single-branch
                --recurse-submodules
                --shallow-submodules
                ${GIT_REMOTE_URL}
                ${PROJ_OUT_REPO_DIR}
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    restore_cmake_message_indent()
else()
    remove_cmake_message_indent()
    message("")
    message("The repository is already cloned to ${PROJ_OUT_REPO_DIR}")
    message("")
    restore_cmake_message_indent()
endif()


message(STATUS "Creating and switching to the local branch 'current'...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} checkout -B current
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()


message(STATUS "Running 'git clean -xfdf' command to remove untracked files/directories...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} clean -xfdf
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
if(EXISTS "${PROJ_OUT_REPO_DIR}/.gitmodules")
    execute_process(
        COMMAND ${Git_EXECUTABLE} submodule foreach --recursive git clean -xfdf
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
endif()
restore_cmake_message_indent()


if(VERSION_TYPE STREQUAL "branch")
    message(STATUS "Getting the latest commit of the branch '${BRANCH_NAME}' from the remote...")
    get_git_latest_commit_on_branch_name(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "remote"
        IN_BRANCH_NAME      "${BRANCH_NAME}"
        OUT_COMMIT_HASH     LATEST_COMMIT_HASH)
    remove_cmake_message_indent()
    message("")
    message("LATEST_COMMIT_HASH = ${LATEST_COMMIT_HASH}")
    message("")
    restore_cmake_message_indent()
    message(STATUS "Fetching the latest commit '${LATEST_COMMIT_HASH}' to the local branch '${BRANCH_NAME}'...")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} fetch origin
                ${LATEST_COMMIT_HASH}:refs/heads/${BRANCH_NAME}
                --depth=1
                --verbose
                --force   # To sovle the following error message:
                # POST git-upload-pack (102 bytes)
                # POST git-upload-pack (gzip 2235 to 841 bytes)
                # From https://gitlab.kitware.com/cmake/cmake
                #  ! [rejected]            34146501ffe30f14d0ca5b999b3ec407d27450fb -> master  (non-fast-forward)
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    restore_cmake_message_indent()
elseif(VERSION_TYPE STREQUAL "tag")
    message(STATUS "Getting the latest tag of '${TAG_PATTERN}' from the remote...")
    get_git_latest_tag_on_tag_pattern(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "remote"
        IN_TAG_PATTERN      "${TAG_PATTERN}"
        OUT_TAG             LATEST_TAG)
    remove_cmake_message_indent()
    message("")
    message("LATEST_TAG = ${LATEST_TAG}")
    message("")
    restore_cmake_message_indent()
    message(STATUS "Fetching the latest tag '${LATEST_TAG}' to the local tag '${LATEST_TAG}'...")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} fetch origin
                refs/tags/${LATEST_TAG}:refs/tags/${LATEST_TAG}
                --depth=1
                --verbose
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    restore_cmake_message_indent()
else()
    message(FATAL_ERROR "Invalid VERSION_TYPE value. (${VERSION_TYPE})")
endif()

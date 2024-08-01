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
set(Sphinx_ROOT_DIR "${PROJ_VENV_DIR}")
set(Python_ROOT_DIR "${PROJ_VENV_DIR}")
find_package(Git      MODULE REQUIRED)
find_package(Python   MODULE REQUIRED)
find_package(Gettext  MODULE REQUIRED COMPONENTS Msgcat Msgmerge)
find_package(Sphinx   MODULE REQUIRED COMPONENTS Build)
include(GitUtils)
include(JsonUtils)
include(LogUtils)


message(STATUS "Determining whether it is required to update .pot files...")
file(READ "${REFERENCES_JSON_PATH}" REFERENCES_JSON_CNT)
get_json_value_by_dot_notation(
    IN_JSON_OBJECT      "${REFERENCES_JSON_CNT}"
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
    set_members_of_reference_json_object(
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
    set_members_of_reference_json_object(
        IN_TYPE             "tag"
        IN_MEMBER_TAG       "\"${LATEST_POT_TAG}\""
        OUT_JSON_OBJECT     LATEST_POT_OBJECT)
    set(CURRENT_POT_REFERENCE   ${CURRENT_POT_TAG})
    set(LATEST_POT_REFERENCE    ${LATEST_POT_TAG})
endif()
if(UPDATE_MODE STREQUAL "COMPARE")
    if(NOT CURRENT_POT_REFERENCE STREQUAL LATEST_POT_REFERENCE)
        set(SWITCH_REFERENCE ${LATEST_POT_REFERENCE})
        set(UPDATE_REQUIRED ON)
    else()
        set(SWITCH_REFERENCE ${CURRENT_POT_REFERENCE})
        set(UPDATE_REQUIRED OFF)
    endif()
elseif(UPDATE_MODE STREQUAL "ALWAYS")
    set(SWITCH_REFERENCE ${LATEST_POT_REFERENCE})
    set(UPDATE_REQUIRED ON)
elseif(UPDATE_MODE STREQUAL "NEVER")
    if(NOT CURRENT_POT_REFERENCE)
        set(SWITCH_REFERENCE ${LATEST_POT_REFERENCE})
        set(UPDATE_REQUIRED ON)
    else()
        set(SWITCH_REFERENCE ${CURRENT_POT_REFERENCE})
        set(UPDATE_REQUIRED OFF)
    endif()
else()
    message(FATAL_ERROR "Invalid UNPDATE_MODE value. (${UPDATE_MODE})")
endif()
remove_cmake_message_indent()
message("")
message("latest = ${LATEST_POT_OBJECT}")
message(".pot = ${CURRENT_POT_OBJECT}")
message("UPDATE_MODE            = ${UPDATE_MODE}")
message("LATEST_POT_REFERENCE   = ${LATEST_POT_REFERENCE}")
message("CURRENT_POT_REFERENCE  = ${CURRENT_POT_REFERENCE}")
message("UPDATE_REQUIRED        = ${UPDATE_REQUIRED}")
message("SWITCH_REFERENCE       = ${SWITCH_REFERENCE}")
message("")
restore_cmake_message_indent()


#[[
message(STATUS "Running 'git checkout -B' command to switch to the 'current' branch...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} checkout -B current
    WORKING_DIRECTORY "${PROJ_OUT_REPO_DIR}"
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()
message(STATUS "Running 'git fetch' command to fetch the '${SWITCH_REFERENCE}' commit to FETCH_HEAD...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} fetch origin
            ${SWITCH_REFERENCE}
            --depth=1
            --verbose
    WORKING_DIRECTORY "${PROJ_OUT_REPO_DIR}"
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()
message(STATUS "Running 'git reset --hard' command to reset the 'current' branch from FETCH_HEAD...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} reset --hard
            FETCH_HEAD
    WORKING_DIRECTORY "${PROJ_OUT_REPO_DIR}"
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()
#]]
message(STATUS "Switching to the '${SWITCH_REFERENCE}' reference on the 'current' branch...")
remove_cmake_message_indent()
message("")
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
restore_cmake_message_indent()


message(STATUS "Generating the configuration file 'conf.py' by configuring project(CMakeHelp)...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${CMAKE_COMMAND} 
            -S ${PROJ_OUT_REPO_SPHINX_DIR}
            -B ${PROJ_OUT_REPO_SPHINX_DIR}/build
            # Enable SPHINX_HTML option to configure conf.py.in into conf.py.
            -D SPHINX_HTML=ON
            # Since find_program(SPHINX_EXECUTABLE) of CMake repo doesn't support to 
            # find sphinx-build inside the virtual environment currently, I have to 
            # specify it in advanced.
            -D SPHINX_EXECUTABLE=${Sphinx_BUILD_EXECUTABLE}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()
message(STATUS "Copying the configuration file 'conf.py'...")
file(COPY_FILE 
    "${PROJ_OUT_REPO_SPHINX_DIR}/build/conf.py"
    "${PROJ_OUT_REPO_DOCS_SOURCE_DIR}/conf.py")
remove_cmake_message_indent()
message("")
message("From: ${PROJ_OUT_REPO_SPHINX_DIR}/build/conf.py")
message("To:   ${PROJ_OUT_REPO_DOCS_SOURCE_DIR}/conf.py")
message("")
restore_cmake_message_indent()


if(NOT UPDATE_REQUIRED)
    message(STATUS "No need to update .pot files.")
    return()
else()
    message(STATUS "Prepare to update .pot files.")
endif()


if(SPHINX_VERBOSE_LEVEL GREATER 0)
    set(SPHINX_VERBOSE_ARGS "-")
    math(EXPR REPEAT_COUNT "${SPHINX_VERBOSE_LEVEL} - 1")
    foreach(INDEX RANGE ${REPEAT_COUNT})
        set(SPHINX_VERBOSE_ARGS "${SPHINX_VERBOSE_ARGS}v")
    endforeach()
    unset(INDEX)
    unset(REPEAT_COUNT)
else()
    set(SPHINX_VERBOSE_ARGS "")
endif()


message(STATUS "Running 'sphinx-build' command with 'gettext' builder to generate .pot files...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E env LANG=${SPHINX_CONSOLE_LOCALE}
            ${Sphinx_BUILD_EXECUTABLE}
            -b gettext
            -D version=${VERSION}                               # Specify 'Project-Id-Version' in .pot files.
            -D gettext_compact=0
            -D gettext_additional_targets=${GETTEXT_ADDITIONAL_TARGETS}
            -j ${SPHINX_JOB_NUMBER}
            ${SPHINX_VERBOSE_ARGS}
            -c ${PROJ_OUT_REPO_DOCS_CONFIG_DIR}                 # <configdir>, where conf.py locates.
            ${PROJ_OUT_REPO_DOCS_SOURCE_DIR}                    # <sourcedir>, where index.rst locates.
            ${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/pot/LC_MESSAGES    # <outputdir>, where .pot generates.
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


message(STATUS "Running 'msgcat' command to update 'sphinx.pot' file...")
execute_process(
    COMMAND ${Python_EXECUTABLE} -c "import sphinx; print(sphinx.__file__);"
    RESULT_VARIABLE RES_VAR
    OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
if(RES_VAR EQUAL 0)
    get_filename_component(SPHINX_LIB_DIR "${OUT_VAR}" DIRECTORY)
else()
    string(APPEND FAILURE_REASON
    "The command failed with fatal errors.\n"
    "    result:\n${RES_VAR}\n"
    "    stdout:\n${OUT_VAR}\n"
    "    stderr:\n${ERR_VAR}")
    message(FATAL_ERROR "${FAILURE_REASON}")
endif()
set(DEFAULT_SPHINX_POT_PATH "${SPHINX_LIB_DIR}/locale/sphinx.pot")
set(PACKAGE_SPHINX_POT_PATH "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/pot/LC_MESSAGES/sphinx.pot")
remove_cmake_message_indent()
message("")
message("From: ${DEFAULT_SPHINX_POT_PATH}")
message("To:   ${PACKAGE_SPHINX_POT_PATH}")
message("")
if(EXISTS "${PACKAGE_SPHINX_POT_PATH}")
    #
    # Concatenate the package 'sphinx.pot' with the default 'sphinx.pot'.
    #
    message("msgcat:")
    message("  --use-first")
    message("  --width        ${GETTEXT_WRAP_WIDTH}")
    message("  --output-file  ${PACKAGE_SPHINX_POT_PATH}")
    message("  [inputfile]    ${PACKAGE_SPHINX_POT_PATH}")
    message("  [inputfile]    ${DEFAULT_SPHINX_POT_PATH}")
    execute_process(
        COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                --use-first
                --width ${GETTEXT_WRAP_WIDTH}
                --output-file ${PACKAGE_SPHINX_POT_PATH}
                ${PACKAGE_SPHINX_POT_PATH}  # [inputfile]
                ${DEFAULT_SPHINX_POT_PATH}  # [inputfile]
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
else()
    #
    # Generate the package 'sphinx.pot' from the default 'sphinx.pot'.
    #
    message("msgcat:")
    message("  --use-first")
    message("  --width        ${GETTEXT_WRAP_WIDTH}")
    message("  --output-file  ${PACKAGE_SPHINX_POT_PATH}")
    message("  [inputfile]    ${DEFAULT_SPHINX_POT_PATH}")
    execute_process(
        COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                --width ${GETTEXT_WRAP_WIDTH} 
                --output-file ${PACKAGE_SPHINX_POT_PATH}
                ${DEFAULT_SPHINX_POT_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
endif()
message("")
restore_cmake_message_indent()


message(STATUS "Running 'msgmerge/msgcat' command to update .pot files...")
set(SRC_POT_DIR "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/pot/LC_MESSAGES")
set(DST_POT_DIR "${PROJ_L10N_VERSION_LOCALE_DIR}/pot/LC_MESSAGES")
file(GLOB_RECURSE SRC_POT_FILES "${SRC_POT_DIR}/*.pot")
remove_cmake_message_indent()
message("")
message("From: ${SRC_POT_DIR}/")
message("To:   ${DST_POT_DIR}/")
message("")
foreach(SRC_POT_FILE ${SRC_POT_FILES})
    string(REPLACE "${SRC_POT_DIR}/" "" SRC_POT_FILE_RELATIVE "${SRC_POT_FILE}")
    set(DST_POT_FILE "${DST_POT_DIR}/${SRC_POT_FILE_RELATIVE}")
    get_filename_component(DST_POT_FILE_DIR "${DST_POT_FILE}" DIRECTORY)
    file(MAKE_DIRECTORY "${DST_POT_FILE_DIR}")
    if(EXISTS "${DST_POT_FILE}")
        # If the ${DST_POT_FILE} exists, then merge it using msgmerge.
        message("msgmerge:")
        message("  --width      ${GETTEXT_WRAP_WIDTH}")
        message("  --backup     off")
        message("  --update")
        message("  --force-po")
        message("  --no-fuzzy-matching")
        message("  [def.po]     ${DST_POT_FILE}")
        message("  [ref.pot]    ${SRC_POT_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                    --width ${GETTEXT_WRAP_WIDTH} 
                    --backup off
                    --update
                    --force-po
                    --no-fuzzy-matching
                    ${DST_POT_FILE}   # [def.po]
                    ${SRC_POT_FILE}   # [ref.pot]
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${RES_VAR}\n"
            "    stdout:\n${OUT_VAR}\n"
            "    stderr:\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    else()
        # If the ${DST_POT_FILE} doesn't exist, then create it using msgcat.
        message("msgcat:")
        message("  --width        ${GETTEXT_WRAP_WIDTH}")
        message("  --output-file  ${DST_POT_FILE}")
        message("  [inputfile]    ${SRC_POT_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                    --width ${GETTEXT_WRAP_WIDTH}
                    --output-file ${DST_POT_FILE}
                    ${SRC_POT_FILE}   # [inputfile]
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${RES_VAR}\n"
            "    stdout:\n${OUT_VAR}\n"
            "    stderr:\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    endif()
endforeach()
unset(SRC_POT_FILE)
message("")
restore_cmake_message_indent()


set_json_value_by_dot_notation(
    IN_JSON_OBJECT      "${REFERENCES_JSON_CNT}"
    IN_DOT_NOTATION     ".pot"
    IN_JSON_VALUE       "${LATEST_POT_OBJECT}"
    OUT_JSON_OBJECT     REFERENCES_JSON_CNT)


file(WRITE "${REFERENCES_JSON_PATH}" ${REFERENCES_JSON_CNT})

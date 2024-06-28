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
set(Sphinx_ROOT_DIR "${PROJ_VENV_DIR}")
find_package(Git      MODULE ${FIND_PACKAGE_GIT_ARGS}     REQUIRED)
find_package(Gettext  MODULE ${FIND_PACKAGE_GETTEXT_ARGS} REQUIRED)
find_package(Sphinx   MODULE REQUIRED)
include(JsonUtils)
include(LogUtils)
set(ENV{LANG} "${CONSOLE_LOCALE}")


if(NOT LANGUAGE STREQUAL "all")
    set(PO_SRC_DIR "${PROJ_L10N_VERSION_LOCALE_DIR}/${LANGUAGE}/LC_MESSAGES")
    set(PO_DST_DIR "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/${LANGUAGE}/LC_MESSAGES")
else()
    set(PO_SRC_DIR "${PROJ_L10N_VERSION_LOCALE_DIR}")
    set(PO_DST_DIR "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}")
endif()
message(STATUS "Copying .po files to the cloned repository...")
remove_cmake_message_indent()
message("")
message("From: ${PO_SRC_DIR}/")
message("To:   ${PO_DST_DIR}/")
message("")
file(GLOB_RECURSE PO_SRC_FILES "${PO_SRC_DIR}/*.po")
foreach(PO_SRC_FILE ${PO_SRC_FILES})
    string(REPLACE "${PO_SRC_DIR}/" "" PO_SRC_FILE_RELATIVE "${PO_SRC_FILE}")
    set(PO_DST_FILE "${PO_DST_DIR}/${PO_SRC_FILE_RELATIVE}")
    get_filename_component(PO_DST_FILE_DIR "${PO_DST_FILE}" DIRECTORY)
    file(MAKE_DIRECTORY "${PO_DST_FILE_DIR}")
    file(COPY_FILE "${PO_SRC_FILE}" "${PO_DST_FILE}" RESULT RES_VAR)
    message("Copied: ${PO_DST_FILE}")
endforeach()
unset(PO_SRC_FILE)
message("")
restore_cmake_message_indent()


file(RELATIVE_PATH LOCALE_TO_SOURCE_DIR
    "${PROJ_OUT_REPO_DOCS_SOURCE_DIR}"
    "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}")
if(NOT LANGUAGE STREQUAL "all")
    set(LANGUAGES_LIST "${LANGUAGE}")
endif()
foreach(_LANGUAGE ${LANGUAGES_LIST})
    message(STATUS "Running 'sphinx-build' command with '${BUILDER}' builder to build HTML documentation for '${_LANGUAGE}' language...")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Sphinx_BUILD_EXECUTABLE}
                -b ${BUILDER}
                -D locale_dirs=${LOCALE_TO_SOURCE_DIR}            # Relative to <sourcedir>
                -D language=${_LANGUAGE}
                -D gettext_compact=0
                -D gettext_additional_targets=${SPHINX_ADDITIONAL_TARGETS}
                -A versionswitch=1
                -j ${SPHINX_JOB_NUMBER}
                -v
                -c ${PROJ_OUT_REPO_DOCS_CONFIG_DIR}               # <configdir>, where conf.py locates.
                ${PROJ_OUT_REPO_DOCS_SOURCE_DIR}                  # <sourcedir>, where index.rst locates.
                ${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}   # <outputdir>, where .html generates.
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
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
        message(FATAL_ERROR "Fatal error occurred.")
    endif()
    message("")
    restore_cmake_message_indent()


    if(REMOVE_REDUNDANT)
        message(STATUS "Removing redundant files/directories...")
        file(REMOVE_RECURSE "${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/.doctrees/")
        file(REMOVE         "${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/.buildinfo")
        file(REMOVE         "${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/objects.inv")
        remove_cmake_message_indent()
        message("")
        message("Removing ${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/.doctrees/...")
        message("Removing ${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/.buildinfo...")
        message("Removing ${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/objects.inv...")
        message("")
        restore_cmake_message_indent()
    endif()


    if(BUILDER MATCHES "^html$")
        message(STATUS "Coying 'version_switch.js' file to the html output directory...")
        set(PROTOCOLS "file:///" "https://")
        foreach(PROTOCOL ${PROTOCOLS})
            string(REGEX REPLACE "${PROTOCOL}" "" BASEURL ${BASEURL_HREF})
            if(NOT "${BASEURL}" STREQUAL "${BASEURL_HREF}")
                break()
            endif()
        endforeach()
        unset(PROTOCOL)
        set(LANGURL_HREF  "${BASEURL_HREF}/${_LANGUAGE}")
        set(LANGURL       "${BASEURL}/${_LANGUAGE}")
        set(LANGURL_RE    "${BASEURL}/${_LANGUAGE}")
        string(REPLACE "." "\\." LANGURL_RE "${LANGURL_RE}")
        string(REPLACE "/" "\\/" LANGURL_RE "${LANGURL_RE}")
        remove_cmake_message_indent()
        message("")
        message("From: ${PROJ_CMAKE_TEMPLATES_DIR}/version_switch.js.in")
        message("To:   ${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/version_switch.js")
        message("")
        message("BASEURL_HREF = ${BASEURL_HREF}")
        message("BASEURL      = ${BASEURL}")
        message("LANGURL_HREF = ${LANGURL_HREF}")
        message("LANGURL      = ${LANGURL}")
        message("LANGURL_RE   = ${LANGURL_RE}")
        message("")
        restore_cmake_message_indent()
        configure_file(
            "${PROJ_CMAKE_TEMPLATES_DIR}/version_switch.js.in"
            "${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/version_switch.js"
            @ONLY)
    endif()
endforeach()
unset(_LANGUAGE)


message(STATUS "The '${BUILDER}' documentation is built succesfully!")

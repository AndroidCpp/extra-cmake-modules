#.rst:
# KDETemplateGenerator
# -------------------
#
# Packages KApptemplate/KDevelop compatible application templates
#
# This module provides a functionality to package in a tarball and
# install project templates compatible with the format used by
# KApptemplate and KDevelop. Useful for providing minimal examples
# for the usage of the KDE Frameworks.
#
# This module provides the following function:
#
# kde_package_app_templates( TEMPLATES template1 [template2] [...] INSTALL_DIR directory)
#
# INSTALL_DIR is the directory to install the template package to.
# In most cases you will want to use the variable KDE_INSTALL_KTEMPLATESDIR
# from :kde-module:`KDEInstallDirs`.
#
# TEMPLATES lists subdirectories containing template files;
# each ``<template>`` directory will be packaged into a file named
# ``<template>.tar.bz2`` and installed to the appropriate location.
#
# The template is a minimal source tree of an application as if it was
# an application project by itself, with names (file names or text inside)
# the text files replaced by the following placeholders when needed:
#
# ``%{PROJECTDIRNAME}``
#     %{APPNAMELC}-%{VERSION} for KAppTemplate
# ``%{APPNAME}``
#     project name as entered by user ex: MyKApp
# ``%{APPNAMELC}``
#     project name in lower case ex: mykapp
# ``%{APPNAMEUC}``
#     project name in upper case ex: MYKAPP
#
# ``%{CPP_TEMPLATE}``
#     license header for cpp file
# ``%{H_TEMPLATE}``
#     license header for h file
#
# ``%{AUTHOR}``
#     author name ex: George Ignacious
# ``%{EMAIL}``
#     author email ex: foo@bar.org
# ``%{VERSION}``
#     project version ex: 0.1
#
# ``%{dest}``
#    used in .kdevtemplate
# ``%{src}``
#    used in .kdevtemplate
#
# Multiple templates can be passed at once.
#
#
# Since 5.18

#=============================================================================
# Copyright 2015      Marco Martin <mart@kde.org>
# Copyright 2014      Simon Wächter<waechter.simon@gmail.com>
# Copyright 2013      Nico Kruber<nico.kruber@gmail.com>
# Copyright 2012      Jeremy Whiting <jpwhiting@kde.org>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file COPYING-CMAKE-SCRIPTS for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of extra-cmake-modules, substitute the full
#  License text for the above reference.)

include(CMakeParseArguments)

function(kde_package_app_templates)
    set(_oneValueArgs INSTALL_DIR)
    set(_multiValueArgs TEMPLATES)
    cmake_parse_arguments(ARG "" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )

    if(NOT ARG_TEMPLATES)
        message(FATAL_ERROR "No TEMPLATES argument given to kde_package_app_templates")
    endif()

    if(NOT ARG_INSTALL_DIR)
        message(FATAL_ERROR "No INSTALL_DIR argument given to kde_package_app_templates")
    endif()

    foreach(_templateName ${ARG_TEMPLATES})

        get_filename_component(_tmp_file ${_templateName} ABSOLUTE)
        get_filename_component(_baseName ${_tmp_file} NAME_WE)
        set(_template ${CMAKE_CURRENT_BINARY_DIR}/${_baseName}.tar.bz2)

        file(GLOB _files "${CMAKE_CURRENT_SOURCE_DIR}/${_templateName}/*")
        set(_deps)
        foreach(_file ${_files})
            get_filename_component(_fileName ${_file} NAME)
            string(COMPARE NOTEQUAL ${_fileName} .kdev_ignore _v1)
            string(REGEX MATCH "\\.svn" _v2 ${_fileName})
            if(WIN32)
                string(REGEX MATCH "_svn" _v3 ${_fileName})
            else(WIN32)
                set(_v3 FALSE)
            endif()
            if (_v1 AND NOT _v2 AND NOT _v3)
                set(_deps ${_deps} ${_file})
            endif ()
        endforeach()

        add_custom_target(${_baseName} ALL DEPENDS ${_template})

        add_custom_command(OUTPUT ${_template}
             COMMAND ${CMAKE_COMMAND} -E tar "cvfj" ${_template} .
             WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${_templateName}
        )


        install(FILES ${_template} DESTINATION ${ARG_INSTALL_DIR})
        set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${_template}")

    endforeach()
endfunction()

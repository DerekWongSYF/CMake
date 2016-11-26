if(GENERATOR_TYPE STREQUAL "DEB")
  set(CPACK_PACKAGE_CONTACT "someone")
  set(CPACK_DEB_COMPONENT_INSTALL "ON")
  #intentionaly commented out to test old file naming
  #set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")

  # false by default
  set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS FALSE)
  # FIXME can not be tested as libraries first have to be part of a package in order
  # to determine their dependencies and we can not be certain if there will be any
  set(CPACK_DEBIAN_APPLICATIONS_AUTO_PACKAGE_SHLIBDEPS TRUE)

  foreach(dependency_type_ DEPENDS CONFLICTS PREDEPENDS ENHANCES BREAKS REPLACES RECOMMENDS SUGGESTS)
    string(TOLOWER "${dependency_type_}" lower_dependency_type_)

    set(CPACK_DEBIAN_PACKAGE_${dependency_type_} "${lower_dependency_type_}-default, ${lower_dependency_type_}-default-b")
    set(CPACK_DEBIAN_APPLICATIONS_PACKAGE_${dependency_type_} "${lower_dependency_type_}-application, ${lower_dependency_type_}-application-b")
    set(CPACK_DEBIAN_APPLICATIONS_AUTO_PACKAGE_${dependency_type_} "${lower_dependency_type_}-application, ${lower_dependency_type_}-application-b")
    set(CPACK_DEBIAN_HEADERS_PACKAGE_${dependency_type_} "${lower_dependency_type_}-headers")
  endforeach()

  set(CPACK_DEBIAN_PACKAGE_PROVIDES "provided-default, provided-default-b")
  set(CPACK_DEBIAN_LIBS_PACKAGE_PROVIDES "provided-lib")
  set(CPACK_DEBIAN_LIBS_AUTO_PACKAGE_PROVIDES "provided-lib_auto, provided-lib_auto-b")
elseif(GENERATOR_TYPE STREQUAL "RPM")
  set(CPACK_RPM_COMPONENT_INSTALL "ON")

  # FIXME auto autoprov is not tested at the moment as Ubuntu 15.04 rpmbuild
  # does not use them correctly: https://bugs.launchpad.net/rpm/+bug/1475755
  set(CPACK_RPM_PACKAGE_AUTOREQ "no")
  set(CPACK_RPM_PACKAGE_AUTOPROV "no")
  set(CPACK_RPM_APPLICATIONS_AUTO_PACKAGE_AUTOREQPROV "yes")
  set(CPACK_RPM_LIBS_AUTO_PACKAGE_AUTOREQPROV "yes")

  set(CPACK_RPM_PACKAGE_REQUIRES "depend-default, depend-default-b")
  set(CPACK_RPM_APPLICATIONS_PACKAGE_REQUIRES "depend-application, depend-application-b")
  set(CPACK_RPM_APPLICATIONS_AUTO_PACKAGE_REQUIRES "depend-application, depend-application-b")
  set(CPACK_RPM_HEADERS_PACKAGE_REQUIRES "depend-headers")

  set(CPACK_RPM_PACKAGE_CONFLICTS "conflict-default, conflict-default-b")
  set(CPACK_RPM_APPLICATIONS_PACKAGE_CONFLICTS "conflict-application, conflict-application-b")
  set(CPACK_RPM_APPLICATIONS_AUTO_PACKAGE_CONFLICTS "conflict-application, conflict-application-b")
  set(CPACK_RPM_HEADERS_PACKAGE_CONFLICTS "conflict-headers")

  set(CPACK_RPM_PACKAGE_PROVIDES "provided-default, provided-default-b")
  set(CPACK_RPM_LIBS_PACKAGE_PROVIDES "provided-lib")
  set(CPACK_RPM_LIBS_AUTO_PACKAGE_PROVIDES "provided-lib_auto, provided-lib_auto-b")
endif()

set(CMAKE_BUILD_WITH_INSTALL_RPATH 1)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/test_lib.hpp"
    "int test_lib();\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/test_lib.cpp"
    "#include \"test_lib.hpp\"\nint test_lib() {return 0;}\n")
add_library(test_lib SHARED "${CMAKE_CURRENT_BINARY_DIR}/test_lib.cpp")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/main.cpp"
    "#include \"test_lib.hpp\"\nint main() {return test_lib();}\n")
add_executable(test_prog "${CMAKE_CURRENT_BINARY_DIR}/main.cpp")
target_link_libraries(test_prog test_lib)

install(TARGETS test_prog DESTINATION foo COMPONENT applications)
install(TARGETS test_prog DESTINATION foo_auto COMPONENT applications_auto)
install(FILES CMakeLists.txt DESTINATION bar COMPONENT headers)
install(TARGETS test_lib DESTINATION bas COMPONENT libs)
install(TARGETS test_lib DESTINATION bas_auto COMPONENT libs_auto)

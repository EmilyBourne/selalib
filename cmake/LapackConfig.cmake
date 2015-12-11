
GET_FILENAME_COMPONENT(Fortran_COMPILER_NAME "${CMAKE_Fortran_COMPILER}" NAME)

SET(USE_MKL OFF CACHE BOOL "Using Intel Math Kernel Library")


IF(Fortran_COMPILER_NAME MATCHES "ifort")
   IF(DEFINED ENV{MKLROOT})
      IF(USE_MKL_WAS_ON AND NOT USE_MKL)
         MESSAGE("WARNING: when MKLROOT is defined MKL library must be used. Now setting 'USE_MKL=ON'...")
      ENDIF()
      SET(USE_MKL ON CACHE BOOL "Using Intel Math Kernel Library" FORCE)
      SET(USE_MKL_WAS_ON true CACHE INTERNAL "Previous value of USE_MKL flag")
   ELSE()
      MESSAGE(STATUS "Environment variable is not set, please load mkl vars")
   ENDIF()
ENDIF()

IF(USE_MKL)

   SET(BLA_VENDOR "Intel")

   STRING(REGEX REPLACE "^([^:]*):" " " MKLROOT $ENV{MKLROOT})
   MESSAGE(STATUS "MKLROOT:${MKLROOT}")
   INCLUDE_DIRECTORIES(${MKLROOT}/include/intel64/lp64 ${MKLROOT}/include)
   SET(BLAS_FOUND TRUE)
   IF(APPLE)
      SET(LAPACK_LIBRARIES "-mkl")
   ELSE()
      SET(LAPACK_LIBRARIES "-Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_sequential.a -Wl,--end-group -lm")
   ENDIF(APPLE)
   SET(BLAS_LIBRARIES ${LAPACK_LIBRARIES})
   SET(LAPACK_FOUND TRUE)

ELSE()

   IF(APPLE)
      SET(BLA_VENDOR "Apple")
   ENDIF(APPLE)
   FIND_PACKAGE(BLAS   QUIET)
   FIND_PACKAGE(LAPACK QUIET)

ENDIF()

IF(LAPACK_FOUND AND BLAS_FOUND)

ELSE(LAPACK_FOUND AND BLAS_FOUND)

  MESSAGE(STATUS "Failed to link LAPACK, BLAS, ATLAS libraries with environments")
  MESSAGE(STATUS "Going to search LAPACK standard paths.")
  FIND_LIBRARY(LAPACK_LIBRARIES NAMES lapack HINTS /opt/local /usr/local PATH_SUFFIXES lib)
  FIND_LIBRARY(BLAS_LIBRARIES NAMES blas HINTS /opt/local /usr/local PATH_SUFFIXES lib)

  IF(LAPACK_LIBRARIES AND BLAS_LIBRARIES)

  ELSE()

     MESSAGE(SEND_ERROR "LAPACK NOT FOUND")
     SET(LAPACK_LIBRARIES " ")
     SET(BLAS_LIBRARIES " ")
 
  ENDIF(LAPACK_LIBRARIES AND BLAS_LIBRARIES)

ENDIF(LAPACK_FOUND AND BLAS_FOUND)

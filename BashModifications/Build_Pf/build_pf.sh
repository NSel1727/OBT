#!/bin/bash

SOURCE_DIR=$1

BUILD_TYPE=RelWithDebInfo

if [[ "$2" != "" ]]
then
    BUILD_TYPE=$2
fi

echo "Build type: ${BUILD_TYPE}"

[ -z $BUILD_DOCS ] && BUILD_DOCS=1

echo "Docs build: ${BUILD_DOCS}"

[ -z $TEST_PLUGINS ] && TEST_PLUGINS=1

echo "Plugins build: ${TEST_PLUGINS}"

[ -z $USE_CPPUNIT ] && USE_CPPUNIT=1

echo "Unittests build: ${USE_CPPUNIT}"

[ -z $MAKE_WSSQL ] && MAKE_WSSQL=0

echo "WSSql build: ${MAKE_WSSQL}"

[ -z $USE_LIBMEMCACHED ] && USE_LIBMEMCACHED=0

echo "WSSql build: ${USE_LIBMEMCACHED}"

[ -z $ECLWATCH_BUILD_STRATEGY ] && ECLWATCH_BUILD_STRATEGY=IF_MISSING

echo "ECLWatch strategy: ${ECLWATCH_BUILD_STRATEGY}"

[ -z $ENABLE_SPARK ] && ENABLE_SPARK=0

echo "Enable Spark: ${ENABLE_SPARK}"

[ -z $SUPPRESS_SPARK ] && SUPPRESS_SPARK=1

echo "Suppress Spark: ${SUPPRESS_SPARK}"

[ -z $SUPPRESS_PLUGINS ] && SUPPRESS_PLUGINS=''

echo "Suppress plugins: ${SUPRESS_PLUGINS}"

echo "PYTHON_PLUGIN: ${PYTHON_PLUGIN}"

echo "Create makefiles"

GENERATOR="Unix Makefiles"

CMAKE_CMD=$'/usr/local/bin/cmake'

CMAKE_CMD+=$' -D CMAKE_BUILD_TYPE='$BUILD_TYPE

CMAKE_CMD+=$' -DINCLUDE_PLUGINS='${TEST_PLUGINS}' -DTEST_PLUGINS='${TEST_PLUGINS}

CMAKE_CMD+=${SUPRESS_PLUGINS}

CMAKE_CMD+=$' -DMAKE_DOCS='${BUILD_DOCS}

CMAKE_CMD+=$' -DUSE_CPPUNIT='${USE_CPPUNIT}

CMAKE_CMD+=$' -DWSSQL_SERVICE='${MAKE_WSSQL}

CMAKE_CMD+=$' -DUSE_LIBMEMCACHED='${USE_LIBMEMCACHED}

CMAKE_CMD+=$' -DECLWATCH_BUILD_STRATEGY='${ECLWATCH_BUILD_STRATEGY}

CMAKE_CMD+=$' -DINCLUDE_SPARK='${ENABLE_SPARK}' -DSUPPRESS_SPARK='${SUPPRESS_SPARK}' -DSPARK='${ENABLE_SPARK}

CMAKE_CMD+=$' '${PYTHON_PLUGIN}

CMAKE_CMD+=$' -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DUSE_LIBXSLT=ON -DXALAN_LIBRARIES= '

if [[ ( "${SYSTEM_ID}" =~ "CentOS_release_6" ) ]]
then
    # For CentOS 6
    CMAKE_CMD+=$' -DCENTOS_6_BOOST=ON'
else
    CMAKE_CMD+=$' -DCENTOS_6_BOOST=OFF'
fi

CMAKE_CMD+=$' -DCMAKE_EXE_LINKER_FLAGS=-lrt'

CMAKE_CMD+=$' ../'$SOURCE_DIR

echo "${CMAKE_CMD}"

eval ${CMAKE_CMD}

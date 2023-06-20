## Commented Code Removals

Lines 62-64:
```
#/usr/local/bin/cmake ../$SOURCE_DIR -DTEST_PLUGINS=1 -DINCLUDE_PLUGINS=1 -DUSE_LIBMEMCACHED=0 -DWSSQL_SERVICE=0 -DSUPPRESS_PY3EMBED=ON -DINCLUDE_PY3EMBED=OFF  -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DMAKE_DOCS=$BUILD_DOCS -DUSE_CPPUNIT=1 -DINCLUDE_SPARK=0 -DSUPPRESS_SPARK=1 -DSPARK=0 -DGENERATE_COVERAGE_INFO=0 -DUSE_LIBXSLT=ON -DXALAN_LIBRARIES= -DMYSQL_LIBRARIES=/usr/lib64/mysql/libmysqlclient.so  -DMYSQL_INCLUDE_DIR=/usr/include/mysql -DMAKE_MYSQLEMBED=1 

#/usr/local/bin/cmake ../$SOURCE_DIR -DTEST_PLUGINS=1 -DINCLUDE_PLUGINS=1 -DSUPPRESS_PY3EMBED=ON -DINCLUDE_PY3EMBED=OFF -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DMAKE_DOCS=$BUILD_DOCS -DUSE_CPPUNIT=1 -DINCLUDE_SPARK=0 -DSUPPRESS_SPARK=1 -DSPARK=0 -DGENERATE_COVERAGE_INFO=0 -DUSE_LIBXSLT=ON -DXALAN_LIBRARIES= -DMYSQL_LIBRARIES=/usr/lib64/mysql/libmysqlclient.so  -DMYSQL_INCLUDE_DIR=/usr/include/mysql -DMAKE_MYSQLEMBED=1
```

Line 68:
```
#GENERATOR="Eclipse CDT4 - Unix Makefiles"
```

Line 72:
```
#CMAKE_CMD+=$' -G "'${GENERATOR}$'"'
```

Line 105:
```
#CMAKE_CMD+=$' -D CMAKE_ECLIPSE_MAKE_ARGUMENTS=-30 ../HPCC-Platform ln -s ../HPCC-Platform'
```

Lines 111-112:
```
#res=$( eval ${CMAKE_CMD} 2>&1 )
# echo "Res: ${res[*]}"
```
                

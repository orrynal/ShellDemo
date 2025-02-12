#!/bin/bash

cd ~

: <<COMMENT
#stop hadr and db on A node
su - db2inst1 -c <<EOF
db2 DEACTIVATE DATABASE SAMPLE
db2 STOP HADR ON DATABASE SAMPLE
db2stop
EOF
COMMENT


#stop hadr and db on B node
stopStandby() {
	rsh wls2 'su - db2inst1 -c "db2 DEACTIVATE DATABASE SAMPLE"'
	rsh wls2 'su - db2inst1 -c "db2 STOP HADR ON DATABASE SAMPLE"'
	rsh wls2 'su - db2inst1 -c "db2stop"'

}


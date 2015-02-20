#!/bin/bash -xe
source /home/centos/rpmbuilder/delorean/globals.sh

echo "Start RPM Build"
echo "=================================="
echo "Jenkins Staging Dir:  $JENKINS_STAGING_DIR"
echo "Delorean Staging Dir: $DELOREAN_STAGING_DIR"
echo "RPM Builder Root:     $RPMBUILDER_ROOT"
echo "Delorean Root:        $DELOREAN_ROOT"
echo "RDO Root:             $RDO_ROOT"
echo "Delorean Env:         $DELOREAN_ENV"
echo "Project-name:         $PROJECT"
echo "=================================="


if [[ ! -d $DELOREAN_ROOT ]]; then
    echo "$DELOREAN_ROOT not present. Exit"
    exit 1
fi

if [[ -d $JENKINS_STAGING_DIR ]]; then
    echo "$JENKINS_STAGING_DIR present"
else
    mkdir -p $JENKINS_STAGING_DIR
fi

cd $DELOREAN_ROOT
######################################
# We delete the specific project entry
###################################### 
sql_del_cmd="delete from commits where project_name=\"$PROJECT\""
sqlite3 commits.sqlite "$sql_del_cmd"
#sqlite3 commits.sqlite 'delete from commits where project_name="openstack-glance"'

#######################################
# Source the python virtual environment
#######################################
source $DELOREAN_ENV

export PYTHONPATH=$PYTHONPATH:$RDO_ROOT
echo $PROJECT
delorean --config-file projects.ini --info-file cisco.yml --package-name $PROJECT 


OPENSTACK_RPM_FILE="$PROJECT*.rpm"
rpms=$(find $DELOREAN_STAGING_DIR -name $OPENSTACK_RPM_FILE)
for rpm in $rpms; do
     cp $rpm $JENKINS_STAGING_DIR/. 
done


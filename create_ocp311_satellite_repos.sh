#!/bin/bash

# Replace your tokenID and secret with the actual values below:

# From: https://access.redhat.com/terms-based-registry/#/token/
PATH=$PATH:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin

TOKENID="YourTokenID"
SECRET="YourTokenSecret"


RESPONSE=$(curl  -u $TOKENID:$SECRET --silent  --write-out %{http_code} --output /dev/null "https://sso.redhat.com/auth/realms/rhcc/protocol/redhat-docker-v2/auth?service=docker-registry&client_id=curl&scope=repository:rhel:pull")

if [ "$RESPONSE" == "200" ];

then

        curl  -s https://registry.redhat.io/v1/search?q=openshift3%20or%20rhel7/etcd%22  | python -mjson.tool | grep ".name.:" | cut -d: -f2 | sed -e "s/ "//g"" -e "s/,"//g"" | sed -e "s/\"//g" | egrep -v 'rhel7/etcd3|rhel7/flannel' > openshift3_images.txt

cat <<EOL >> openshift3_images.txt
jboss-amq-6/amq63-openshift
jboss-datagrid-7/datagrid71-openshift
jboss-datagrid-7/datagrid71-client-openshift
jboss-datavirt-6/datavirt63-openshift
jboss-datavirt-6/datavirt63-driver-openshift
jboss-decisionserver-6/decisionserver64-openshift
jboss-processserver-6/processserver64-openshift
jboss-eap-6/eap64-openshift
jboss-eap-7/eap71-openshift
jboss-webserver-3/webserver31-tomcat7-openshift
jboss-webserver-3/webserver31-tomcat8-openshift
rhscl/mongodb-32-rhel7
rhscl/mysql-57-rhel7
rhscl/perl-524-rhel7
rhscl/php-56-rhel7
rhscl/postgresql-95-rhel7
rhscl/python-35-rhel7
redhat-sso-7/sso70-openshift
rhscl/ruby-24-rhel7
redhat-openjdk-18/openjdk18-openshift
redhat-sso-7/sso71-openshift
rhscl/mariadb-101-rhel7
cloudforms46/cfme-openshift-postgresql
cloudforms46/cfme-openshift-memcached
cloudforms46/cfme-openshift-app-ui
cloudforms46/cfme-openshift-app
cloudforms46/cfme-openshift-embedded-ansible
cloudforms46/cfme-openshift-httpd
cloudforms46/cfme-httpd-configmap-generator
rhgs3/rhgs-server-rhel7
rhgs3/rhgs-volmanager-rhel7
rhgs3/rhgs-gluster-block-prov-rhel7
rhgs3/rhgs-s3-server-rhel7
EOL
	cd /root
        hammer product create --name "ocp311" --organization "momolab.io"

        for image in `cat openshift3_images.txt`;
        do
                hammer repository create \
		--name $image \
		--content-type docker \
		--url http://registry.redhat.io/ \
		--docker-upstream-name $image \
		--product ocp311 \
		--organization momolab.io \
		--upstream-username $TOKENID \
		--upstream-password $SECRET

        hammer product synchronize --name "ocp311" --organization "momolab.io"

        done

        #hammer product synchronize --name "ocp311" --organization "momolab.io"
else
        echo "TOKENID/SECRET might be invalid, please check and try again"
fi

 

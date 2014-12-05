# Install jenkins
mkdir -p /opt/jenkins/data
curl -sSL https://get.docker.io/ubuntu/ | sh
docker run --name jenkins -d -p 80:8080 -v /opt/jenkins/data:/jenkins -t aespinosa/jenkins
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
docker-enter jenkins

########################################
# BEGIN : init jenkins
########################################
# setup deploy key
MAVEN_MASTER_PASSWD=
MAVEN_SERVER_ID=
MAVEN_SERVER_USERNAME=
MAVEN_SERVER_PASSWORD=
docker_repo=

apt-get update
apt-get install python-software-properties software-properties-common openssh-client git unzip ant -y
add-apt-repository -y "deb http://ppa.launchpad.net/natecarlson/maven3/ubuntu precise main"
add-apt-repository -y ppa:webupd8team/java
apt-get update

# TODO(edison): Should install java in non-interactive mode
apt-get install -y --force-yes --quiet maven3 oracle-java8-installer
ln -s /usr/share/maven3/bin/mvn /usr/local/bin/mvn

ssh-keygen -q -t rsa -b 2048 -N "" -C "jenkins.deploy.key" -f ~/.ssh/jenkins.deploy.key
cat ~/.ssh/jenkins.deploy.key.pub
# access http://gitlab.wellsite-ds.lo and copy the content as a deploy key

# configure maven server
mkdir ~/.m2
# generate master password for maven
cat <<EOF > ~/.m2/settings-security.xml
<settingsSecurity>
    <master>$(mvn --encrypt-master-password ${MAVEN_MASTER_PASSWD})</master>
</settingsSecurity>
EOF

# configure server
cat <<EOF > ~/.m2/settings.xml
<settings>
    <servers>
        <server>
            <id>${MAVEN_SERVER_ID}</id>
            <username>${MAVEN_SERVER_USERNAME}</username>
            <password>$(mvn --encrypt-password ${MAVEN_SERVER_PASSWORD})</password>
        </server>
    </servers>
</settings>
EOF

# flex sdk
#mkdir /opt/flex-sdks/flex-sdk-4.5.1.21328A
#wget http://fpdownload.adobe.com/pub/flex/sdk/builds/flex4.5/flex_sdk_4.5.1.21328A.zip -O /opt/flex-sdks/flex-sdk-4.5.1.21328A/flex_sdk_4.5.1.21328A.zip
#cd /opt/flex-sdks/flex-sdk-4.5.1.21328A && unzip flex_sdk_4.5.1.21328A.zip && cd -

# exit docker container
exit
########################################
# END
########################################

# commit docker container
docker commit jenkins ${docker_repo}/jenkins



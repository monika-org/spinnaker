******************
NOTE: Change the ubuntu-user name and spinnaker version that you want to install.
*****************

SPINNAKER_VERSION=1.16.5
curl -Os https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh --user xeadmin
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker xeadmin
sudo docker run -p 127.0.0.1:9090:9000 -d --name minio1 -v /mnt/data:/data -v /mnt/config:/root/.minio minio/minio:RELEASE.2018-07-31T02-11-47Z server /data

sudo apt-get -y install jq

MINIO_SECRET_KEY=`echo $(sudo docker exec minio1 cat /root/.minio/config.json) |jq -r '.credential.secretKey'`
MINIO_ACCESS_KEY=`echo $(sudo docker exec minio1 cat /root/.minio/config.json) |jq -r '.credential.accessKey'`
echo $MINIO_SECRET_KEY | hal config storage s3 edit --endpoint http://127.0.0.1:9090 \
    --access-key-id $MINIO_ACCESS_KEY \
    --secret-access-key

hal config storage edit --type s3

# env flag that need to be set:


set -e

if [ -z "${SPINNAKER_VERSION}" ] ; then
  echo "SPINNAKER_VERSION not set"
  exit
fi

sudo hal config version edit --version $SPINNAKER_VERSION
sudo hal deploy apply
sudo echo "host: 0.0.0.0" |sudo tee \
    /home/xeadmin/.hal/default/service-settings/gate.yml \
    /home/xeadmin/.hal/default/service-settings/deck.yml
sudo hal deploy apply
sudo systemctl daemon-reload
sudo hal deploy connect
printf " -------------------------------------------------------------- \n|     Connect here to spinnaker: http://192.168.33.10:9000/    |\n --------------------------------------------------------------"
sudo systemctl enable redis-server.service
sudo systemctl start redis-server.service

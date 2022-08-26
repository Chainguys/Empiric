ssh -i LightsailDefaultKey-us-east-2.pem ubuntu@18.119.165.238 -t "mkdir all"
scp -i LightsailDefaultKey-us-east-2.pem -r ../sample-publisher/all/ ubuntu@18.119.165.238:
scp -i LightsailDefaultKey-us-east-2.pem -r initialize_lightsail.sh ubuntu@18.119.165.238:
ssh -i LightsailDefaultKey-us-east-2.pem ubuntu@18.119.165.238 -t "source initialize_lightsail.sh"

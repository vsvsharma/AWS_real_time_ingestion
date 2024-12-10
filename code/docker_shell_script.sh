aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 209757962519.dkr.ecr.ap-south-1.amazonaws.com
docker build -t extraction-ecr-repo /home/varuns/personal/AWS_real_time_ingestion/code/lambda_user_to_kinesis/
docker tag extraction-ecr-repo:latest 209757962519.dkr.ecr.ap-south-1.amazonaws.com/extraction-ecr-repo
docker push 209757962519.dkr.ecr.ap-south-1.amazonaws.com/extraction-ecr-repo:latest
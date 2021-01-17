set -x -e

DEPLOY_FUNCTION_NAME="weather-api-bah"
DEPLOY_ALIAS_NAME="weather-api-bahAlias"
DEPLOY_APPSPEC_FILE="appspec.yaml"
DEPLOY_BUCKET_NAME="artifact-bucket-bah/bah-codebuild-lambda/CodeDeploy"

# DEVELOPMENT ALIAS VERSION
aws lambda get-alias \
  --function-name $DEPLOY_FUNCTION_NAME \
  --name $DEPLOY_ALIAS_NAME \
  > output.json
DEVELOPMENT_ALIAS_VERSION=$(cat output.json | jq -r '.FunctionVersion')

# UPDATE FUNCTION CODE
aws lambda update-function-code \
  --function-name $DEPLOY_FUNCTION_NAME \
  --zip-file fileb://weather-api-bah.zip \
  --publish \
  > output.json
LATEST_VERSION=$(cat output.json | jq -r '.Version')

# NO DEPLOYMENT NEEDED EXIT
if [[ $DEVELOPMENT_ALIAS_VERSION -ge $LATEST_VERSION ]]; then
  exit 0
fi

# CREATE APPSPEC FILE IN S3 BUCKET
cat > $DEPLOY_APPSPEC_FILE <<- EOM
version: 0.0
Resources:
  - myLambdaFunction:
      Type: AWS::Lambda::Function
      Properties:
        Name: "$DEPLOY_FUNCTION_NAME"
        Alias: "$DEPLOY_ALIAS_NAME"
        CurrentVersion: "$DEVELOPMENT_ALIAS_VERSION"
        TargetVersion: "$LATEST_VERSION"
EOM
aws s3 cp \
    $DEPLOY_APPSPEC_FILE \
    s3://$DEPLOY_BUCKET_NAME/$DEPLOY_APPSPEC_FILE
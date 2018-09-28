set -x
export DIST_OUTPUT_BUCKET=nexstra-pge
export VERSION=v1.0.3
export REGION=us-east-2
delete=false
./build-s3-dist.sh $DIST_OUTPUT_BUCKET $VERSION
aws s3 cp ./dist/ s3://${DIST_OUTPUT_BUCKET}-${REGION}/media-analysis-solution/$VERSION/ --recursive --acl bucket-owner-full-control --region "${REGION}"
B=$DIST_OUTPUT_BUCKET-${REGION} 
aws s3api list-objects --bucket "$B" --prefix "media-analysis-solution/${VERSION}/"  --query 'Contents[].Key' --output text | tr '\t' '\n' | 
  xargs -n1  -I{} aws s3api put-object-acl --acl public-read --bucket "$B" --key  "{}"

./update-function.sh

export STACK_NAME=MediaAnalytics
export TEMPLATE="https://${DIST_OUTPUT_BUCKET}-${REGION}.s3-${REGION}.amazonaws.com/media-analysis-solution/$VERSION/media-analysis-deploy.template"
export EMAIL="dlee@nexstra.com"
exists=$(aws cloudformation list-stacks  --region "$REGION" --stack-status-filter UPDATE_COMPLETE CREATE_COMPLETE | jq -r '..|.StackName?' | grep ^MediaAnalytics$ )

#DRY=--dry-run
if $delete ; then 
   aws cloudformation delete-stack --stack-name "$STACK_NAME" -region "$REGION"
   aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" -region "$REGION"

fi 
  
if [ -n "$exists" ] ; then 
	envsubst < ./create-stack.json > /tmp/create-stack.$$
	aws cloudformation update-stack --stack-name "$STACK_NAME"  --cli-input-json "$(</tmp/create-stack.$$)" --region "$REGION"
	aws cloudformation wait stack-update-complete --stack-name "$STACK_NAME"  --region "$REGION"
else
	envsubst < ./create-stack.json > /tmp/update-stack.$$
	aws cloudformation create-stack --stack-name "$STACK_NAME"  --cli-input-json "$(</tmp/update-stack.$$)"  --region "$REGION"
	aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"  --region "$REGION"
fi

#!/bin/bash
# var fname 
function fname() { 
   local f=$(awscmd list-functions --list | grep "$2"-)
   if [ -z "$f" ] ; then 
     echo "Function not found: $2" 
     exit 1
  fi
  declare -g $1=$f
}


fname fapi MediaAnalytics-MediaAnaly-MediaAnalysisApiFunction
fname ff MediaAnalytics-MediaAnalysisFunction
fname fhelp MediaAnalytics-MediaAnalysisHelperFunction



aws lambda update-function-code --function-name $ff --zip-file fileb://.//dist/media-analysis-function.zip
aws lambda update-function-code --function-name $fapi --zip-file fileb://.//dist/media-analysis-api.zip
aws lambda update-function-code --function-name $fhelp --zip-file fileb://.//dist/media-analysis-helper.zip

#aws s3 cp dist/web_site/ s3://mediaanalytics-mediaanalysiswebsitebucket-e94ncajz3ou9/ --recursive
#MediaAnalytics-MediaAnaly-MediaAnalysisApiFunction-1TFL2OFDGU4UD
#MediaAnalytics-MediaAnalysisFunction-1985EIIQSF3S5
#MediaAnalytics-MediaAnalysisHelperFunction-1WL7I2SHJU4KP

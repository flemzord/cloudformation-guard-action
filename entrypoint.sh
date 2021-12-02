#!/bin/sh

# validate inputs
if [ -z "${INPUT_CFN_DIRECTORY}" ] ; then
  echo "Missing 'cfn_directory' parameter."
  echo "Set this to the directory where your CloudFormation Templates are located."
  exit 1
fi

# check if using default or provided rules
echo "INPUT_RULESET_FILE set to $INPUT_RULESET_FILE"

# find templates with 'Resources'
POSSIBLE_TEMPLATES=$(grep --with-filename --recursive 'Resources' ${INPUT_CFN_DIRECTORY}/* | cut -d':' -f1 | sort -u)

for f in $POSSIBLE_TEMPLATES; do
    echo "Checking for ruleset matching template file: ${f}"
    rules=${f%.*}.ruleset
    if [ -e $rules ]; then
        echo "                                      Found: $rules"
        cg_cmd="cfn-guard validate --rules $rules  --template ${PWD}/${f}"
        echo "Running command:"
        echo "$ $cg_cmd"
        $cg_cmd
        if [ $? -ne 0 ]; then
            echo "CFN GUARD FAIL!"
            exit 1
        fi
    else
        echo "No matching: $rules"
    fi
done

echo "CloudFormation Guard Scan Complete"

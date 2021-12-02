#!/bin/sh

# validate inputs
if [ -z "${INPUT_CFN_DIRECTORY}" ] ; then
  echo "Missing 'cfn_directory' parameter."
  echo "Set this to the directory where your CloudFormation Templates are located."
  exit 1
fi

# find templates with 'Resources'
POSSIBLE_TEMPLATES=$(grep --with-filename --recursive 'Resources' ${INPUT_CFN_DIRECTORY}/* | cut -d':' -f1 | sort -u)

for f in $POSSIBLE_TEMPLATES; do
    if grep -q ".yml" <<< "${f}"; then
      echo "Checking for ruleset matching template file: ${f}"
      rules=${f%.*}.ruleset
      echo "                                      Found: $rules"
      cg_cmd="cfn-guard validate -d ${f} -r $rules"
      echo "Running command:"
      echo "$ $cg_cmd"
      $cg_cmd
      if [ $? -ne 0 ]; then
          echo "CFN GUARD FAIL!"
          exit 1
      fi
    fi
done

echo "CloudFormation Guard Scan Complete"

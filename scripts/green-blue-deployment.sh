# Default deployment colors to blue and green.
ASC_DEPLOYMENT_COLOR_1=${ASC_DEPLOYMENT_COLOR_1:-blue}
ASC_DEPLOYMENT_COLOR_2=${ASC_DEPLOYMENT_COLOR_2:-default}
ASC_APP_NAME=api-service
ASC_RESOURCE_GROUP_NAME=rg-spring-cloud-demo-hkb
ASC_SERVICE_NAME=spring-cloud-demo-hkb

# Installs the spring-cloud extension if not available.
function install_dependencies () {
 az extension add -n spring-cloud
}
 
# Gets the name of the deployment active in production.
function get_active_deployment_name() {
az spring-cloud app deployment list \
    --app $ASC_APP_NAME \
    --resource-group $ASC_RESOURCE_GROUP_NAME \
    --service $ASC_SERVICE_NAME \
    --query "[?properties.active].name | [0]"
}

# Alternates between the two defined deployment colors.
function get_new_deployment_name() {
  if [ "$1" == "\"$ASC_DEPLOYMENT_COLOR_1\"" ]; then
    echo $ASC_DEPLOYMENT_COLOR_2
  else
    echo $ASC_DEPLOYMENT_COLOR_1
  fi
}

# Deletes a deployment.
function delete_deployment() {
  az spring-cloud app deployment delete \
    --name $1 \
    --app $ASC_APP_NAME \
    --resource-group $ASC_RESOURCE_GROUP_NAME \
    --service $ASC_SERVICE_NAME
}

function get_count_deploymentslots() {
  az spring-cloud app deployment list \
    --app $ASC_APP_NAME \
    --resource-group $ASC_RESOURCE_GROUP_NAME \
    --service $ASC_SERVICE_NAME \
    --query 'length(@)'
}

# Creates a deployment.
function create_deployment() {  
# Only default deployment exists, so create new deployment
  if [  $1 == $ASC_DEPLOYMENT_COLOR_1 ] && [ $2 == 1 ]; then
   delete_deployment $1  # USE THIS ONLY IF DEFAULT DEPLOYMNET HUNG
    az spring-cloud app deployment create \
      --name $1 \
      --app $ASC_APP_NAME \
      --resource-group $ASC_RESOURCE_GROUP_NAME \
      --service $ASC_SERVICE_NAME \
      --jar-path $ASC_JAR_PATH \
     --runtime-version Java_11  # USE THIS ONLY IF VERSION IS NOT 8
  else # If target instance is not in up and running state, delete and re-create it
    INSTANCE_STATUS=$(get_deployment_instance_status)
    echo "Instance health status: ${INSTANCE_STATUS}"
    
   if [ "$INSTANCE_STATUS" == \""Succeeded\"" ]; then
   az spring-cloud app deploy \
    -n $ASC_APP_NAME \
    -g $ASC_RESOURCE_GROUP_NAME \
    -s $ASC_SERVICE_NAME \
    -d $1 \
    --jar-path $ASC_JAR_PATH
    --runtime-version Java_11 # USE  ONLY IF VERISON IS NOT 8
    else
    echo 'instance status down, deleting and re-creating instance' 
    delete_deployment $target_deployment_name
    
    az spring-cloud app deployment create \
      --name $target_deployment_name \
      --app $ASC_APP_NAME \
      --resource-group $ASC_RESOURCE_GROUP_NAME \
      --service $ASC_SERVICE_NAME \
      --jar-path $ASC_JAR_PATH
    --runtime-version Java_11 # USE  ONLY IF VERISON IS NOT 8
    fi
  fi
}

# Get instance status
function get_deployment_instance_status()
{
az spring-cloud app deployment list \
  --app $ASC_APP_NAME \
  --resource-group $ASC_RESOURCE_GROUP_NAME \
  --service $ASC_SERVICE_NAME \
  --query "[?name=='${target_deployment_name}'].properties.provisioningState | [0]"
}

# Set a deployment.
function set_deployment() {
  az spring-cloud app set-deployment \
    --deployment $1 \
    --name $ASC_APP_NAME \
    --resource-group $ASC_RESOURCE_GROUP_NAME \
    --service $ASC_SERVICE_NAME
}

#Installing Dependencies
 install_dependencies
 
#Getting the Production/Active Deployment Name
active_deployment_name=$(get_active_deployment_name)
echo "Active Deployment:  ${active_deployment_name}"

#setting the Staging/InActive Deployment Name
target_deployment_name=$(get_new_deployment_name $active_deployment_name)
echo "Target Deployment:  ${target_deployment_name}"

#Getting count of Deploymentslots
count_deploymentslots=$(get_count_deploymentslots)
echo "Deployment Count: ${count_deploymentslots}"

#Creating the Staging Deployment 
create_deployment $target_deployment_name $count_deploymentslots

# TODO: Add health check step and Post Approval to SWAP the slot
# set_deployment $target_deployment_name

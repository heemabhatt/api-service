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

  if [  $1 == $ASC_DEPLOYMENT_COLOR_1 ] && [ $2 == 1 ]; then
    az spring-cloud app deployment create \
      --name $1 \
      --app $ASC_APP_NAME \
      --resource-group $ASC_RESOURCE_GROUP_NAME \
      --service $ASC_SERVICE_NAME \
      --jar-path $ASC_JAR_PATH \
      --runtime-version Java_11
  else
    INSTANCE_STATUS=$(get_deployment_instance_status)
    echo "Instance health status: ${INSTANCE_STATUS}"
    
   if [ "$INSTANCE_STATUS" == \""Succeeded\"" ]; then
   az spring-cloud app deploy \
    -n $ASC_APP_NAME \
    -g $ASC_RESOURCE_GROUP_NAME \
    -s $ASC_SERVICE_NAME \
    -d $1 \
    --jar-path $ASC_JAR_PATH
    else
    echo 'instance status down' 
    delete_deployment $target_deployment_name
    
    az spring-cloud app deployment create \
      --name $target_deployment_name \
      --app $ASC_APP_NAME \
      --resource-group $ASC_RESOURCE_GROUP_NAME \
      --service $ASC_SERVICE_NAME \
      --jar-path $ASC_JAR_PATH
      --runtime-version Java_11
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
 
echo "color1: ${ASC_DEPLOYMENT_COLOR_1}"
echo "color2: ${ASC_DEPLOYMENT_COLOR_2}"

 #Getting the Production/Active Deployment Name
active_deployment_name=$(get_active_deployment_name)
echo "Active Deployment:  ${active_deployment_name}"


#setting the Staging/InActive Deployment Name
target_deployment_name=$(get_new_deployment_name $active_deployment_name)
echo "target:  ${target_deployment_name}"

# #delete_deployment $target_deployment_name
echo "DEPLOYMNET STATUS: $(get_deployment_instance_status) "

#Getting count of Deploymentslots
count_deploymentslots=$(get_count_deploymentslots)
echo "count: ${count_deploymentslots}"
echo "JAR PATH:  ${ASC_JAR_PATH}"
# #Creating the Staging Deployment 
 create_deployment $target_deployment_name $count_deploymentslots

# # TODO: Add health check step and Post Approval to SWAP the slot
# set_deployment $target_deployment_name

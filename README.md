# Tailscale Solutions Engineer Takehome Assignment
The goal of this project is to deploy a [subnet router](https://tailscale.com/kb/1019/subnets) and a device with [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh) using infrastructure-as-code, connect them to an existing tailnet, and then test the connection from a device in a different network on the same tailnet.

The deployment code and steps in this project are intended for Google Cloud Platform (GCP). The GCP infrastructure will be deployed and managed using Terraform.

## Prerequisites
### Tailscale account and tailnet setup with first device
Sign up for Tailscale and create a tailnet with your first device (local computer) through following the instructions [here](https://tailscale.com/kb/1017/install). View your device under the Machines tab on the Admin console. We will be using this device to test the connection to both the subnet router and device with Tailscale SSH that we will setup in the steps below.

To prepare for adding devices automatically, we are going to generate an authentication key and add our user as an Auto approver on your [Tailscale admin console](https://login.tailscale.com/admin).

#### Generate authentication key
Under the Machines tab in your admin console, select "Add a device" with the *Linux server option*. Skip to "Step 2. Set up authentication key" and enable the "Reusable" option. Select "Generate install script", copy the value after `--auth-key=` and store in a safe place to be used for `vm_tailscale_api_auth`. 

#### Set up your user as an auto approver
Under the Access Controls tab in your admin console, navigate to Auto approvers. Select "Add route" and create a route for the subnet `10.2.0.0/16` to be auto-approved for your user's email address. This is the subnet range we will use for GCP and this rule will enable your subnet router to be added automatically later without requiring you to manually approve it in the admin console.

### GCP environment setup
If you are setting up a GCP environment from scratch, we are going to create a new project. Record your `project id` to be used later.

#### Permission Setup
Enable a few services/permissions through running the following commands on the Cloud Shell terminal (accessible through the top-right menu of your new GCP project).
```
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable config.googleapis.com 
gcloud services enable cloudresourcemanager.googleapis.com
```
Add your user into the compute admin IAM role by replacing the <project_id> placeholder value with your `project id` and the <email_address> with your own in the command below before running it.
```
gcloud projects add-iam-policy-binding <project_id> --member="user:<email_address>" --role=roles/compute.instanceAdmin.v1
```
#### Repository Setup
On the Cloud Shell terminal, open the Editor and select "import an existing repository" to connect your editor with github. After your github is connected, select the `tailscale-se-takehome` project. In the Editor, open the `dev.tfvars` file and replace the `vm_project_id` variable with your own. 

## Deployment
On the GCP Cloud Shell terminal, navigate into the terraform folder and initialize terraform.
```
cd tailscale-se-takehome/terraform
terraform init
```
Plan the terraform build. Provide the `vm_tailscale_api_auth` value collected above when prompted.
```
terraform plan -var-file="$HOME/tailscale-se-takehome/terraform/dev.tfvars"
```
Apply the terraform build. Provide the `vm_tailscale_api_auth` value collected above when prompted.
```
terraform apply -var-file="$HOME/tailscale-se-takehome/terraform/dev.tfvars"
```
Note: It may take a couple of minutes for the devices to show up as connected to the tailnet in the admin console to allow for the tailscale download, installation, and configuration.

## Verification
### Subnet Router
In the Machines tab of your Tailscale admin console, verify that the device configured as a subnet router shows up in the list as `tailscale-subnet-router` to confirm it is connected to the tailnet. Verify that the device has the subnet tag and that there is no info icon indicating that approval is required for the route.

To test the connection, open up a terminal on your first device (local computer) you added to the tailnet during the initial setup and ping the subnet router. Confirm packet flow.
```
ping tailscale-subnet-router
```

### Tailscale SSH
In the Machines tab of your Tailscale admin console, verify that the device configured with Tailscale SS shows up in the list as `tailscale-ssh` to confirm it is connected to the tailnet. Verify that the device has the ssh tag.

To test the connection, open up a terminal on your first device (local computer) you added to the tailnet during the initial setup and ssh to the `tailscale-ssh` host. Confirm successful connection.
```
ssh root@tailscale-ssh
```
Note: There is a default route in the Tailscale SSH section of the Access Controls that allows this connection. Finer control will require addditional rules to be added here.

## Future Considerations
#### Workload Identity Federation
In the deployment code, I used a sensitive variable type within Terraform that was provided at runtime to inject the authentication key. Though the static value is not exposed in this implementation, using static credentials is not ideal for sustainability and security reasons; they can be hard to keep track of and easy to steal. A better option would be to use Workload Identity Federation which would allow workloads to prove their identity to Tailscale using time-limited tokens issued by a trusted identity provider.

#### Peer Relays
Though not required for the use case of this project, it would be useful to enable peer relays to provide the capacity to handle higher bandwidth loads in the future.
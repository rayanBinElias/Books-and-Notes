DevOps Study Guide To Do List

Config Connector overview 
	- open source kb8s add on that lets you manage Google cloud resources through kb8s 
	- env can use 
		- RBAC(Role based access control) for access control 
		- events for visibility 
		- single source config 
		- desired stat mngmt 
		- eventual consistency for loosely coupling depency

    How it works?
    	- provide collection of
    		- custom Resource Definitions(CRDs)
    			- allow kb8s to create and manage cloud roesources
    		- controllers

    	- config connec deploy pods
    		- to nodes that have RBAC permission
    			- create/delete/get and list CRDs
    				- create and reconcie kb8s resources

    Customize behavior
    	- manage existing GC resources
    	- use kb8s secrets
    		- sensitive data such as passwords

GitOps-style continuous delivery with Cloud Build 
	- https://cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build - "environment as a code"A - describing your deployments declaratively using files (for example, Kubernetes manifests) stored in a Git repository.

  - app repository: contains the source code of the application itself
  - env repository: contains the manifests for the Kubernetes Deploymen

Config Sync Overview 
	- a GitOps service offered as a part of Google Kubernetes Engine (GKE) Enterprise edition - lets cluster operators and platform administrators deploy configurations from a source of truth.

    Config Sync benefits
    	"GitOps is considered a universal best practice for organizations managing Kubernetes configuration at scale"

    	- Integrated with Google Kubernetes Engine (GKE) Enterprise edition
    	- Built-in observability
    	- Multi-cloud and hybrid support

    Understanding Config Sync
    	- teams might sync their clusters to a single root repository (managed by an admin) and multiple namespace repositories (managed by application operators):

    - Configuring clusters
    - Configuring namespaces

Best practices for building containers
	1. Package a single app per container
	2. Properly handle PID 1, signal handling, and zombie processes
		- first process launched when starting a Linux kernel has the PID 1
			- init processs
				- starting and shutting down the system
	
		Problem
			1. How the Linux kernel handles signals

			2. How classic init systems handle orphaned processes

			3. Use a specialized init system

		Solution: 
			- Run as PID 1 and register signal handlers
				- CMD [ "nginx", "-g", "daemon off;" ]
			- Enable process namespace sharing in Kubernetes
			- Use a specialized init system

	3. Optimize for the Docker build cache
		-  Docker build cache can accelerate the building of container images
			RUN apt-get update && \
					apt-get install -y nginx
	4. Remove unnecessary tools
	5. Build the smallest image possible
		- Use the smallest base image possible
		- Reduce the amount of clutter in your image
		- Try to create images with common layers
	6. Scan images for vulnerabilities
		- Arificat Analysis
			- Automatic vulnerability scanning
			- On-Demand Scanning API

		Steps
			- Store your images in Artifact Registry and enable vulnerability scanning.
			- Configure a job that regularly fetches new vulnerabilities from Artifact Registry and triggers a rebuild of the images if needed.
			- When the new images are built, have your continuous deployment system deploy them to a staging environment.
			- Manually check the staging environment for problems.
			- If no problems are found, manually trigger the deployment to production.
	7. Properly tag your images
		- google/cloud-sdk:419.0.0
			- Tagging using semantic versioning
				- X is the major version, incremented only for incompatible API changes.
				- Y is the minor version, incremented for new features.
				- Z is the patch version, incremented for bug fixes.
		- Tagging using the Git commit hash
	8. Carefully consider whether to use a public image
		- constraints that might render the use of public images impossible:
			- You want to control exactly what is inside your images.
			- You dont want to depend on an external repository.
			- You want to strictly control vulnerabilities in your production environment.
			- You want the same base operating system in every image.

		- managing such a system at scale:
			- An automated way to build images, in a reliable way, even for images that are built rarely. Build triggers in Cloud Build are a good way to achieve that.
			- A standardized base image. Google provides some base images that you can use.
			- An automated way to propagate updates to the base image to "child" images.
			- A way to address vulnerabilities in your images. For more information, see Scan images for vulnerabilities.
			- A way to enforce your internal standards on images created by the different teams in your organization.

		- Several tools are available to help you enforce policies
			- container-diff can analyze the content of images and even compare two images between them.
			- container-structure-test can test whether the content of an image complies with a set of rules that you define.
			- Grafeas is an artifact metadata API, where you store metadata about your images to later check whether those images comply with your policies.
			- Kubernetes has admission controllers that you can use to check a number of prerequisites before deploying a workload in Kubernetes.

	9. A note about licenses
		- Before you include third-party libraries and packages 
			- ensure that the respective licenses allow you to do so

Best practices for operating containers
	1. Use the native logging mechanisms of containers
		- fluent bit/fluentd agent
			- cloud logging
		- JSON logs
			- time-series/indexed doc -> JSON foprmat
		- Log aggregator sidecar pattern
			- GKE access point for log
	2. Ensure that your containers are stateless and immutable
		Stateless 
			- means that any state (persistent data of any kind) is stored outside of a container.
				- GCS
				- redis/memcached/memorystore
				- GKE -> persisitent disk
			
		Immutable 
			- means that a container won't be modified during its life: 
				- no updates
				- no patches
				- no configuration changes.

			- If you must update the application code or apply a patch:
				- you build a new image and redeploy it
			
			- makes deployments safer and more repeatable.

			-  roll back, you simply redeploy the old image

	3. Avoid privileged containers
		-  A privileged container 
			- is a container that has access to all the devices of the host machine, bypassing almost all the security features of containers.
	
		-  alternatives:
			https://cloud.google.com/architecture/best-practices-for-operating-containers?hl=en#avoid_privileged_containers
			- securityCOntext option/ --cap-add flag
				- givespecific capabilities to the container 
			- sidecar container/init container
				- modify the host settings in order to run
			- dedicated annotation
				- modify sysctls in Kubernetes,

			Policy controller
				- can forbid privileged containers in Kubernetes
					- can't create pods that violate this policy
		
	4. Make your application easy to monitor
		- prometheus GKE
		- Metrics HTTP endpoint
			- expose the health of your application
		- Sidecar pattern for monitoring
		
	5. Expose the health of your application
		- is the application running? 
		- Is it healthy? 
		- Is it ready to receive traffic? 
		- How is it behaving?

		1. Liveness probe
			- container is running/available
				- let Kubernetes know if your app is alive or dead.
			- send req to endpoint /healthz if reutrn "200 OK", means healthy so no killed or restart
				- The application is running.
				- Its main dependencies are met (for example, it can access its database).
		
		2. Readiness probe
			- container ready/healthy  to serve incoming traffic
				- imagine that your app takes a minute to warm up and start
			-/ready
				- The application is healthy.
				- Any potential initialization steps are completed.
				- Any valid request sent to the application doesn't result in an error. as root
	
	6. Avoid running as root
	7. Carefully choose the image version

Best practices for enterprise multi-tenancy
	1. Setting up folders, projects and clusters
		- Establish a folder and project hierarchy.
		
		- Assign roles using IAM.
		
		- Centralize network control with Shared VPCs.
			- Create one cluster admin project per cluster.
			- Make clusters private.
			- Ensure the control plane for the cluster is regional.
			- Ensure nodes in your cluster span at least three zones.
			- Autoscale cluster nodes and resources.
			- Schedule maintenance windows for off-peak hours.
			- Set up an external Application Load Balancer with Ingress.
			- Consider when setting up your network
				- The maximum number of service projects that can be attached to a host project is 1,000, and the maximum number of Shared VPC host projects in a single organization is 100.
				- The Node, Pod, and Services IP ranges must all be unique. You cannot create a subnet whose primary and secondary IP address ranges overlap.
				- The maximum number of Pods and Services for a given GKE cluster is limited by the size of the cluster's secondary ranges.
				- The maximum number of nodes in the cluster is limited by the size of the cluster's subnet's primary IP address range and the cluster's Pod address range.
				- For flexibility and more control over IP address management, you can configure the maximum number of Pods that can run on a node. By reducing the number of Pods per node, you also reduce the CIDR range allocated per node, requiring fewer IP addresses.

			- GKE IPAM calculator
				- calculate subnets for your clusters
				- https://github.com/GoogleCloudPlatform/gke-ip-address-management

			- Determine the size of your cluster
				- The sizing of your cluster is dependent on the type of workloads you plan to run. If your workloads have greater density, the cost efficiency is higher but there is also a greater chance for resource contention.
				- The minimum size of a cluster is defined by the number of zones it spans: one node for a zonal cluster and three nodes for a regional cluster.
				- Per project, there is a maximum of 50 clusters per zone, plus 50 regional clusters per region.
				- Per cluster, there is a maximum of 15,000 nodes per cluster (5,000 for GKE versions up to 1.17), 1,000 nodes per node pool, 1,000 nodes per cluster (if you use the GKE Ingress controller), 256 Pods per node (110 for GKE versions older than 1.23.5-gke.1300), 150,000 Pods per cluster, and 300,000 containers per cluster. Refer to the Quotas and limits page for additional information.

			- Schedule maintenance windows
		
		- Creating reliable and highly available clusters	
			- Autoscale cluster nodes and resources		
			- Determine the size of your cluster
			- Schedule maintenance windows
			- Set up an external Application Load Balancer with Ingress

	4. Securing the cluster for multi-tenancy
		- Control Pod communication with network policies.
			- metadata:
  			name: deny-all
		
		- Run workloads with GKE Sandbox.
			- provides two isolation boundaries between the container and the host OS:
				- A user-space kernel, written in Go, that handles system calls and limits interaction with the host kernel. Each Pod has its own isolated user-space kernel.
				- The user-space kernel also runs inside namespaces and seccomp filtering system calls.
		
		- Set up policy-based admission controls.
			- Policy Controller: 
				- Declare pre-defined or custom policies and enforce them in clusters at scale using fleets. Policy Controller is an implementation of the open source Gatekeeper open policy agent and is a feature of GKE Enterprise.
			- PodSecurity admission controller: 
				- Enforce pre-defined policies that correspond to the Pod Security Standards in individual clusters or in specific namespaces.
		
		- Use Workload Identity Federation for GKE to grant access to Google Cloud services.
			- enable workload identity federation for GKE in the cluster
				- secure grantn access to GC services

		- Restrict network access to the control plane.
			- enable authorized networks
				- protect control plan

	5. Tenant provisioning
		- Create tenant projects.
			-  contain logical resources specific to the tenant applications (for example, 	
				- logs, monitoring
				- storage buckets
				- service accounts, etc.)

		- Use RBAC to refine tenant access.
			- finer-grained access to cluster resource

			Tenant Developer
				- Grants access to create/edit/delete Pods, deployments, Services, configmaps in their namespace.

			Tenant admin
				- namespace admin
				- Grants access to list and watch deployments in their namespace.
				- Grants access to add and remove users in the tenant group.
		
		- Create namespaces for isolation between tenants.
			- Avoid reaching namespace limits
			- Standardize namespace naming
			- Create service accounts for tenant workloads
			
		- Enforce resource quotas

	6. Monitoring, logging and usage
		- Track usage metrics.
			- enable GKE cost allocation
				- appear in the labels field of the billing export to BigQuery.
				- not spoort autopilot cluster
		
		- Provide tenant-specific logs.
			- use Cloud Logging's Log Router for specific project workloads

		7. Checklist summary
			- https://cloud.google.com/kubernetes-engine/docs/best-practices/enterprise-multitenancy#checklist

Introducing Rollout Strategies in the Kubernetes V2 Provider
	- Use Spinnaker
		- support 
			- blue/green deployment
				- you keep the previous version available as a hot standby to enable painless rollback
				
			- dark deployment


Managing infrastructure as code with Terraform, Cloud Build, and GitOps
	- using a Git repository to store the environment state that you want.

	The State of DevOps 
		- Version control
		- Continuous integration
		- Continuous delivery
		- Continuous testing

Building VM images using Packer 
	Packer 
		- is an open source tool for creating identical Virtual Machine (VM) images for multiple platforms from a single source configuration.

Secret Manager overview 
	- lets you store, manage, and access secrets as binary blobs or text strings
	- configuration information such as
		- database passwords
		- API keys,
		- TLS certificates needed by an application at runtime

	Secret
		- project-global object that contains a collection of metadata and secret versions.

	Version
		- stores the actual secret data, such as API keys, passwords, or certi
		- cannot modify a version, but you can delete it.

	Rotation
		- rotate a secret by adding a new secret version to the secre
		- Any version of a given secret can be accessed, as long as that version is enabled

Cloud KMS
	- manage cryptographic keys and to use them to encrypt or decrypt data
	- cannot view, extract, or export the key material itself.
	- more complex and less efficient than using Secret Manager.

Binary Authorization
	-  a service on Google Cloud that provides centralized software supply-chain security for applications that run on Google Kubernetes Engine (GKE) and GKE clusters

Manage Traffic Using Kubernetes Manifests
	- Use Spinnaker to deploy Kb8s manifests
		- blue/green deployment

Implementing Binary Authorization using Cloud Build and GKE 
	Binary authorization
		- is the process of creating attestations on container images for the purpose of verifying that certain criteria are met before you can deploy the images to GKE.
		- s the process of creating attestations on container images for the purpose of verifying that certain criteria are met before you can deploy the images to GKE.

	CI/CD Pipeline using Cloud Source Repositories, Cloud Build, Artifact Registry, and GKE. 
		Build

		Deploy to staging

		Deploy to Prod

Best practices for using Terraform
	- https://cloud.google.com/docs/terraform/best-practices-for-terraform#google-cloud-resources
	
	1. General style and structure guidelines
		- Follow a standard module structure.
		- Adopt a naming convention.
		- Use variables carefully.
		- Expose outputs.
		- Use data sources.
		- Limit the use of custom scripts.
		- Include helper scripts in a separate directory.
		- Put static files in a separate directory.
		- Protect stateful resources.
		- Use built-in formatting.
		- Limit the complexity of expressions.
		- Use count for conditional values.
		- Use for_each for iterated resources.
		- Publish modules to a registry.

	2. Reusable modules
		- Activate required APIs in modules.
		- Include an owners file.
		- Release tagged versions.
		- Don't configure providers or backends.
		- Expose labels as a variable.
		- Expose outputs for all resources.
		- Use inline submodules for complex logic.
	
	3. Terraform root modules
		- Minimize the number of resources in each root module.
		- Use separate directories for each application.
		- Split applications into environment-specific subdirectories.
		- Use environment directories.
		- Expose outputs through remote state.
		- Pin to minor provider versions.
		- Store variables in a tfvars file.
		- Check in .terraform.lock.hcl file.

	4. Cross-configuration communication

	5. Working with Google cloud resources
		- Provision virtual machine instances.
		- Manage Identity and Access Management.

	6. Version control
		- Use a default branching strategy.
		- Use environment branches for root configurations.
		- Allow broad visibility.
		- Never commit secrets.
		- Organize repositories based on team boundaries.

	7. Operations
		- Always plan first.
		- Implement an automated pipeline.
		- Use service account credentials for CI.
		- Avoid importing existing resources.
		- Don't modify Terraform state manually.
		- Regularly review version pins.
		- Use application default credentials when running locally.
		- Set aliases to Terraform.

	8. Security
		- Use remote state.
		- Encrypt state.
		- Don't store secrets in state.
		- Mark sensitive outputs.
		- Ensure separation of duties.
		- Run pre-apply checks.
		- Run continuous audits.

	9. Testing
		- Use less expensive test methods first.
		- Start small.
		- Randomize project IDs and resource names.
		- Use a separate environment for testing.
		- Clean up all resources.

Find Ops Agent troubleshooting information 
	Ops Agent checks for the following
		- Connectivity problems
		- Availability of ports used by the agent to report metrics about itself
		- Permission problems
		- Availability of the APIs used by the agent to write logs or metrics
		- A problem in the health-check routine itself.
		- Version 2.37.0 introduced runtime heath checks for the Ops Agent
		- Version 2.46.0 introduced the informational LogPingOpsAgent code

	A prolonged Pending status might indicate one of the following
		- A problem applying the policy.
		- A problem in the actual installation of the Ops Agent.
		- A connectivity problem between the VM and Cloud Monitoring.

	Agent status
		- can check the status of the Ops Agent processes on the VM to determine if the agent is running or not.

	Agent logs ingest to Cloud logging troubleshooting
		- inspect the agent's logs locally on the VM for troubleshooting.
			- journalctl -u google-cloud-ops-agent*
			- vim -M /var/log/google-cloud-ops-agent/subagents/logging-module.log
		
		- can also use log rotation to manage 
			- the agent's self logs.















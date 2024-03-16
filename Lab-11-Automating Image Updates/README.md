# Lab 11. Automating Image Updates
Automate scan registry and update image metadata
Automate the commit of new image tags to GitHub
Note: If you see discrepancies between instructions in the video lessons versus the lab guide,
trust the lab guide, as it gets updated often and is expected to contain working code.

# Reflecting Image Updates
# Enable Image Automation
At the time of writing this lab (May 2021), Image Automation Controllers and Image Reflector
Controllers are in Alpha. Don’t use image automation in production yet; keep it to
non-production environments only. If you live on the bleeding edge and still decide to use it in
production, we suggest setting it to push to a new branch, which then can be merged into the
main/release branches to trigger the actual deployment.
Bootstrap again with the following --components-extra option added:
flux check
flux bootstrap github
--owner=$GITHUB_USER \
--repository=flux-infra \
--branch=main \
--path=./clusters/staging \
--personal \
--log-level=debug \
--network-policy=false \
--components-extra=image-reflector-controller,image-automation-controller
flux check

# Setting Up the Image Repository Scanning
Create an image repository to scan the images from.
flux get image repository
flux create image repository vote --image=xxxxx/vote --interval=1m
flux get image repository
Replace xxxxx with your Docker Hub account ID used to publish the image.

# Define the Image Selection Policy
You have set up a CI process which tags the image with the following format
`* ${GITBRANCH}-${GITSHA:0:7}-$(date +%s)
An example is main-e5d27a2c-1619063680
Where,
● GIT_BRANCH : main
● GIT_SHA:0-7 : first 8 characters from git commit e.g. e5d27a2c
● $(date +%s): timestamp (date + time) in literal format e.g. 1619063680
To select the latest version using the above pattern, and to select the latest version of the image
based on the timestamp, add the image selection policy:
flux create image policy vote \
--image-ref=vote \
--select-numeric=asc \
--filter-regex='^main-[a-f0-9]+-(?P<ts>[0-9]+)' \
--filter-extract='$ts'
Where,
● --image-ref=vote : reference to the repository created above
● --select-numeric=asc : select based on the numeric value ordered as ascending
values
● --filter-regex : look for tags matching this regex. Fetch only those e.g.
main-e5d27a2c-1619063680
● --filter-extract='$ts': decide which image is the latest based on this field. In
this case it is the timestamp.

Flux needs some way to decide which image is the latest from the tags it
fetches using the regex pattern. This is why it is important to add a timestamp
field to the image tag. Timestamp is in the literal format, which is easy to sort.

Greater the number, the more recent the image. Other sorting options include
sorting based on alphabetic order or using semver.
Once created, you can validate if Flux has picked up the latest image by using the policy above
running the following command:
flux get images policy
If you would like to further create and publish a new image to test with the policy, you would
have to run the CI pipeline again and validate if Flux picks it up.

# Auto Committing Image Tags to GitHub
Mark the Deployment Code for Image Replacement
Now mark the Kustomization manifests (deployment code) where you would like images to be
automatically updated by Flux. You can refer to the examples provided here: Automate image
updates to Git - Flux | GitOps Toolkit
e.g. file: instavote/deploy/vote/staging/kustomization.yaml
Before
images:
- name: schoolofdevops/vote
newTag: v8
After
images:
- name: schoolofdevops/vote
newTag: v8 # {"$imagepolicy": "flux-system:vote:tag"}
Rules to replace images:
● If a complete image URL is defined in a manifest, use the policy name,
image: sofd/vote:v8 # {“$imagepolicy”: “flux-system:vote”}
`
● If only the tag is defined, use policy name:tag
newTag: v8 # {"$imagepolicy": "flux-system:vote:tag"}
Check for existing image update rules:
flux get images update

Now, set up an image update rule to automatically update images:
flux create image update instavote-all \
--git-repo-ref=instavote \
--git-repo-path="./deploy/vote/staging" \
--checkout-branch=main \
--push-branch=main \
--author-name=flux \
--author-email=flux@example.com \
--commit-template="{{range .Updated.Images}}{{println .}}{{end}}"
Here, Flux is going to update any images.
When you apply this, you may see it fail due to an authentication error.
[sample output]
✚ generating ImageUpdateAutomation
► applying ImageUpdateAutomation
✔ ImageRepository created
◎ waiting for ImageUpdateAutomation reconciliation
✗ authentication required

The root cause here is Flux does not have write access to the GitRepository it is referring to to
fetch and apply the deployment code from. You can provide it with write access by creating a
secret using the GITHUBUSERNAME and GITHUBTOKEN environment variables defined earlier.

# Generate a Secret to Authenticate with Git Repo
To do so, begin by creating a Kubernetes secret, this time using the flux utility (yes, Flux does
have a subcommand to generate secrets).
flux create secret -h
flux create secret git -h
flux create secret git github-instavote \
--url=https://github.com/xxxxxx/instavote \
--username=$GITHUB_USER \
--password=$GITHUB_TOKEN
kubectl get secrets -n flux-system
kubectl describe secret -n flux-system github-instavote
Once a secret is created, update the existing GitRepository source to refer to the secret added
above so that now Flux has write access to it.
e.g. file: flux-infra/clusters/staging/instavote-gitrepository.yaml
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
name: instvote
namespace: flux-system
spec:
interval: 30s
ref:
branch: main
secretRef:
name: github-instavote
url: https://github.com/xxxxxx/instavote.git
Pay special attention to the secretRef part as below.
secretRef:
name: github-instavote
This is the part that you need to update. Once done, commit the changes and push it to the
flux-infra repo.
Once the git repository source is updated with the secret, with the next reconciliation, you
should see Flux triggering an automated image update. If not, you could run it as:
flux reconcile image update instavote-all

And check if the image has been committed to GitHub by Flux:
flux get images update
You can validate by:
●
Checking on the GitHub repo if a new commit has been added by FluxCD

# Fixing Issues with Images
At this time, you may see the kustomization for the vote app fail. You will see it attempting to
launch a new pod, however failing with error such as the one below:
Warning Failed
13m (x4 over 14m)
kubelet
Failed to pull image "schoolofdevops/vote:main-1c01cd25-1684430239":
rpc error: code = NotFound desc = failed to pull and unpack image
"docker.io/schoolofdevops/vote:main-1c01cd25-1684430239": failed to
resolve reference
"docker.io/schoolofdevops/vote:main-1c01cd25-1684430239":
docker.io/schoolofdevops/vote:main-1c01cd25-1684430239: not found
This is because it’s using the schoolofdevops/vote repository instead of yours. You can fix
it by adding the newName to the following file with the relevant repository name, as in:
File: deploy/vote/staging/kustomization.yaml
images:
- name: schoolofdevops/vote
newName: xxxxxx/vote
newTag: main-1c01cd25-1684430239 # {"$imagepolicy":
"flux-system:vote:tag"}
Replace xxxxxx/vote with the actual value. Once you make this change, you should see
Flux reconciling to the kubernetes environment successfully.


# Mini Project
Now that you have set up the image automation workflow for the vote app, it's time to repeat
the process for the result app.
For this you have to:
Create the Image Repository Scanner
Create the Image Policy
Since the result app is being deployed with Helm, use the values files for the Helm
release and update that with Flux
Create an Update Rule to push the image tags to the git source

Solution
Create a repository to scan the images from the Docker repository/registry.
flux create image repository result --image=xxxxx/result --interval=1m
Create the image policy with:
flux create image policy result \
--image-ref=result \
--select-numeric=asc \
--filter-regex='^main-[a-f0-9]+-(?P<ts>[0-9]+)' \
--filter-extract='$ts'
Create an image update rule, this time to point to the path where the helm chart for the result
app is.
flux create image update result \
--git-repo-ref=instavote \
--git-repo-path="./deploy/charts/result" \
--checkout-branch=main \
--push-branch=main \
--author-name=flux \
--author-email=flux@example.com \
--commit-template="{{range .Updated.Images}}{{println .}}{{end}}"

File: deploy/charts/result/values.yaml
image:
repository: dopspdemo/result
pullPolicy: IfNotPresent
# Overrides the image tag whose default is the chart appVersion.
tag: "latest" # {"$imagepolicy": "flux-system:result:tag"}
flux get image repository
flux get image policy
flux get image update
Since the result app is being deployed with helm, you will also have to update the version
number on line number 18 in deploy/charts/result/Chart.yaml as:

# This is the chart version. This version number should be incremented
each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning
(https://semver.org/)
version: 0.1.1
This will build a new version of the helm chart and deploy it.

Export and Commit Image Reflection and Automation Resources
After validating the image updates are working, it’s time to generate YAML manifests and push
them to the repository.
Begin exporting all the objects created as part of this lab thus far:
flux export image repository vote | tee vote-imagerepository.yaml
flux export image policy vote | tee vote-imagepolicy.yaml
flux export image update instavote-all | tee
vote-imageupdateautomation.yaml
flux export image repository result | tee result-imagerepository.yaml
flux export image policy result | tee result-imagepolicy.yaml
flux export image update result | tee
result-imageupdateautomation.yaml
Add, commit and push these manifests to the repo:
git status
git add *.yaml
git commit -am "add image automation code"
git push origin main
This completes the lab on automating image updates, which is a very interesting and useful
feature of Flux.
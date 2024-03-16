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
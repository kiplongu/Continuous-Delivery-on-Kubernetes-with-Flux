Lab 5. Git Essentials for a GitOps Practitioner

Overview

In this lab, you are going to learn the essentials of the Git workflow, including:

How to add Global Configurations to Git
How to start Revision Controlling your code with Git and GitHub
How to check Logs, Status, Commit History, Staging Areas, etc.
How to get started with Git Branches and Remotes
How to submit changes with Pull Request-based Workflows
How to enforce Branching Policies (e.g., Trunk-based Development Model)
How to Release your code using Semantic Versioning and by creating Tags

Basic Git Operations

To begin learning Git, you need:

An account on GitHub. If you haven’t yet signed up, begin by creating an account
here
Git Client installed. Refer to Git - Installing Git for installing Git on your system.
Begin by validating that git client is installed by running:
git
If you see an output with options to the git utility, it means it is installed on your system.

Forking and Cloning the Repository

Begin by creating a fork of GitHub - lfs269/instavote: Instavote - Example Voting Application.
Forked from Docker Samples Org.

Now clone the forked repository to your system as:

git clone https://github.com/xxxxxx/instavote.git

where you will replace xxxxxx with the actual GitHub account/org name that you forked the
repository with.

Adding Global Configurations to Git

To set up configurations (such as which user is committing to the repository), you need to
configure git; more specifically, add global configuration (user specific).
To list the existing config use, run:

git config
git config --list --global

To add the essential configuration related to the user, run:

git config --global user.name "Your Name"
git config --global user.email "name@example.com"
Ensure that the user name and email address match your GitHub account.
Validate the configurations by running:
git config --list --global
Auto Generating Manifests and Tracking with Git
Change into the path where you have cloned the repository earlier. e.g.

cd instavote
mkdir deploy
cd deploy
mkdir vote redis
cd vote
Now generate the deployment and services for the vote app:
kubectl create deployment vote --image=schoolofdevops/vote:v1
--replicas 2 --dry-run=client -o yaml > deployment.yaml
kubectl create service nodeport vote --tcp=80 --node-port=30000
--dry-run=client -o yaml > service.yaml
To add the deployments and services for redis, run:
cd ..
cd redis
kubectl create deployment redis --image=redis:alpine --dry-run=client
-o yaml > deployment.yaml
kubectl create service
yaml > service.yaml
clusterip redis --tcp=6379 --dry-run=client -o
Start revision controlling these manifests with git, as in:

cd ..
git status
git add *
git status

git commit -am "added deploy code for vote and redis"
git status
git log
git push origin main
When it asks for the password, you should provide a token that you can generate from the
token’s page Sign in to GitHub · GitHub as follows:

Branching and Merging
Try creating a new branch of development and switching to it, as in:
git branch
git branch test
git branch
git log
git checkout test
git branch
Alternatively, you could have achieved this in one step using git checkout -b test.
It’s now time to add a file to the branch created above:
cd deploy
echo "This is a Deployment Code for Kubernetes" > README.md
git status
git add README.md
git status
git commit -am "added README for deploy code"
git status
git log
Try modifying the file now:
echo "This code would be used by Flux to deploy to a kubernretes
environment" >> README.md
git status
git add README.md
git status
git commit -am "updated README"
git status
git log
To bring these changes into the main branch, run:
git checkout main
git merge test
To have it be reflected on GitHub, push the changes to it as in:
git push origin main
Ensure you are using a token instead of the password.

To delete the branch, use:
git branch -D test
git branch
git log

Raising Pull Requests to Merge Changes
Create a branch from the GitHub UI named featureA:

On to your local workstation, pull the changes so that it starts tracking the remote branch, e.g.:
# git pull origin
From https://github.com/devops-0001/instavote
* [new branch]
featureA
-> origin/featureA
Already up to date.
Switch to the newly created branch, as in:
git branch featureA
cd deploy
Edit vote/deployment.yaml to add labels, as in:

Validate the changes:
git diff
git log
git commit -am "added a new label to vote app"
git log
git push origin featureA
Verify the changes are available in the commit history, as in:

Enforcing Trunk Based Development Model
You can read about the different branching models here:


Trunk Based Development
GitHub Flow
Git Flow
GitHub Flow vs.Trunk Based


Tagging Releases with git tag
You can read about Git Tagging related topics here:

Git Tagging
Semantic Versioning
git branch
Create a special branch to cut the releases from:
git checkout -b 0.1
To create and list a tag with a patch release:
git tag -a v0.1.0 -m "initial release"
git tag
git tag 4.0
git tag
To view the most recent tag:
git show
To see the difference between a simple tag (4.0) and an annotated tag (v0.1.0), run:
git show 4.0
git show v0.1.0

Where the annotated tag shows additional info, such as:
[sample output]
tag v0.1.0
Tagger: Gourav Shah <gs@initcron.org>
Date:
Wed May 17 07:21:03 2023 +0000
initial release

It is recommended to use annotated tags.
To delete the tag, run:
git tag
git tag -d 4.0
git tag
To push the tags to GitHub, run:
git push origin v0.1.0
At this time, you shall see a new release added to the repository:
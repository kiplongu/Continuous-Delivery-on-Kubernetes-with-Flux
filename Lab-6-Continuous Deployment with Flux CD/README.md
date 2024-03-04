Lab 6. Continuous Deployment with Flux CD

Prerequisites

Create a Personal Access Token with full repository access. To do so, login to your GitHub
account and go to Settings.

From account Settings, select Developer Settings.

Choose Personal Access Token and click on Generate.

Provide a name for the token, select full repo access, along with admin:repo_hook →
read:repo_hook and click on Create.

Retain the page which displays the token (one time) until you set the environment variables in
your shell permanently.

Set up the environment variables, preferably permanently, in the shell profile script by adding
the following lines in ~/.bashrc or the equivalent file for your shell.
Make sure you have replaced the values of the token and user with the actual values, by
removing < >.

export GITHUB_TOKEN=<your-personal-access-token>
export GITHUB_USER=<your-github-username>

Install Flux CLI

To set up continuous deployment with Flux, begin by downloading and installing the Flux CLI.

On Mac:

brew install fluxcd/tap/flux

On Mac or Linux using curl:

curl -s https://fluxcd.io/install.sh | sudo bash
[Sample Output]
```
[INFO] Downloading metadata
https://api.github.com/repos/fluxcd/flux2/releases/latest
[INFO] Using 2.0.0-rc.3 as release
[INFO] Downloading hash
https://github.com/fluxcd/flux2/releases/download/v2.0.0-rc.3/flux_2.0
.0-rc.3_checksums.txt
[INFO] Downloading binary
https://github.com/fluxcd/flux2/releases/download/v2.0.0-rc.3/flux_2.0
.0-rc.3_linux_amd64


For additional Operating Systems Support, please refer to the Flux Installation documentation.

To enable bash completion, add the following to ~/.bashrc
echo "source /etc/bash_completion" >> ~/.bashrc
echo ". <(flux completion bash)" >> ~/.bashrc
Also install bash-completion as needed.
e.g.
apt update
apt install bash-completion
Apply the configs to the current shell:
source ~/.bashrc_________________________

To validate, run flux followed by double Tab (press the Tab key twice), and you should see an
output similar to the following:
# flux [tab][tab]
bootstrap
completion
suspend
check
create
uninstall
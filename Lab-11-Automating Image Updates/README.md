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
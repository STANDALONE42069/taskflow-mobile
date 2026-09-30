# Lab 10 mobile pipeline

The Jenkinsfile runs in a Kubernetes pod with `cirruslabs/flutter:stable` and
OSV Scanner. Analyze, widget tests with coverage, and dependency scanning run as
parallel gates. Every branch produces a debug APK. Only `main` can build the
release AAB, and Jenkins must provide the three Android signing credentials
listed in the API repository's `docs/lab10/SETUP.md`.

The analyzer reports pre-existing style and deprecation hints as informational;
warnings and errors remain blocking.

The Jenkins Kubernetes cloud name is `kubernetes`, configured in Lab 9. The
pod disables service-account token mounting because the mobile build does not
need Kubernetes API access. Artifact paths are archived by the Jenkinsfile.

Set `TASKFLOW_SLACK_CHANNEL` or `TASKFLOW_CI_EMAIL_RECIPIENTS` in Jenkins to
send success and failure notifications with the branch and build URL.

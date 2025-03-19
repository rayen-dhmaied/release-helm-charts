# Release Helm Charts GitHub Action  

This GitHub Action automates the process of releasing Helm charts using Github Pages through the following steps:
- Checkout the charts branch and publish (GitHub Pages) branch in seperate directories
- Update dependencies
- Find new or modified Helm charts
- Lint charts
- Package linted charts
- Update index
- Push index and packages to publish branch

## Usage

### Prerequisites

To enable GitHub Pages for this GitHub Action:  

1. **Create a new branch** (e.g., `gh-pages`).  
2. **Check out the branch**, delete all files (if you don’t want to expose your code), then commit and push.  
3. **Go to Repository Settings** → **Code and Automation** → **Pages** and select the branch for deployment.  

💡 **Tip:** Naming the branch `gh-pages` automatically enables GitHub Pages.

## Inputs  

| Name            | Description                                      | Required | Default       |
|----------------|--------------------------------------------------|----------|--------------|
| `charts_branch` | Branch to pull the Helm charts from             | ❌ No    | `main`       |
| `publish_branch` | Branch to push the Helm charts to              | ❌ No    | `gh-pages`   |
| `charts_dir`   | Path to the Helm charts directory                 | ❌ No    | `helm-charts` |
| `helm_version` | Helm version to install                         | ❌ No    | `v3.12.0`    |
| `token`        | GitHub token for authentication                  | ✅ Yes   | N/A          |


### Example Workflow 

```yaml
name: Release Helm Charts  

on:
  workflow_dispatch: # Workflow manual Execution
  push:
    branches:
      - main
    paths:
      - 'helm-charts/**'

jobs:
  release-helm-charts:
    runs-on: ubuntu-latest
    steps:
      - name: Release Helm Charts
        uses: rayen-dhmaied/release-helm-charts@v1
        with:
          charts_branch: main
          charts_dir: helm-charts
          publish_branch: gh-pages
          token: ${{ secrets.GITHUB_TOKEN }}
```

## How to use the Helm Repo

```sh
helm repo add <repo_name> https://<github_username>.github.io/<github_repo_name>
helm repo update
```
## Notes  

- The `token` input should be a **GitHub token** with `repo` scope to push changes.  
- Ensure that `charts_branch` and `publish_branch` exist in your repository.  
- The action assumes Helm charts are stored inside `charts_dir` (default: `helm-charts`).  

## Contributing  

Contributions are welcome! Feel free to open issues or pull requests to improve this action.  

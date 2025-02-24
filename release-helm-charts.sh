#!/bin/bash

echo "🔹 Updating Helm chart dependencies..."

CHARTS=()
for CHART_DIR in src/$CHARTS_DIR/*; do
  if [ -d "$CHART_DIR" ]; then
    CHART_NAME=$(basename "$CHART_DIR")

    if helm dependency update "$CHART_DIR"; then
      echo "✅ Dependencies updated: $CHART_NAME"
      CHARTS+=("$CHART_NAME")
    else
      echo "❌ Failed to update dependencies: $CHART_NAME" >&2
    fi
  fi
done

echo "🔹 Identifying modified or new charts..."

CHARTS_TO_LINT=()
for CHART in "${CHARTS[@]}"; do
    PACKAGE_NAME=$(helm show chart "src/$CHARTS_DIR/$CHART" | awk '/name:/ {name=$2} /version:/ {version=$2} END {print name "-" version ".tgz"}')

    if [ ! -f "dest/$CHART/$PACKAGE_NAME" ]; then
      echo "📌 New or updated chart detected: $CHART"
      CHARTS_TO_LINT+=("$CHART")
    else
      helm template "src/$CHARTS_DIR/$CHART" > new.yaml
      helm template "dest/$CHART/$PACKAGE_NAME" > old.yaml
      if ! diff new.yaml old.yaml > /dev/null; then
        echo "📌 Modified chart detected: $CHART"
        CHARTS_TO_LINT+=("$CHART")
      fi
    fi
done

echo "🔹 Linting charts..."

LINTED_CHARTS=()
for CHART in "${CHARTS_TO_LINT[@]}"; do
  if helm lint "src/$CHARTS_DIR/$CHART"; then
    echo "✅ Lint successful: $CHART"
    LINTED_CHARTS+=("$CHART")
  else
    echo "❌ Lint failed: $CHART" >&2
  fi
done

echo "🔹 Packaging charts..."

PACKAGED_CHARTS=()
for CHART in "${LINTED_CHARTS[@]}"; do
  if helm package "src/$CHARTS_DIR/$CHART" --destination "dest/$CHART"; then
    echo "✅ Packaged successfully: $CHART"
    PACKAGED_CHARTS+=("$CHART")
  else
    echo "❌ Packaging failed: $CHART" >&2
  fi
done

if [ ${#PACKAGED_CHARTS[@]} -gt 0 ]; then
  echo "🔹 Updating Helm repo index..."
  helm repo index dest --url /$GITHUB_REPO_NAME
  echo "🔹 Committing and pushing changes..."
  cd dest
  git add .
  git commit -m "Update Helm charts and index"
  git push origin $PUBLISH_BRANCH
else
  echo "🔹 No changes detected. Skipping commit and push."
fi
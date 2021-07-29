#!/usr/bin/env bash
# Ugly quick and dirty hack to make new release more easy
# Require yq and coreutils

: "${1?"Usage: $0 You need to specifiy a version"}"

RELEASE="$1"
URI=("interceptors" "release")

for uri in "${URI[@]}"
do
  BASEURL="https://storage.googleapis.com/tekton-releases/triggers/previous/${RELEASE}/${uri}.yaml"
  curl -s -L -O "$BASEURL" > /dev/null
  csplit --prefix=tk-${uri} ${uri}.yaml \
		--elide-empty-files \
		--quiet \
		--suffix-format='%02d.yaml' \
		"/---/+1" '{*}'
  for file in tk-${uri}*; do
		kind=$(yq -M -r '.kind // empty' "$file"|tr '[:upper:]' '[:lower:]')
		name=$(yq -M -r '.metadata.name // empty' "$file")
		mv "$file" "$kind-$name.yaml"
  done
  rm ${uri}.yaml
done

rm kustomization.yaml
kustomize create --autodetect


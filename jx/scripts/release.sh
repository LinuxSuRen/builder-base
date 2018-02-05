#!/usr/bin/env bash

# ensure we're not on a detached head
git checkout master

# until we switch to the new kubernetes / jenkins credential implementation use git credentials store
git config credential.helper store

export VERSION="$(jx-release-version)"
echo "Releasing version to ${VERSION}"

docker build -t docker.io/$ORG/$APP_NAME:${VERSION} .
docker tag docker.io/$ORG/$APP_NAME:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER docker.io/$ORG/$APP_NAME:latest

docker push docker.io/$ORG/$APP_NAME:${VERSION}
docker push docker.io/$ORG/$APP_NAME:latest

#jx step tag --version ${VERSION}
git tag -fa v${VERSION} -m "Release version ${VERSION}"
git push origin v${VERSION}

updatebot push-version --kind docker jenkinsxio/builder-base ${VERSION}
updatebot push-version --kind helm jenkinsxio/builder-base ${VERSION}

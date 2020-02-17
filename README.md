# Portus-Docker
A lightweight Docker image containing an installation of [Portus by SUSE](https://github.com/SUSE/Portus.git), based on Alpine Linux.

This image builds itself directly from the official sources.

## Motivation

SUSE does provide Dockerfiles for Portus, however those are either for development only, not compiled from the current source code in the repository, but rather from the precompiled packages from the OpenSUSE packet sources.

This image is based on Alpine Linux and uses Docker multi-stage builds to keep its size down. It also precompiles all assets and builds a production version of the software. It was primarily written to run forks of the official code, or just to really control what code goes into your image.

## Compilation
Build using Docker: `docker build -t stargate01/portus:latest .`

Optional build arguments (`--build-arg`):
 - **VERSION_STRING**: The displayed version string. (Default: v2.5)
 - **REPO_TAG**: The Tag or branch of the repository to be built. (Default: v2.5)
 - **REPO_URL**: The repository URL, if you would like to build a fork. (Default: https://github.com/SUSE/Portus.git )

## Local Testing
A basic Docker Compose configuration is provided. Check the domain names in `config/*.env and docker-compose.yml` (Default: `registry.home` and `portus.home`)

Generate a certificate for token auth: `cd config && ./gen-certs.sh`

Start a stack containing Portus, the background worker for Portus, a Docker registry and a MariaDB database: `docker compose build && docker-compose up`

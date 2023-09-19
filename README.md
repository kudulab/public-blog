# public-blog

This is a repository supporting deployment of https://kudulab.io

A post describing this setup - https://kudulab.io/posts/blog-aws-github-pages/

## Workflow

1. Be sure to clone this repository with git submodules:
```
# If it's the first time you checkout a repo:
git submodule sync
git submodule update --init --recursive
# otherwise:
git submodule sync
git submodule update --recursive
```
1. Start live preview with `./tasks live_preview`.
1. Add post in `src/content/posts/`
1. Run `./tasks set_version 0.X.0` and fill-in the changelog.
1. `git push` to master to deploy.

## CICD Pipeline

In order for the CICD Pipeline to work, you need:
* to add an environment variable `GITHUB_CREDENTIALS` into CircleCI configuration. Please set its value to a value of github token, with the `repo` rights. This is needed for the `release` and `publish` stages of the CICD pipeline.
* to generate a 'Deploy Key' through the CircleCI configuration, under SSH Keys. The read-only one is enough. This is needed to checkout the git repository on CircleCI.

## License

Copyright 2019-2022 Ava Czechowska, Tom Setkowski

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

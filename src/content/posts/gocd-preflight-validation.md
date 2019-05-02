+++
date = "2019-05-03"
title = "GoCD configuration validation with preflight API"
description = "Walkthrough validating GoCD config-repos locally using new preflight API"
images = []
math = "false"
series = []
author = "Tomasz Sętkowski"
+++

In GoCD [19.2.0](https://www.gocd.org/releases/#19-2-0) [preflight API endpoint](https://api.gocd.org/current/#preflight-check-of-config-repo-configurations) was [merged](https://github.com/gocd/gocd/pull/5579), which allows to validate local GoCD configuration files (e.g. [YAML](https://github.com/tomzo/gocd-yaml-config-plugin), [JSON](https://github.com/tomzo/gocd-json-config-plugin)) before submitting them to source control.

Every user has been long annoyed by slow feedback, when pushing configuration changes to GoCD only to find out in a moment that something is wrong on the errors and warnings page. This required to ammend last commit or push another one.

With the new API and gocd-cli it is now possible to get the same feedback before pushing changes. It takes less than a second, depending on hosting environment. In this post I would like to encourage config-repo GoCD users to adopt the routine of checking configuration early. Below is a walk through the setup and usage.

The supporting code is hosted on [github](https://github.com/tomzo/gocd-preflight-demo).

## Setup

We need the following components:

 * GoCD server >= 19.2.0
 * [gocd-cli](https://github.com/gocd-contrib/gocd-cli)
 * A git repository which will be our config-repo

### GoCD server setup

If you have admin access to a GoCD server, it is quite safe to try the preflight API, because the queries are not changing anything on the server.

Otherwise I would recommend to setup a local gocd server. There are several options to do so, my default way to go about it is with docker and official [gocd-server](https://github.com/gocd/docker-gocd-server) image. Since last stable release is `19.3.0`, the base image will be `gocd/gocd-server:v19.3.0` with GoCD 19.3.0.

We will now:

1. Setup gocd in docker.
1. Configure [filebased authentication plugin](https://github.com/gocd/gocd-filebased-authentication-plugin). Because [gocd-cli does not support working with insecure servers yet](https://github.com/gocd-contrib/gocd-cli/issues/35).

This process is automated in the [supporting repository](https://github.com/tomzo/gocd-preflight-demo).
It's sufficient to run
```
./tasks setup_gocd
```
The command will enter a container with `gocd` CLI installed and configured against the newly created GoCD server.

#### Manual setup

If for some reasons you need to setup GoCD manually, you can do so with the following steps.

Generate a `passwd` file, user is `admin` and password is `secret`
```
echo -n secret | htpasswd -i -B -c passwd admin
```

Start GoCD with docker, using the following command:
```
docker run -ti -p 8153:8153 -v $PWD/passwd:/godata/passwd gocd/gocd-server:v19.3.0
```

Open `http://localhost:8153` in your browser. You may need to wait for server to start before UI is ready.
Configure authentication with a password file, by browsing into `Admin->Authorization Configuration` and click `Add`.
Make sure you set password file path to `/godata/passwd`.

![GoCD password file setup](/images/gocd_passwd_auth.png)

Once configured you'll need to reload the page and login.

### Gettting GoCD CLI

[gocd-cli](https://github.com/gocd-contrib/gocd-cli) is in early development stage, it is not released yet. Currently one has to build it.
However, as I maintain the GoCD config repository plugins releases anyway, I have added a pipeline to build `gocd-cli` and a [docker image with it](https://github.com/gocd-contrib/docker-gocd-cli-dojo). I have also published binaries on my [fork](https://github.com/tomzo/gocd-cli/releases/tag/0.0.1).

#### GoCD CLI Configuration

GoCD CLI has to be configured to know where the GoCD endpoint is and how to authenticate with it.

If you have started with `./tasks setup_gocd`, then configuration has been done inside the docker container already.

If you are working with a manually set up server, make notice of the server url, it should end with `/go`, for example `https://go.mydomain.com/go`.
Regardless of whether you are using the [gocd-cli-dojo](https://github.com/gocd-contrib/docker-gocd-cli-dojo) docker image or have downloaded one of the binaries, configuration can be done with a yaml file.
In your home directory create a file `.gocd/settings.yaml` with the following content:

```yaml
auth:
  password: secret
  type: basic
  user: admin
config_version: 1
server:
  # make sure this url is correct!
  url: http://localhost:8153/go
```

### Setup configuration repository

In order to try capabilities of `gocd-cli`, we need a configuration repository.
You can fork [gocd-preflight-demo](https://github.com/tomzo/gocd-preflight-demo) as it has 1 simple pipeline called `preflight-demo`.
But don't add it to the GoCD yet.

# Trying out GoCD CLI

Now, once we are all set up, let's try working with `gocd-cli`.

Running `gocd` prints usage information:
```console
dojo@7f0b90d0ae1e(gocd-cli-dojo:):/dojo/work$ gocd
A command-line companion to a GoCD server

Usage:
  gocd [command]

Available Commands:
  about       About GoCD CLI
  config      GoCD CLI configuration
  configrepo  GoCD config-repo functions
  help        Help about any command

Flags:
  -c, --config string   config file (default is $HOME/.gocd/settings.yaml)
  -X, --debug           debug output; overrides --quiet
  -h, --help            help for gocd
  -q, --quiet           silence output
      --version         version for gocd

Use "gocd [command] --help" for more information about a command.
```

The most interesting commands are under `gocd configrepo`:
```console
dojo@7f0b90d0ae1e(gocd-cli-dojo:):/dojo/work$ gocd configrepo
Functions to help development of config-repos in GoCD (pipeline configs as code)

Usage:
  gocd configrepo [command]

Aliases:
  configrepo, cr

Available Commands:
  export      Exports the specified pipeline as a config-repo definition in the indicated config-repo plugin format
  fetch       Fetches configrepo plugins
  preflight   Preflights any number of definition files for syntax, structure, and dependencies against a running GoCD server
  rm          Deletes a config-repo by id
  show        Displays the settings for an existing config-repo
  syntax      Checks one or more definition files for syntactical correctness

Flags:
      --groovy              Alias for '--plugin-id cd.go.contrib.plugins.configrepo.groovy'
  -h, --help                help for configrepo
      --json                Alias for '--plugin-id json.config.plugin'
  -d, --plugin-dir string   The plugin directory to search for plugins
  -i, --plugin-id string    The config-repo plugin to use (e.g., yaml.config.plugin)
      --yaml                Alias for '--plugin-id yaml.config.plugin'

Global Flags:
  -c, --config string   config file (default is $HOME/.gocd/settings.yaml)
  -X, --debug           debug output; overrides --quiet
  -q, --quiet           silence output

Use "gocd configrepo [command] --help" for more information about a command.
```

We are working with a yaml repository, so we need to make sure we have a yaml plugin installed **locally**. To be consistent, we should have the same plugin version which is used by the server.

If you are using the [gocd-cli-dojo](https://github.com/gocd-contrib/docker-gocd-cli-dojo) docker image, then image already bundles the plugin. Image tags can help with picking the plugin version. For example, to use the `0.10.1` yaml plugin, you could create following [Dojofile](https://github.com/ai-traders/dojo#dojofile):
```toml
DOJO_DOCKER_IMAGE="kudulab/gocd-cli-dojo:yaml-0.10.1"
```
Then running `dojo` will ensure that this image is used to create the docker container.

If you are using a local binary, then [specific plugin version can be fetched with](https://github.com/gocd-contrib/gocd-cli#example-fetch-a-config-repo-plugin-matching-a-specific-version-or-a-version-range)
```
gocd configrepo --yaml fetch --match-version '0.10.1'
```

## Validate a new config repository

If you have forked [gocd-preflight-demo](https://github.com/tomzo/gocd-preflight-demo), then there is just one pipeline file with the following content:
```yaml
---
format_version: 4
pipelines:
  preflight-demo:
    group: www
    label_template: "${git[:8]}"
    materials:
      git:
        type: configrepo
    stages:
      - test:
          jobs:
            test:
              tasks:
                - exec:
                    command: /bin/bash
                    arguments:
                      - -c
                      - echo hello
```
It is not yet registered with the server. In this case, let's see if the proposed file is correct
```
$ gocd configrepo preflight --yaml pipeline.gocd.yaml
OK
```
Running the same command with `--debug` is also interesting, we can see what has actually happened:
```console
dojo@b934e5d49d46(gocd-cli-dojo:):/dojo/work$ gocd configrepo preflight --yaml pipeline.gocd.yaml --debug
[DEBUG] Running any necessary config migrations...
[DEBUG] Loaded config from: /home/dojo/.gocd/settings.yaml
[DEBUG] Sending API request POST http://gocd:8153/go/api/admin/config_repo_ops/preflight?pluginId=yaml.config.plugin
[DEBUG] Headers >>>
[DEBUG] Content-Type: multipart/form-data; boundary=e66832a9f9a0eeef51e397ff4654d8a8c8b324d278d40232359a7e2c4b1d
[DEBUG] Accept: application/vnd.go.cd.v1+json
[DEBUG] Authorization: :: REDACTED ::
[DEBUG] Body >>>
[DEBUG] --e66832a9f9a0eeef51e397ff4654d8a8c8b324d278d40232359a7e2c4b1d
Content-Disposition: form-data; name="files[]"; filename="pipeline.gocd.yaml"
Content-Type: application/octet-stream


[DEBUG] format_version: 4
pipelines:
  preflight-demo:
    group: www
    label_template: "${git[:8]}"
    materials:
      git:
        type: configrepo
    stages:
      - test:
          jobs:
            test:
              tasks:
                - exec:
                    command: /bin/bash
                    arguments:
                      - -c
                      - echo hello

[DEBUG]
--e66832a9f9a0eeef51e397ff4654d8a8c8b324d278d40232359a7e2c4b1d--

[DEBUG] handling success response 200
[DEBUG] Response status code: 200
[DEBUG] Response Headers >>>
[DEBUG] X-Xss-Protection: 1; mode=block
[DEBUG] X-Content-Type-Options: nosniff
[DEBUG] Expires: Thu, 01 Jan 1970 00:00:00 GMT
[DEBUG] Cache-Control: max-age=0, private, must-revalidate
[DEBUG] Vary: Accept-Encoding, User-Agent
[DEBUG] Date: Thu, 02 May 2019 09:53:35 GMT
[DEBUG] X-Ua-Compatible: chrome=1
[DEBUG] Set-Cookie: JSESSIONID=node01nqjqb5g8fy853dvbwp82pbp34.node0;Path=/go;Expires=Thu, 16-May-2019 09:53:35 GMT;Max-Age=1209600;HttpOnly
[DEBUG] Set-Cookie: JSESSIONID=node01osr04qt4iled0jfizjvvnec5.node0;Path=/go;Expires=Thu, 16-May-2019 09:53:35 GMT;Max-Age=1209600;HttpOnly
[DEBUG] Content-Type: application/vnd.go.cd.v1+json;charset=utf-8
[DEBUG] X-Frame-Options: SAMEORIGIN
[DEBUG] Response Body >>>
{
  "errors" : [ ],
  "valid" : true
}
OK
```
The actions that took place:
1. `gocd-cli` has sent `multipart/form-data` with pipeline contents to the gocd server. Using the new preflight endpoint, the `POST` request was sent to `http://gocd:8153/go/api/admin/config_repo_ops/preflight?pluginId=yaml.config.plugin`
1. Server has received the configuration, validated it at a **global** scope and responsed with no errors:
```json
{
  "errors" : [ ],
  "valid" : true
}
```
On the local demo setup with docker, this operation takes `0.07` seconds, that's a nice feedback time!
```console
dojo@b934e5d49d46(gocd-cli-dojo:):/dojo/work$ time gocd configrepo preflight --yaml pipeline.gocd.yaml
OK

real	0m0.070s
user	0m0.004s
sys	0m0.009s
```

This is great for the the happy path. Let's break something to see how errors are communicated. We can make everybody's favorite yaml error - let's make extra identiation somewhere.
```yaml
format_version: 4
pipelines:
  preflight-demo:
      group: www
    label_template: "${git[:8]}"
    materials:
      git:
        type: configrepo
    stages:
      - test:
          jobs:
            test:
              tasks:
                - exec:
                    command: /bin/bash
                    arguments:
                      - -c
                      - echo hello
```
Then validate again:
```console
$ gocd configrepo preflight --yaml pipeline.gocd.yaml
pipeline.gocd.yaml:
  - Error parsing YAML. : Line 4, column 19: Expected a 'block end' but found: block mapping start :

$ echo $?
1
```
The error message is not the best, but at least it shows the line with the error. The message would be much better after adding [schema validation to the yaml plugin](https://github.com/tomzo/gocd-yaml-config-plugin/issues/113).
The exit code is `1` due to the validation error.

This covers basics of validating a new repository. Let's move on to working with config-repos already registered with the server.

## Validate existing repository

Let's add the configuration repository to GoCD server.
In order to add your fork to the server, browse to `Admin -> Config Repositories` and click on `Add`, then fill in the following pop-up

![Adding config repo](/images/gocd_add_preflight_repo.png)

1. Make sure you select `YAML Configuration Plugin`.
1. Then enter URL of the repository. A github fork URL would have following format `https://github.com/<your-github-account>/gocd-preflight-demo.git`.
1. Enter the `Config repository ID` and remember this. We will need it soon. In this walkthrough, we'll use `preflight-demo` as repository ID.
1. Click `Save` and wait a moment for the pipeline to appear on the dashboard.

![Pipeline on dashboard](/images/gocd_preflight_demo_pipe.png)

Now, let's see what happens when we try to validate our local `pipeline.gocd.yaml` again.
```
dojo@b934e5d49d46(gocd-cli-dojo:):/dojo/work$ gocd configrepo preflight --yaml pipeline.gocd.yaml
You have defined multiple pipelines called 'preflight-demo'. Pipeline names are case-insensitive and must be unique.

You have defined multiple pipelines named 'preflight-demo'. Pipeline names must be unique. Source(s): [cruise-config.xml, https://github.com/tomzo/gocd-preflight-demo.git at c1e3abd571d2d050e8767f277551016ab7164e9e]
```
We get a duplicate pipeline name error. This is because we did not tell GoCD that we are attempting to validate, what would happen, if we replaced `preflight-demo` repository with our local content. In order to fix this, let's add `-r` argument with config repo ID:
```
$ gocd configrepo preflight --yaml -r preflight-demo pipeline.gocd.yaml
OK
```
Now the check makes sense.

## Using the auth tokens

So far we have been using the username and password authentication method. `gocd-cli` supports token-based authentication, which is generally a better and more secure approach. You must be running `GoCD` >= 19.2.0 to use tokens.
There is a very clear screencast, on the [releases page](https://www.gocd.org/releases/#19-2-0), on how to generate a token.
Let's put `config-repo validation` as description:

![config-repo validation](/images/gocd_create_access_token.png)

We have previously configured `gocd-cli` to use a username and a password. In order to switch to tokens, use the following `.gocd/settings.yaml`:

```yaml
auth:
  # The generated token goes here:
  token: eb7abf46df710fbde5c2b532857069a5b1cce4ab
  type: token
config_version: 1
server:
  # make sure this url is correct!
  url: http://localhost:8153/go
```

We can check that this configuration also works:
```
$ gocd configrepo preflight --yaml -r preflight-demo pipeline.gocd.yaml
OK
```

## Implications

Above walkthrough demonstrates how we can validate configuration locally before sending it to the source control, and therefore GoCD. It makes sense that each developer working on pipeline config files, could adopt a routine in which before commiting and pushing the new pipelines, one would first check if validation passes.

The weak spot in this approach is that developers may simply forget to do this check. To protect against this, here is a [wild idea from almost 4 years ago](https://github.com/gocd/gocd/issues/1133#issuecomment-110326938) - create a pipeline which validates configuration repository before importing it in the server.

### CI for CI configuration

Config-repo users are increasingly experimenting with templates and generating configuration rather than crafting each YAML, JSON file manually. Such approach is usually driven by DRY (don't repeat yourself), it can also decrease readability and maintainability of the configuration.

If we think about configuration repository as a software project, then applying some best practices would mean that we test it, using the CI system, before the deployment. For a config repo project, the software lifecycle stages would translate to:

 * test - validate the configuration with the preflight API
 * deployment - push to source control configured as config repo

If we are generating the configuration files, then that would be an additional, earliest stage.

#### Example setup

In order for such setup to work, we would need additionally:

 * a GoCD agent capable of rendering configuration templates, using a template engine of our choice.
 * the GoCD agent being able to push to git repository
 * the GoCD agent having sufficient secrets to access the GOCD API
 * an additional pipeline responsible for delivery of valid configuration

Here is an example workflow, with a generation stage, that could be implemented:

1. Developer makes changes in the templates of configuration files.
1. Developer pushes these changes to a `config` branch of the repository.
1. GoCD picks up changes in `config` branch and starts a pipeline which runs 3 tasks:
   - generate - which executes the template engine to render the final configuration (e.g. JSON, YAML)
   - validate - which runs the `gocd configrepo preflight` command
   - commit and push - which would commit generated files, merge to `master` branch and push

A jinja template file could look like this:
```yaml
format_version: 4
pipelines:
  preflight-demo:
    group: {{ group }}
    label_template: "${git[:8]}"
    materials:
      git:
        type: configrepo
    stages:
      - test:
          jobs:
            test:
              tasks:
                - exec:
                    command: /bin/bash
                    arguments:
                      - -c
                      - echo {{ greating }}
```
Then, in order to render this pipeline, we could use python and [yasha](https://github.com/kblomqvist/yasha) package:
```
yasha --mode=pedantic --group=www --greating=hello -o pipeline.gocd.yaml pipeline.yaml.j2
```

A pipeline which generates and validates the configuration could look like this:
```yaml
format_version: 4
pipelines:
  preflight-demo.config:
    group: www
    label_template: "${git[:8]}"
    materials:
      git:
        git: git@github.com:tomzo/gocd-preflight-demo.git
        branch: config
    environment_variables:
      GOCDCLI_SERVER_URL: https://go.mydomain.com/go
      GOCDCLI_AUTH_TYPE: token
    secure_variables:
      GOCDCLI_AUTH_TOKEN: AES:ZWI3YWJmNDZkZjcxMGZiZGU1YzJiNTMyODU3MDY5YTViMWNjZTRhYiAK
    stages:
      - validate:
          jobs:
            config:
              tasks:
                - exec:
                    command: /bin/bash
                    arguments:
                      - -c
                      - ./tasks generate
                - exec:
                    command: dojo
                    arguments:
                      - -c
                      - Dojofile.val
                      - "./tasks validate"
                - exec:
                    command: /bin/bash
                    arguments:
                      - -c
                      - ./tasks publish
```
This example assumes you would be using the [gocd-cli-dojo](https://github.com/gocd-contrib/docker-gocd-cli-dojo) image to execute the validation step.

This is only a thought experiment. A draft is available in `recursive` branch of the [gocd-preflight-demo](https://github.com/tomzo/gocd-preflight-demo/tree/recursive) repository.

If you have any interest in setting up a full proof of concept, let me know in the comments.

#### Other pros and cons

Putting your configuration into a pipeline has a few **benefits**:

 * The materials used for generating the configuration can be anything that GoCD supports, particularly other repositories or artifacts fetched from dependant pipelines. This means you can share templates in whatever process you like.
 * Since the rendered configuration is eventually commited in the source control, this brings back the **readable preview** of what is the current state of GoCD configuration. After all, YAML is very easy to review. The repository with the generated content is the single source of truth.
 * Chances of introducing a broken config to the server are very low, especially if the only channel will be through the automated commit.

**Cons**:

 * Complexity builds on complexity. Excessive use of templates and dependencies might cause a maintainability crisis.
 * Using the extra branch and having to wait for another pipeline to pass before config gets applied slows down the feedback.

Choose your tools wisely.

# Summary

In this post we have seen how `gocd-cli` can be applied to validate configuration early.
It is a big move forward towards improving **feedback time** on configuration errors. The addition of token-based authentication is also helpful in implementing secure validation routines.

The `gocd-cli` is in early development stage, but sufficient to boost productivity already.

In the near term it would be nice to add a few usability improvements:

 * start releasing `gocd-cli` binaries
 * shorten the [long CLI commands](https://github.com/gocd-contrib/gocd-cli/issues/40)
 * make [environment variables unix friendly](https://github.com/gocd-contrib/gocd-cli/issues/39) in the gocd-cli
 * improve error messages in the [yaml plugin by adding schema validation](https://github.com/tomzo/gocd-yaml-config-plugin/issues/113)

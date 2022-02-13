+++
date = "2022-02-143"
title = "TODO"
description = "TODO"
images = []
math = "false"
series = []
author = "Ewa Czechowska"
+++

We wrote this post because of the recent [update to the Docker Desktop terms](https://docs.docker.com/desktop/). [Dojo](https://github.com/kudulab/dojo/), a CLI tool that we wrote, uses Docker and Docker-Compose. In this post, we'd like to help you continue using Dojo while staying compliant with the licenses. The proposed solution focuses on [Colima](https://github.com/abiosoft/colima).

Disclaimer: this is not a legal advice. The information is presented best to our knowledge. 

## Does this situation concern you?

Firstly, **if you use Docker on Linux, this situation does not concern you** (see: [source](https://www.docker.com/blog/looking-for-a-docker-alternative-consider-this/)). Although, it might be useful to know that there are plans to build Docker Desktop for Linux. More details available at [https://www.docker.com/blog](https://www.docker.com/blog/accelerating-new-features-in-docker-desktop/). However, if you use **Mac or Windows**, it's possible that you're using Docker Desktop.

Secondly, the official [Docker Desktop](https://www.docker.com/products/docker-desktop) website informs that
> It remains free for small businesses (fewer than 250 employees AND less than $10 million in annual revenue), personal use, education, and non-commercial open source projects

So, if your **type of usage** does not fall into the above range, it's possible that this situation concerns you.

## What is Docker Desktop?

This paragraph from [Docker Docs](https://docs.docker.com/desktop/) summarises it best what Docker Desktop is:
> Docker Desktop is an easy-to-install application for your Mac or Windows environment that enables you to build and share containerized applications and microservices. Docker Desktop includes Docker Engine, Docker CLI client, Docker Compose, Docker Content Trust, Kubernetes, and Credential Helper.

## How to handle this situation?

There are several options to handle this situation:
* you or your company may have invested in a paid subscription or have a license agreement to continue using Docker Desktop
* you may consider using Docker Desktop alternatives

We are not recommending one option over another. However, to make Dojo usable by more people and to cover more use cases, we're describing here how you can use Dojo with Docker Desktop alternatives.

## Docker Desktop alternatives

You may want to investigate [Considerations for Evaluating
Docker Desktop Alternatives](https://www.docker.com/products/docker-desktop/alternatives). One of them would be to decide which Docker Desktop features you really need. For Dojo use cases we care about:
* Docker Engine
* Docker Client
* Docker-Compose

There are several alternatives for Docker Desktop, such as:
* Podman
* minikube
* containerd
* Lima
* Colima (Colima uses Lima)

## Dojo + Colima

[Colima](https://github.com/abiosoft/colima) is an opensource project available on GitHub, described as:
> Container runtimes on macOS (and Linux) with minimal setup.

If all you’re doing is running Docker CLI on your desktop and occasionally mount a volume, then Colima is sufficient for your needs. It is also enough to work with Dojo.

Please use Dojo 0.10.4, as it fixes a small bug that occurs when using Colima.

### Set up for Mac OS
1. **Uninstall Docker Desktop**. You can follow [the official instructions](https://docs.docker.com/desktop/mac/install/#uninstall-docker-desktop) or just delete it via Finder in Applications
2. **Install Docker Client**
	* You can just run:
	```
	brew install docker
	```
	* Verify that Docker is installed
	```
	$ docker version
	Client: Docker Engine - Community
	 Version:           20.10.12
	 API version:       1.41
	 Go version:        go1.17.5
	 Git commit:        e91ed5707e
	 Built:             Sun Dec 12 06:28:24 2021
	 OS/Arch:           darwin/amd64
	 Context:           default
	 Experimental:      true
	Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
	```

3. **Install Docker-Compose**
	* You can just run:
	```
	brew install docker-compose
	```
	* OR you can download the Darwin x86 binary from https://github.com/docker/compose/releases, move the file to `/usr/local/bin` and rename it to `docker-compose`
	* Verify that Docker-Compose is installed
	```
	$ docker-compose version
	Docker Compose version 2.2.3
	```
4. **Install Colima**
	* Please install version which is at least `0.3.2`. You can do it with `brew` or using [other methods](https://github.com/abiosoft/colima/blob/main/INSTALL.md). The following will also install the Colima dependencies such as `lima`.
	```
	brew install colima
	```
	* Verify that Colima is installed
	```
	$ colima version
	colima version v0.3.2
	```
5. **Start Colima**
	* if you had a previous Colima version installed, please run
	```
	colima delete # delete existing instance
	colima start
	```
	* otherwise, just run
	```
	colima start
	```
6. **Verify** that you can use Docker containers, e.g. by
```
docker run -ti alpine:3.15 sh
```

This setup should be enough to use Dojo with Colima. You may want to visit [Colima readme](https://github.com/abiosoft/colima#customizing-the-vm) if you need more power allocated to the VM created by Colima.

## Notes about installing Docker on Mac
* The following command would install Docker Desktop ([source](https://formulae.brew.sh/cask/docker))
```
brew install --cask docker
```
* Installing Docker without Docker Desktop or Docker-Machine or Lima. This alone will simply not work, as explained [here](https://www.cprime.com/resources/blog/docker-for-mac-with-homebrew-a-step-by-step-tutorial/) and [here](https://medium.com/crowdbotics/a-complete-one-by-one-guide-to-install-docker-on-your-mac-os-using-homebrew-e818eb4cfc3).
```
brew install docker
```


troubleshooting
TODO: Tom should we copy your info?

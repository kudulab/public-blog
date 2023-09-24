+++
date = "2023-09-19"
title = "Terraform license updated to Business Source License (BSL)"
description = "A quick guide on how to navigate the situation of Terraform having a new license"
images = []
math = "false"
series = []
author = "Ava"
+++

You may have noticed the recent changes around Terraform licensing. This post explains the current situation and who is affected.

## The one-git-commit change

It all started with [this git commit](https://github.com/hashicorp/terraform/commit/b145fbcaadf0fa7d0e7040eac641d9aef2a26433) on 11th August 2023.

![The git commit with the Terraform license change](/images/2023-1-commit.png)

This commit changed the license of Terraform from MPL (Mozilla Public License) to BSL (Business Source License). What does it mean?

## The consequences

There are many consequences of that license change. Some Terraform users will not be affected:

* The license change is not retroactive. This means all source code and releases prior to the change remain under the MPL 2.0 license.
* You can still use Terraform in non-production environments. All non-production use of BSL licensed HashiCorp products is permitted.
* If you are a consultant, you can still help your clients with their own use of BSL licensed HashiCorp products for their production environment.

The main difference is that organizations providing competitive offerings to HashiCorp will no longer be permitted to use the community edition products free of charge under the BSL license.

Read more at https://www.hashicorp.com/license-faq and https://www.hashicorp.com/blog/hashicorp-adopts-business-source-license.


## OpenTofu Manifesto and the open-source Terraform fork

*Update 23.09.2023: The manifesto was originally called OpenTF Manifesto and the Terraform fork - OpenTF. Both were then renamed to OpenTofu and placed under the oversight of The Linux Foundation. Read more [here](https://www.theregister.com/2023/09/20/terraform_fork_opentf_opentofu/).*

The license change has lead to the creation of the [OpenTofu Manifesto](https://opentofu.org/manifesto). The manifesto's "goal is to ensure Terraform remains truly open source and proposes returning it to a fully open license". The main plan is to convince HashiCorp to switch Terraform back to an open-source license. And there is a fallback plan. If HashiCorp is unwilling to switch back, OpenTF Manifesto proposes to fork the legacy MPL-licensed Terraform and maintain the fork in the foundation. The fork was already created and is available on GitHub at [OpenTofu](https://github.com/opentofu/opentofu/).

OpenTofu is a fork of Terraform and is licensed under Mozilla Public License v2.0 (which is the same license as Terraform was using until the 11th August 2023 git commit).

Read more at https://opentofu.org or take a look at the strong principles proposed by OpenTofu:

![OpenTofu Principles](/images/2023-1-opentf-principles.png)


## Conclusion

While we, as many others, are tremendously grateful to HashiCorp for Terraform and for many other tools, it's hard to not acknowledge the community contributions - raising GitHub issues, creating Pull Requests, supporting so many Terraform providers, modules, and hundreds of related tools (linters, security scanners, test frameworks). Therefore, the major concern, arisen from this rapid Terraform license change, is the **risk of the fracture of the community**. Terraform was under the MPL license for around 9 years and has become one of the most popular Infrastructure as Code tools. Now, it will be not so straightforward where to contribute and whether your proposed contribution does not break the BSL license.

Secondly, the **BSL terms are quite vague** - it's not fully transparent what "competitive with HashiCorp" means and the [HashiCorp license FAQ](https://www.hashicorp.com/license-fa) suggests that you should write them an email to confirm that. The problem of this solution is that the decision may be different on a specific case and dependent on the circumstances and factors unknown to the public.

There are **many similar stories** that come to mind. Let's take [Hudson](https://en.wikipedia.org/wiki/Hudson_(software)) as one example. Hudson was a Continuous Integration tool. Then, Hudson was trademarked and this has lead to the creation of an open-source fork of Hudson. (There is a dispute on which one was fork of which). That fork is [Jenkins](https://en.wikipedia.org/wiki/Jenkins_(software)), which continues to be a widely-known and used CI tool, while Hudson is rarely mentioned anymore. Another interesting story about handling a similar problem in a different way is about [Docker and Moby](https://thenewstack.io/what-is-the-moby-project/).

Time will tell whether the OpenTofu manifesto succeeds and Terraform becomes back again open-source, or whether we will need to embrace the new reality after the warm 9 years.

![Google search result of Jenkins CICD](/images/2023-1-jenkins.png)

![Google search result of Hudson CICD](/images/2023-1-hudson.png)


Related articles:

* https://blog.gruntwork.io/the-future-of-terraform-must-be-open-ab0b9ba65bca
* https://www.forbes.com/sites/rscottraynovich/2023/08/17/hashicorp-licensing-firestorm-fuels-open-source-debate/?sh=25c16c3023fc

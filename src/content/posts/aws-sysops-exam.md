+++
date = "2019-10-06"
title = "Getting AWS SysOps Administrator certified"
description = "My recommendations for learning AWS and passing the SysOps Admin exam"
math = "false"
series = []
author = "Tomasz Sętkowski"
+++

In July 2019, I've passed the [AWS Certified SysOps Administrator - Associate](https://www.certmetrics.com/amazon/public/badge.aspx?i=3&t=c&d=2019-07-17&ci=AWS00888387). I decided to share my experiences leading to it, because while there is a lot of resources for learning AWS, choosing the time-efficient ones requires some extra effort. While I am not an expert in AWS (with just one certificate), my learning path was quite smooth. I learned a lot in a short time, then passed the exam with a high score of `973/1000`, which is what many people could aim for. I will briefly explain my approach and resources I used so that you can also enjoy your path to AWS certificate.

### SysOps as the first exam

If you are new to the AWS certifications, often the first question is which exam should you take?
All over the Internet you'll find people recommending going for the Architect Associate exam as your first one rather than SysOps Administrator because apparently Architect Associate is easier. I decided to go for the harder one to stand out. Given that I scored high, this is a confirmation that **it is perfectly doable to pass SysOps as your first exam**. The approach I took involved studying for Architect exam and getting high scores (~90%) on preparation exams, and only then moving further to SysOps materials.

## Study Roadmap

This is a detailed record of how much time I've spent on learning AWS before attempting the exam:

Assuming **1 day = 8 hours**.

1. **3 days** of learning basics and studying high-level overview of all AWS services. For me this implied transfer of knowledge from OpenStack to AWS. If you are totally new to the cloud, then it might take longer.
1. **2 months** of working with AWS. Personal projects, contributions to relevant open source. I didn't use any courses or tutorial at this stage. Just searched for needed services as I was building the infrastructure.
1. **8 days** of courses designed for AWS Architect Associate certificate.
1. **3 days** of practice exams and studying my answers (especially the wrong ones).
1. **6 days** of courses designed for SysOps exam.
1. **5 days** of practice exams for AWS SysOps Associate certificate.

## Resources

### Practical experience

Getting a grasp how to solve actual problems with AWS cloud is probably the best learning experience. I think that only by writing code and deploying actual projects you can gain **and keep** the relevant knowledge. For me, this meant migrating some services from OpenStack to AWS. So, I could immediately map concepts from one cloud to another. I am fortunate enough to have lots of projects and open source work to keep me busy.
However, if you don't have your own projects, you can help someone else build their infrastructure or contribute in open source space.

### Courses

Here are the courses that I have completed and my impression of them:

1. [A Cloud Guru - AWS Certification Preparation Guide](https://acloud.guru/learn/aws-certification-preparation). Introduction to AWS certifications and some study tips. If you know absolutely nothing about AWS certifications then it's worth watching. If you don't have much time, I'd consider skipping it.
1. [A Cloud Guru - AWS Certified Solutions Architect Associate 2019](https://acloud.guru/learn/aws-certified-solutions-architect-associate). I found it very useful, it touches a lot of subjects on the certificate. This is a great way to start you up on learning AWS in detail. **BUT** do no expect this to prepare you for the exam. There is way too little information in the course and you'll need to study more anyway.
1. [A Cloud Guru - AWS Certified SysOps Administrator - Associate 2019](https://acloud.guru/learn/aws-certified-sysops-administrator-associate-2019). The official description says that you should already know the content from the Solutions Architect course. It would have been great if this course actually added a layer on top of the previous one. Unfortunately, it repeats a lot of information and adds only a few new concepts. In conclusion, I would not recommend it, rather than this, jump straight to the next one -
1. [Udemy, Stephane Maarek - Ultimate AWS Certified SysOps Administrator Associate 2019](https://www.udemy.com/course/ultimate-aws-certified-sysops-administrator-associate/?couponCode=JPTDSC10). This is probably the best SysOps course out there. It does go in detail into topics which are covered on the exam. It does not waste your time by repeating basics from Solutions Architect materials.

### Practice exams

Practice exams are not just about scoring yourself to see if you'll pass. A good set of tests will provide a long explanation to each question and links to documentation where you can read more about it.

1. [A Cloud Guru exam simulator](https://acloud.guru/exam-simulator). I had a mixed experience:
   - **Solutions Architect Associate** exam questions are worth trying. Their difficulty is medium. I scored 70-80% on first attempts. So this did give me some feedback on areas to work on. I think its worth to attempt this a few times until you score 90%.
   - **SysOps Administrator Associate** exam questions are way too easy and the database is quite small. As a result, I scored over 90% on my first attempt. Moreover, the way that ACG simulator works often results in answering a question which you might have already seen in previous session. As a result, you spend time on answering easy questions which you have seen before. Not very effective and not much to learn there.
1. [Udemy, Jon Bonso - AWS Certified SysOps Administrator Associate Practice Exams](https://www.udemy.com/course/aws-certified-sysops-administrator-associate-practice-exams-soa-c01/). Because I felt under-prepared after ACG exams, I searched for other exam sources. Many people indicated that Jon Bonso's course is hard and has detailed explanations for each question. I can confirm that it is harder than the actual exam and you can learn a lot from the extra resources provided in each answer. There are 5 tests with unique questions. I have scored 69%, 78%, 87%, 92%, 76% few days before the actual exam where I scored 98%. If you agree with philosophy of over-preparing then definitely use this exam set.

### Notes

I've produced many pages of markdown notes from all resources that I used. I definitely recommend to **write down the critical things that you hear or read** while learning. On the day of my exam, I had 2 hours in train and in waiting room before the exam. I read all I had written before. It was very useful and I keep coming back to these notes today.

## Final words

I've never been a fan of certifications. I prefer hands-on experience with real-world problems to solve, bugs to debug and infrastructure to be built. Why I bothered with getting the certificate? First, I was looking to shift my career, from OpenStack environment to AWS. Getting certified gets the hiring process a bit easier for both sides. Certificate is a clear indication that I actually know the cloud that I am supposed to operate on. Second, I found the knowledge that I gained to be extremely useful on practical part of job interviews. In the end, I am glad I went through the process. If you are thinking about working on AWS, then going through the path I described above is probably a good choice.

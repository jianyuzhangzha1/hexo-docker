---
title: "Zero Trust Is Not a Better VPN: What Telecom Networks Teach Us About AI Infrastructure Security"
date: 2025-07-09 09:00:00
tags:
  - AI
  - Zero Trust
  - Security
  - 6G
  - AI-RAN
  - Agent
categories:
  - Tech Insights
index_img: /images/2025/ai-ran-6g/ep01/ep01-linkedin-cover-zero-trust-ai-infra.png
banner_img: /images/2025/ai-ran-6g/ep01/ep01-linkedin-cover-zero-trust-ai-infra.png
---

Zero Trust is not a stronger VPN. It is a dynamic security mechanism, and it works best where users, devices, applications, agents, and access contexts keep changing.

That distinction matters.

It matters for telecom networks.
It matters for cloud platforms.
And it matters even more for AI infrastructure.

Over the past few years, Zero Trust has become one of those terms that everyone uses, but not everyone uses in the same way. In many projects, it is treated as a VPN replacement. In some enterprise IT discussions, it becomes a new access gateway. In AI security discussions, it is now being extended to LLM applications and autonomous agents.

All of these views are partially right.

But they miss the key engineering question:

<!-- more -->

Where should Zero Trust be applied, and where should it not be forced into the main production path?

My view is simple:

Zero Trust is highly valuable for application access, management systems, cloud workloads, and AI agents. But for carrier-grade infrastructure, especially high-throughput forwarding planes, traditional security domains, isolation, hardware trust, and low-intrusion encryption still have a critical role.

The future is not "Zero Trust everywhere."

The future is layered security by system function.

## 1. What Zero Trust Really Means

Zero Trust is often summarized by three principles:

- Verify explicitly.
- Use least privilege.
- Assume breach.

These principles are clear.
They are also practical.

At its core, Zero Trust is not against networks. It is against implicit trust.

The old model was simple:

```text
User
  -> VPN
  -> Internal network
  -> Application
```

Once a user entered the internal network, the system often assumed a broad level of trust. That was acceptable when employees, applications, terminals, and data were mostly inside a stable perimeter.

That world has changed.

Today:

- Users move.
- Devices change.
- Applications run in the cloud.
- Contractors need access.
- APIs call APIs.
- AI agents trigger actions.
- Data flows across many systems.

So the security question has changed.

```text
Old question:
  Are you inside the network?

New question:
  Who are you?
  Is your device trustworthy?
  What resource are you accessing?
  Why are you accessing it?
  What is the current risk?
  What is the minimum permission needed?
  Can the permission be revoked immediately?
```

That is the real meaning of Zero Trust.

It is a continuous access decision model based on identity, device posture, context, behavior, and resource sensitivity.

But every decision has a cost.

Every policy check consumes time.
Every log consumes storage.
Every proxy adds a path.
Every context evaluation adds complexity.

So Zero Trust must be placed carefully.

## 2. How I Learned Zero Trust in Real Projects

My understanding of Zero Trust did not start from a white paper.

It started from projects.

In recent years, I have worked on several Zero Trust access projects for telecom operators and government-enterprise customers. The most common scenario was very practical:

Replace VPN access.

The systems were usually:

- Internal operation and maintenance systems.
- OA and office applications.
- Remote access for contractors.
- Enterprise customer mobile office platforms.
- Provincial operator systems in regions such as Zhejiang and Shanghai.

The business goals were not abstract.

Customers wanted to:

- Reduce the exposed attack surface.
- Hide service ports with SPA.
- Avoid broad internal network access.
- Apply fine-grained access control.
- Record detailed access logs.
- Manage temporary users and contractors.
- Replace the "enter the intranet first" model.

This is where Zero Trust works extremely well.

It changes the access model from:

```text
Enter the network first.
Then find the application.
```

to:

```text
Authenticate identity.
Check device and context.
Authorize only one application.
Authorize only one action if needed.
Record the full access trail.
```

For enterprise IT and operator management systems, this is a major improvement.

The exposure surface becomes smaller.
Permissions become more precise.
Logs become more useful.
Risk becomes easier to trace.

But the more projects I worked on, the more I realized another truth:

Zero Trust is not free.

Fine-grained policy is expensive to model.
Full logging is expensive to store.
Deep proxying is sensitive to performance.
Context evaluation increases operational complexity.
User experience must be tuned carefully.

That is why Zero Trust should not be blindly inserted into every layer of every system.

## 3. A 2018 Discussion That Shaped My Thinking

In 2018, I had a dedicated discussion with Dr. Zhiyuan Hu, a network expert from Bell, on whether Zero Trust could be applied to 5G networks.

Her judgment was direct:

It can work on the management plane.
The forwarding plane will not tolerate the performance cost.

That sentence stayed with me.

It separated the problem into two very different domains.

For the management plane, Zero Trust is a strong fit.

It can answer:

- Who can log in?
- Who can operate?
- Who approved the action?
- Which command was executed?
- Which system was accessed?
- Which log proves it?

For the forwarding plane, the requirements are completely different.

The forwarding plane needs:

- High throughput.
- Low latency.
- Low jitter.
- Minimal state.
- Minimal interruption.
- Minimal dependency in the traffic path.

If we place heavy proxies, frequent dynamic authorization, and complex context evaluation into a Tbps-level user-plane path, we create a bottleneck.

This is not a philosophical objection.

It is an engineering constraint.

That is also why, in real telecom projects, the practical landing points were usually management systems, OA systems, remote O&M, application access, VPN replacement, SPA-based port hiding, and detailed access auditing.

These are application and management-plane problems.

They are not high-throughput forwarding-plane problems.

## 4. What Microsoft, AWS, and ATIS Got Right

Microsoft, AWS, and ATIS represent three useful patterns for Zero Trust.

They are different.
But they share one common idea:

Find the right control point.

### Microsoft: Zero Trust as an enterprise security foundation

Microsoft's Zero Trust model is highly suitable for enterprise IT.

It brings together identity, devices, applications, data, networks, and security operations.

The success factor is not simply "strong authentication."

The success factor is the integration of identity, conditional access, endpoint signals, application control, and audit.

This is why the Microsoft model works well for modern enterprises:

- Employees are mobile.
- Applications are distributed.
- Devices are diverse.
- Data is no longer only on-premises.
- Attackers may already be inside.

This model aligns well with what I have seen in government-enterprise projects.

The highest value comes from replacing VPN, reducing exposure, and controlling application access based on context.

### AWS: Zero Trust as application-level access

AWS Verified Access is another clear pattern.

Its positioning is very direct:

- No VPN is required.
- Each application request is evaluated.
- Access is granted only when security requirements are met.
- Logs are centralized for audit and troubleshooting.

The key point is this:

Users do not enter the whole VPC.

They access specific applications.

```text
User
  -> Identity and device signals
  -> Verified Access policy
  -> Application A / Application B / Application C
  -> Logs and audit trail
```

This is a strong cloud-era Zero Trust pattern.

Again, the landing point is application access, not full network penetration.

### ATIS: Zero Trust adapted to telecom production networks

ATIS is more interesting for telecom operators.

It faces 5G, Open RAN, telecom cloud, and carrier-grade production networks.

Here, we cannot simply copy enterprise IT practices.

Telecom production networks have hard constraints:

- High throughput.
- Low latency.
- High reliability.
- Multi-vendor interoperability.
- Strict operational continuity.

ATIS does not overthrow 3GPP.

It is better understood as injecting Zero Trust operating principles into the existing 3GPP security toolbox.

```text
3GPP provides the security toolbox:
  - SBA security
  - TLS / mTLS
  - OAuth 2.0
  - Network domain security
  - Certificates and key mechanisms

ATIS provides the operational playbook:
  - Continuous evaluation
  - Closed-loop telemetry
  - Dynamic policy
  - Cloud-network-hardware correlation
  - Open RAN multi-vendor trust chain
```

The most important lesson from ATIS is architectural restraint.

Do not pull all traffic into a heavy Zero Trust gateway.

Separate the main path from the observation and control paths.

```text
Main path:
  Lightweight authentication
  Low-intrusion encryption
  Do not block normal production traffic

Side path:
  Telemetry analysis
  Risk scoring
  Behavior baseline
  Asynchronous response
  Dynamic downgrade or revocation
```

This is the telecom-grade way to think about Zero Trust.

It is not "apply everything everywhere."

It is "apply the right control at the right layer."

![Layered security model for telecom and AI infrastructure](/images/2025/ai-ran-6g/ep01/ep01-linkedin-middle-layered-security.png)

## 5. Why GenAI and Agents Bring Zero Trust Back

Now AI changes the problem again.

GenAI applications and AI agents create a new type of dynamic participant.

An agent is not just a user interface.

It can:

- Read data.
- Call APIs.
- Use tools.
- Trigger workflows.
- Generate actions.
- Affect downstream systems.

That is why OWASP and IBM-style enterprise AI governance discussions increasingly connect GenAI security with Zero Trust ideas.

Many LLM and agent risks are access-control problems in a new form:

- Prompt injection.
- Sensitive information disclosure.
- Insecure plugin or tool design.
- Excessive agency.
- Model and data leakage.
- Supply-chain risk.

The model is not only answering questions.

It may be acting on behalf of a user.

So we must ask:

```text
Who is the agent?
Who owns the task?
Which tools can it call?
Which data can it read?
Which action requires approval?
Which context is trusted?
Which behavior must be logged?
Which permission can be revoked?
```

This is why Zero Trust fits AI agents.

Not as a buzzword.

As an access-control model.

For AI agents, we need at least four capabilities.

First, agent identity.

An agent should not be only a shadow of a user account. It should have its own identity, scope, owner, task, valid duration, tool permissions, and risk level.

Second, tool-level authorization.

The dangerous part of an agent is not text generation. The dangerous part is tool use.

Can it query a database?
Can it send an email?
Can it modify a configuration?
Can it execute a script?
Can it call a production API?

These permissions must be explicit.

Third, continuous context evaluation.

The same agent may be low-risk in one context and high-risk in another.

Summarizing a public document is one thing.
Changing a production configuration is another.

Fourth, causal-chain audit.

For agents, logging the final output is not enough.

We need to know:

- Who initiated the task.
- What plan the agent generated.
- Which tools were called.
- Which data was read.
- Which system was changed.
- Which step was denied.
- Which step required human approval.

This is the foundation of agent security.

## 6. What Is Still Missing

We should not be too optimistic.

Zero Trust can help secure GenAI and agents, but the architecture is still immature.

Several gaps remain.

Agent identity is not yet standardized enough.

Humans have accounts.
Machines have certificates.
What exactly should agents have?

Tool permission models are still immature.

Prompt instructions are not a security boundary. Tool authorization must be enforced outside the model.

Context trust is difficult.

Agents may read poisoned content. Prompt injection is essentially a context-trust problem.

Decision chains must become explainable.

When an agent takes a risky action, we cannot accept "the model thought it was fine" as an explanation.

Policy enforcement must be high performance.

Agents operate at machine speed. Security decisions must keep up.

Otherwise, we either block the business or accept uncontrolled risk.

## 7. My Conclusion: Two Security Paradigms, Not One

My conclusion is straightforward.

Zero Trust will become an important security foundation for AI infrastructure.

But it is not a universal medicine.

It should not be forced end-to-end into every infrastructure path.

Infrastructure security and application security should be treated as two different paradigms.

Infrastructure security is better served by:

- Security domains.
- Isolation.
- Segmentation.
- Network domain security.
- Hardware trust.
- Management-plane separation.
- Low-intrusion encryption.

Application and agent security are better served by:

- Zero Trust access.
- Identity governance.
- SPA.
- ZTNA.
- Fine-grained authorization.
- Behavior audit.
- Agent identity.
- Tool-level permission control.

They are not substitutes.

They are complementary.

```text
AI infrastructure security
  |
  +-- Infrastructure security paradigm
  |     -> Security domains
  |     -> Isolation
  |     -> Hardware trust
  |     -> Low-intrusion encryption
  |
  +-- Application security paradigm
  |     -> ZTNA
  |     -> SPA
  |     -> Fine-grained authorization
  |     -> Access audit
  |
  +-- Agent security paradigm
        -> Agent identity
        -> Tool authorization
        -> Context evaluation
        -> Causal-chain audit
```

This is also the lesson telecom networks can offer to AI infrastructure.

Do not confuse security ambition with architectural correctness.

Zero Trust is powerful because it is dynamic.

But dynamic judgment has a cost.

The real design challenge is not whether to use Zero Trust.

The real challenge is where to use it, how deep to place it, and how to avoid turning security itself into the next performance bottleneck.

That is the discussion AI infrastructure now urgently needs.

![Right control point for Zero Trust in AI infrastructure](/images/2025/ai-ran-6g/ep01/ep01-linkedin-ending-control-point.png)

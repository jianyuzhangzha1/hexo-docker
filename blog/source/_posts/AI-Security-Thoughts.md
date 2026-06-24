---
title: Deepthinking LLM Security
date: 2026-04-14 22:29:20
tags:
    - AI
    - Security
    - 2026
    - OWASP
    - LLM
categories:
    - Tech Insights
---

### -- What’s New, Amplified, and Diminished

Large Language Models (LLMs) are often discussed as a disruptive force in AI, but from a security engineering perspective, a more pragmatic framing is useful: **an LLM system is still an IT system—just one with a probabilistic core and a natural language interface**.

From a threat perspective, the important question is not whether an LLM can reason like a human, but how an attacker can steer its inputs, context, tools, and outputs across system boundaries.

This shift in interface and execution model fundamentally reshapes the threat landscape. Rather than introducing entirely foreign risks, LLMs **reconfigure existing security problems**, while also creating a small but critical set of **new attack surfaces**.

<!-- more -->

This article decomposes the risks outlined by OWASP LLM Top 10 into three categories:

* **LLM-specific risks (new)**
* **Amplified risks (existing but stronger)**
* **Diminished or transformed risks**


|No| OWASP LLM | Application vulurnability | Traditional Binary expoit| Trend|
|-| ------- | ------- |------- |------- |
|1| Prompt Injection  | SQL Injection | Command Injection | new |
|2| Sensitive Information Disclosure| business data leakage | business data leakage |Amplified|
|3| Supply Chain Vulnerabilities  | component | library hijact |Amplified|
|4| Data and Model Poisoning  | N/A | N/A  |new|
|5| Improper Output Handling | N/A | N/A |new|
|6| Excessive Agency  | API abuse | N/A |new|
|7| System Prompt Leakage  | log or backup lost | log lost |Amplified|
|8| Vector and Embedding Weaknesses  | DoS | DoS |new|
|9| Misinformation  | N/A | N/A |new|
|10| Unbounded Consumption | DoS | DoS |Amplified|
|11| N/A |N/A |Classical Injection (SQLi, XXE) |Diminished|
|12| N/A |Classical Injection (SQLi, XXE)| N/A |Diminished|
|13| N/A |Authentication and Authorization Attacks | N/A |Diminished|

<br>

## 1. LLM-Specific Risks: A New Attack Surface

These risks emerge directly from the defining characteristics of LLMs:
**natural language input, probabilistic generation, and contextual reasoning**.

### 1.1 Prompt Injection: Semantic Exploitation

Prompt injection is often compared to SQL injection, but the analogy is superficial.

* SQL injection exploits **syntax parsing**
* Prompt injection exploits **semantic ambiguity**

There is no strict boundary between instructions and data in natural language. System prompts, user inputs, and tool instructions coexist in a shared context, making it possible for malicious inputs to override intended behavior.

**Key issue:** LLMs lack a hard separation between control plane and data plane.

<br>
<br>
<br>
<br>
<br>
<br>

In practice, prompt injection is rarely a single dramatic sentence. It is usually a layered manipulation:

* a benign-looking paragraph that hides a control instruction
* a retrieved document that contains adversarial text
* a tool output that is fed back into the next reasoning step
* a conversation history that slowly shifts the model's frame of reference

That is why prompt injection is best treated as a **workflow security problem**, not just a content moderation problem. The attack succeeds when the model, the retriever, and the tool chain all trust one another too much.

From an engineering perspective, this means the first line of defense is not "make the prompt smarter." It is to reduce how much authority a single piece of text can carry across system boundaries.

---

### 1.2 Context-Based Data Exfiltration

In traditional systems, data exfiltration typically involves direct access (e.g., querying a database). In LLM systems, leakage often occurs indirectly:

* System prompts revealed through manipulation
* Sensitive RAG data surfaced via crafted queries
* Memory or conversation history exposed unintentionally

This is **inference-time leakage**, not access-time leakage.

---

### 1.3 Training Data Poisoning

Unlike traditional code injection, poisoning attacks target the **model’s behavior** rather than execution flow.

Attack vectors include:

* Pretraining datasets
* Fine-tuning pipelines
* RAG ingestion sources

Outcomes:

* Bias injection
* Backdoor triggers
* Behavioral manipulation

---

### 1.4 Model Inversion & Membership Inference

These attacks attempt to infer whether specific data was part of the training set.

This is fundamentally different from traditional systems because:

* The model encodes statistical traces of training data
* Leakage occurs through **probabilistic reconstruction**, not direct access

---

## 2. Amplified Risks: The Same Problems, But Worse

LLMs act as **force multipliers** for several well-known security issues.

---

### 2.1 Insecure Output Handling

Traditional vulnerabilities like:

* Command injection
* Cross-site scripting (XSS)
* Remote code execution (RCE)

are now easier to exploit because:

* LLMs can generate attack payloads automatically
* Users no longer need deep technical expertise

The model becomes an **attack co-pilot**.

---

### 2.2 Supply Chain Risk

Modern LLM systems involve multiple layers:

* Base models
* Fine-tuned models
* Embedding models
* Prompt templates
* Plugins and tools

This creates a **multi-dimensional supply chain**, including a new category:

> **Prompt supply chain**

A compromised prompt or plugin can alter system behavior without modifying code.

---

### 2.3 Excessive Agency (Autonomous Execution Risk)

When LLMs are integrated with agents, they gain the ability to:

* Call APIs
* Execute workflows
* Modify system state

This transforms traditional misconfiguration risks into:

> **Automated, scalable misuse of privileges**

---

### 2.4 Sensitive Information Disclosure

LLMs do not just retrieve data—they:

* Summarize
* Infer
* Reconstruct

This increases the risk of:

* Indirect leakage
* Cross-context inference
* Aggregated exposure

---

### 2.5 Denial of Service (DoS)

LLM systems introduce a new cost model:

* Token-based billing
* Compute-intensive inference

Attackers can exploit this by:

* Forcing long context processing
* Triggering recursive agent loops
* Generating high-cost queries

---

## 3. Diminished or Transformed Risks

Some traditional vulnerabilities are less relevant—or have shifted form.

---

### 3.1 Memory Corruption Exploits

Classic issues like:

* Buffer overflows
* Use-after-free

are largely mitigated because:

* LLMs run in managed environments
* There is no direct memory manipulation

However, these risks reappear if:

* Tools execute native code
* Plugins interact with unsafe components

---

### 3.2 Classical Injection (SQLi, XXE)

LLMs do not directly parse structured query languages, so direct injection is less relevant.

However, a new pattern emerges:

> **Second-order injection**

Example:

* LLM generates SQL → downstream system executes it

---

### 3.3 Authentication and Authorization Attacks

The focus shifts from:

* Breaking login systems

to:

* Manipulating prompt boundaries
* Escalating tool permissions

Access control becomes **contextual and dynamic**, rather than static.

---

## 4. A Layered Security Model for LLM Systems

A useful abstraction is to treat LLM systems as a **five-layer architecture**:

### 4.1 Interface Layer

* Prompt injection
* Input validation

### 4.2 Context Layer

* RAG poisoning
* Data leakage

### 4.3 Model Layer

* Alignment issues
* Inference attacks

### 4.4 Tool / Agent Layer

* Privilege abuse
* Autonomous execution risks

### 4.5 Infrastructure Layer

* DoS
* Supply chain vulnerabilities

---

## 5. The Core Paradigm Shift

Traditional systems follow a deterministic pipeline:

> **Input → Parse → Execute**

LLM systems introduce two additional stages:

> **Input → Semantic Understanding → Probabilistic Generation → Interpretation → Execution**

This creates two fundamental challenges:

1. **Semantic ambiguity (non-verifiable intent)**
2. **Non-deterministic outputs (non-repeatable behavior)**

Security can no longer rely purely on static rules. It must incorporate:

* Probabilistic controls
* Runtime monitoring
* Behavioral constraints

---

## 6. Engineering Implications

From a practical standpoint, several design principles emerge:

### 6.1 Zero Trust for LLM Systems

* Treat prompts as untrusted input
* Treat model outputs as untrusted data
* Apply least privilege to all tool interactions

---

### 6.2 Control Plane vs Data Plane Separation

Strictly isolate:

* System instructions (control plane)
* User inputs (data plane)

This reduces the impact of prompt injection.

---

### 6.3 Output Security Gateway

Introduce a validation layer for model outputs:

* Schema enforcement
* Policy checks
* Content filtering

---

### 6.4 Fine-Grained Agent Authorization

Adopt RBAC-like controls for tools:

* Scoped permissions
* Rate limits
* Full auditability

---

## Conclusion

LLM security is not a replacement for traditional security—it is an extension of it.

What changes is not the existence of risk, but its **location and amplification**:

* From syntax to semantics
* From execution to generation
* From deterministic control to probabilistic governance

Understanding this shift is essential for building secure, production-grade AI systems.

In that sense, LLM security is less about inventing new defenses, and more about **re-applying first principles under a new computational paradigm**.

## References

1. OWASP, *OWASP Top 10 for Large Language Model Applications*.
2. Y. Liu et al., *Prompt Injection attack against LLM-integrated Applications*, arXiv:2306.05499, 2023.
3. X. Suo, *Signed-Prompt: A New Approach to Prevent Prompt Injection Attacks Against LLM-Integrated Applications*, arXiv:2401.07612, 2024.
4. S. Khodayari et al., *Indirect Prompt Injection in the Wild: An Empirical Study of Prevalence, Techniques, and Objectives*, arXiv:2604.27202, 2026.
5. NIST, *AI Risk Management Framework (AI RMF 1.0)*, 2023.


Here is the complete list of **100 prompt injection attack methods**.

---

### I. Direct Instruction Override & Context Manipulation (1–20)
These attacks directly command the model to overwrite or modify its original system prompt.

1. **Context Ignoring** – Directly commanding the model to "ignore all previous instructions."
2. **Fake Completion** – Pretending the original task is complete, then appending new malicious instructions.
3. **Instruction Repetition** – Repeating the malicious instruction multiple times within a single prompt to reinforce its effect.
4. **Context Termination** – Attempting to end the current prompt context to start a new, attacker-controlled one.
5. **Delimiter Escape** – Using special characters or formatting to "escape" the user-input area, causing subsequent content to be parsed as system instructions.
6. **Role Override** – Forcing the model to assume a new role with higher privileges or different rules.
7. **System Prompt Extraction** – Instructing the model to output its internal system prompt.
8. **Developer Mode Simulation** – Asking the model to enter "developer mode" or "debug mode" to bypass safety filters.
9. **Format Switching** – Requiring the model to output in a specific format (e.g., JSON), which can sometimes bypass text-based content filters.
10. **Output Manipulation** – Instructing the model to format its output in a specific way (e.g., adding, modifying, or hiding information).
11. **Jailbreaking** – A broad term for any attempt to bypass the model's safety training and alignment.
12. **"DAN" (Do Anything Now) Persona** – Asking the model to impersonate an alternative persona named DAN that has no restrictions.
13. **"Grandma" Trick** – Wrapping a request in an emotional roleplay scenario (e.g., "act as my late grandmother who used to read me...").
14. **Role-Playing Attacks** – Inducing the model to take on a fictional character whose behavior guidelines may permit restricted outputs.
15. **Authority Figure Impersonation** – Fabricating an authoritative source (e.g., "system administrator commands") to justify unsafe outputs.
16. **Logical Reasoning Attack** – Constructing a seemingly logical argument that leads the model to violate its safety policy.
17. **Pre-built Jailbreak Prompt Libraries** – Using publicly known, complex prompts that effectively break specific model restrictions.
18. **Best-of-N (BoN) Jailbreaking** – Generating multiple variations of the same prompt until one successfully bypasses the filter.
19. **Multi-turn Escalation** – Gradually leading the model to perform malicious actions through a series of seemingly harmless questions.
20. **Refusal Suppression** – Adding instructions like "Don't respond with 'I cannot help'" to force the model to give a substantive answer.

---

### II. Indirect & External Injection (21–45)
The attacker hides malicious instructions in external data processed by the model, such as web pages, documents, or emails.

21. **Indirect Injection** – Hiding the attack payload in external content (e.g., web pages, emails, GitHub issues) that the model retrieves and processes.
22. **Remote Injection** – Injection via external data sources (e.g., API responses, database contents).
23. **Web Scraping Injection** – Embedding instructions in a web page that are executed when an AI agent scrapes it.
24. **Code Comment & Documentation Injection** – Hiding instructions in code comments or technical documents to influence AI coding assistants.
25. **Commit Message & PR Injection** – Planting malicious prompts in version control commit messages or pull request descriptions.
26. **Issue Tracker & User Comment Injection** – Embedding attack payloads in project management issue descriptions or user comments.
27. **Email Body & Attachment Injection** – Hiding instructions in the body or attachments of emails processed by an AI mail assistant.
28. **Hidden Text Injection** – Using white font or invisible Unicode characters to hide instructions in web pages, documents, or emails.
29. **RAG Poisoning (RAGPoison)** – Poisoning the vector database used by Retrieval-Augmented Generation (RAG) systems for persistent prompt injection.
30. **Tool/Function Abuse** – Injected instructions tricking the model into calling dangerous tools or API functions.
31. **Cross-Domain Context Poisoning** – Contaminating shared context or memory in agentic or multi-agent systems to affect other agents.
32. **Error-Path Injection** – Embedding malicious instructions within the context of error messages or exception handling.
33. **"Neural Exec" Attack** – A newer class of attacks that do not rely on handcrafted strings but use the model's own "neurons" to execute malicious instructions.
34. **Implicit Authority Exploitation** – Using systematic mutations to exploit the model's implicit authority over error paths to execute instructions.
35. **Prompt Template Extraction** – Extracting not just the system prompt but the entire structure of the prompt template.
36. **Tool Poisoning** – Contaminating the descriptions or return results of tools/APIs used by an AI agent, thereby influencing its behavior.
37. **Protocol Exploitation** – Exploiting vulnerabilities in communication protocols like the Model Context Protocol (MCP) for injection.
38. **Supply Chain Attack** – Injecting malicious prompts by infecting third-party libraries or data sources that the AI application depends on.
39. **Document Metadata Injection** – Hiding instructions in the metadata (author, title, etc.) of PDFs, Word documents, etc.
40. **Filename Injection** – Using maliciously crafted filenames that trigger injection when the AI processes a file list.
41. **Database Content Injection** – Planting prompts in database records that activate when queried and processed by the AI.
42. **Cache Poisoning** – Contaminating the AI application's cache so that subsequent requests return poisoned responses.
43. **Log File Injection** – Writing malicious instructions into application logs, waiting for an AI log-analysis tool to process them.
44. **Configuration File Injection** – Modifying configuration files read by the AI application to inject new instructions or alter behavior.
45. **Environment Variable Injection** – Manipulating environment variables to affect the AI application's prompt construction process.

---

### III. Encoding, Obfuscation & Tokenizer Attacks (46–70)
Changing the representation of malicious instructions to evade text-based filters.

46. **Base64 Encoding** – Base64-encoding the malicious instruction and asking the model to decode and execute it.
47. **Hexadecimal Encoding** – Using hexadecimal notation to hide instructions.
48. **Unicode Smuggling** – Using invisible or zero-width Unicode characters to hide instructions.
49. **Payload Splitting** – Breaking sensitive instruction words into multiple parts and reassembling them in the prompt.
50. **Token Smuggling** – Exploiting the model's tokenizer properties to encode malicious instructions in a form the model understands but filters cannot detect.
51. **Homoglyph Attack** – Using visually similar but different Unicode code points to spell instruction words, bypassing keyword blacklists.
52. **Typoglycemia Attack** – Keeping the first and last letters intact but scrambling the middle letters (e.g., "Iegnore") – humans can read it, and models may still understand.
53. **Markdown/HTML Rendering Hiding** – Using KaTeX/LaTeX rendering techniques to generate invisible text.
54. **Emoji & Special Character Encoding** – Replacing letters or words with emojis or special Unicode symbols.
55. **URL Encoding** – Percent-encoding the instruction (e.g., `%49%67%6E%6F%72%65`).
56. **Double Encoding** – Base64-encoding first, then URL-encoding, to bypass multi-layer filters.
57. **Case Alternation** – Using mixed case (e.g., `IgNoRe`) to bypass simple pattern matching.
58. **Synonym Substitution** – Replacing blocked keywords with synonyms (e.g., "disregard," "skip").
59. **Foreign Language / Multilingual** – Phrasing the instruction in a language the model understands but the filter does not (e.g., French, Spanish).
60. **Programming Language Syntax** – Disguising the injection as a query language statement (e.g., SQL, Splunk).
61. **Exploiting Format Preferences** – Placing the instruction in a format common in the model's training data (e.g., XML tags like `<instruction>`).
62. **Zero-Width Joiner Insertion** – Inserting zero-width characters within keywords to visually appear normal but break string matching.
63. **Control Character Injection** – Using newline (`\n`), carriage return (`\r`), tab (`\t`), etc., to break the prompt structure.
64. **Math Formulas & Symbols** – Using mathematical expressions (e.g., `∑`) instead of words and asking the model to "compute" the instruction.
65. **Reverse Word Order** – Writing instruction words backward (e.g., "erongi") and asking the model to reverse them before executing.
66. **Text-in-Image Injection** – In multimodal models, embedding instructions as text within an image (OCR).
67. **Audio Instruction Injection** – Embedding instructions in audio files in multimodal models.
68. **Leetspeak** – Replacing letters with numbers and symbols (e.g., `!gn0r3`).
69. **Morse Code** – Encoding the instruction in Morse code.
70. **Binary Representation** – Representing the instruction as a binary string.

---

### IV. Multimodal & Cross-Modal Attacks (71–79)
Exploiting the model's ability to process multiple input types (text, images, audio).

71. **Image Prompt Injection** – Embedding textual instructions in an image that activate when a multimodal model processes it.
72. **Audio Prompt Injection** – Embedding hidden voice instructions in audio files.
73. **Cross-Modal Confusion** – Injecting instructions in one modality (e.g., image) to influence output in another (e.g., text).
74. **Visual Jailbreaking** – Using specific visual patterns or adversarial images to trigger unintended model behavior.
75. **Video Frame Injection** – Embedding adversarial prompts across sequential video frames.
76. **Multi-turn Cross-Modal** – Alternating between text, image, and audio inputs across multiple turns to gradually bypass safeguards.
77. **OCR Poisoning** – Inserting hidden text into PDFs or screenshots that are processed via OCR, which is then interpreted as user instructions.
78. **Audio Adversarial Perturbations** – Adding imperceptible noise to audio that forces the model to misinterpret the spoken prompt as a command.
79. **Defined Dictionary Attack** – Defining a "dictionary" that maps safe instructions to malicious payloads, causing the model to execute the payload when it sees the mapped key.

---

### V. Training-Phase & Data Poisoning (80–84)
Injecting malicious data during the model's training or fine-tuning to trigger malicious behavior on specific triggers.

80. **Privacy Extraction** – Using crafted prompts to make the model "memorize" and output PII from its training data.
81. **Membership Inference Attack** – Determining whether a specific data record was part of the model's training set.
82. **Model Inversion Attack** – Attempting to reconstruct training data from the model's outputs.
83. **Data Exfiltration via Markdown Images** – Injected instructions make the model render a Markdown image whose URL carries stolen data (e.g., API keys).
84. **Exfiltration via Links** – Inducing the model to generate a response containing a link to an attacker-controlled server, passing sensitive data as URL parameters.

---

### VI. Agentic, Multi-Agent & System-Level Attacks (85–100)
Targeting complex AI systems, such as agents that can call tools or execute code.

85. **Agentic Attacks** – Attacks targeting AI agents, exploiting their perception, planning, and action capabilities.
86. **Multi-Agent Manipulation** – Manipulating one agent in a multi-agent system to influence the behavior of other agents.
87. **MCP (Model Context Protocol) Attacks** – Exploiting vulnerabilities in MCP for "tool poisoning" or "context hijacking."
88. **Tool Call Hijacking** – Injected instructions causing the agent to call an attacker-specified tool instead of the intended one.
89. **Code Execution Injection** – In AI code assistants, injecting instructions to generate and execute malicious code.
90. **Command Injection** – Similar to traditional command injection, using prompts to make the AI agent execute commands on the underlying OS.
91. **Context Window Overflow** – Providing extremely long input to fill the model's context window, potentially causing erratic behavior or instruction omission.
92. **Cross-Session Persistence Manipulation** – Injecting instructions that cause the model to remain manipulated across subsequent sessions (if stateful).
93. **Application Layer Attacks** – Exploiting vulnerabilities in the AI application itself (not the underlying model) for injection.
94. **Availability / DoS Attacks** – Injecting computationally intensive prompts to exhaust system resources (Denial of Service).
95. **Trust & Reliability Attacks** – Manipulating the model to output incorrect information, eroding user trust in the system.
96. **Chain-of-Thought (CoT) Manipulation** – Targeting reasoning models to manipulate their "chain of thought" process, leading them to incorrect or harmful conclusions.
97. **Social Engineering Attacks** – Using emotional appeals, urgency, or authority pressure within the prompt to psychologically coerce the model into complying.
98. **Context-Based Manipulation** – Altering the contextual information surrounding the main instruction to subtly influence the model's judgment.
99. **Formatting Tricks** – Using spacing, line breaks, and indentation to blur the line between user data and system instructions.
100. **Authority Roleplay (System/Admin)** – Posing as a system administrator, developer, or other high-privilege role to command the model to execute operations.

---

> **Disclaimer**: This list is provided strictly for security research and educational purposes. Unauthorized prompt injection attacks against AI systems are illegal and unethical. Understanding these techniques is essential for building robust defenses.

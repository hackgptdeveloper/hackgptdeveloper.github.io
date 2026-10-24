
A hash chain makes an audit log **tamper-evident**: it lets an auditor or forensic investigator detect whether recorded events have been altered, removed, inserted, or reordered—provided the chain is checked against a trusted reference that an attacker cannot also replace. Its purpose is to establish confidence in the integrity and sequence of recorded evidence, not to prevent someone from editing the underlying storage. [security.stackexchange](https://security.stackexchange.com/questions/4320/techniques-for-ensuring-verifiability-of-event-log-files)

## How it works

Instead of hashing each log entry independently, each entry’s hash incorporates the previous entry’s hash:

\[
h_0 = \text{a defined initial value}
\]

\[
h_i = H\bigl(h_{i-1}\,\|\,\operatorname{encode}(E_i)\bigr)
\]

Here, \(E_i\) is an event record, \(H\) is a cryptographic hash function such as SHA-256, and `encode` is an unambiguous serialization. This links every entry to the history before it. Verification recomputes the hashes and checks that the links match. [security.stackexchange](https://security.stackexchange.com/questions/4320/techniques-for-ensuring-verifiability-of-event-log-files)

For example:

```text
Event 1: Alice logs in
    h1 = H(h0 || event1)

Event 2: Alice grants Bob administrator privileges
    h2 = H(h1 || event2)

Event 3: Bob exports customer records
    h3 = H(h2 || event3)
```

Changing the privilege-grant event changes `h2`, which also changes the expected `h3`. Removing the second event likewise breaks the original linkage between the surrounding records. Independent hashes do not provide this same relationship between records; chaining binds their order as well as their contents. [security.stackexchange](https://security.stackexchange.com/questions/4320/techniques-for-ensuring-verifiability-of-event-log-files)

## What this gives an auditor or investigator

- Integrity checking: determine whether the supplied records still match the history committed to by a trusted checkpoint.
- Sequence verification: detect changes to the recorded ordering, including removal or insertion within the committed history.
- Forensic confidence: support an incident reconstruction with evidence that the underlying log has not been silently rewritten.
- Evidence-preservation checks: compare an acquired log against a previously preserved chain hash to detect subsequent changes. [security.stackexchange](https://security.stackexchange.com/questions/4320/techniques-for-ensuring-verifiability-of-event-log-files)

The distinction is between “these are the logs we currently have” and “these logs match a cryptographic commitment preserved independently before the investigation.” [security.stackexchange](https://security.stackexchange.com/questions/4320/techniques-for-ensuring-verifiability-of-event-log-files)

## The crucial limitation: an attacker can recompute the chain

A plain hash chain does not make rewriting history computationally infeasible. An attacker who can edit every record and every stored hash can change an event and simply recompute all subsequent hashes. The resulting chain will be internally consistent. An attacker can also remove the end of a chain without breaking its remaining internal links. [security.stackexchange](https://security.stackexchange.com/questions/4320/techniques-for-ensuring-verifiability-of-event-log-files)

Therefore, protect a checkpoint outside the attacker’s control—for example, periodically copy the latest chain hash and its record position to separate write-once storage. An investigator can then recompute the chain up to that position and compare it with the preserved checkpoint. The checkpoint protects the history through that position; later, unanchored records remain exposed. [security.stackexchange](https://security.stackexchange.com/questions/4320/techniques-for-ensuring-verifiability-of-event-log-files)

```text
Log server                         Independently protected storage
E1 → E2 → ... → E1000
                 h1000 ──────────► checkpoint: (1000, h1000)

Later verification:
recompute through E1000 → compare with the protected checkpoint
```

## What a hash chain does not prove

| Claim | What the chain actually establishes |
|---|---|
| “The logged event really happened.” | Integrity of recorded data does not establish that the logger recorded the truth. |
| “Every event was logged.” | Chaining cannot reveal an event omitted before it entered the log. |
| “This person created the record.” | Hashes alone do not authenticate the author; signatures provide a separate attribution mechanism. |
| “The timestamp is accurate.” | Protecting a timestamp from later alteration does not establish that the original clock was correct. |
| “This is a complete forensic chain of custody.” | Cryptographic integrity supports, but does not replace, documentation of collection, access, transfers, and handling. |

These are separate questions of authenticity, completeness, and evidence handling—not merely whether the stored bytes and sequence remain intact. [cursa](https://cursa.app/en/page/forensic-soundness-hashing-and-evidence-integrity)

In short, a hash chain is most valuable when paired with independently protected checkpoints: it turns an editable log into a history whose retrospective alteration can be detected. [security.stackexchange](https://security.stackexchange.com/questions/4320/techniques-for-ensuring-verifiability-of-event-log-files)

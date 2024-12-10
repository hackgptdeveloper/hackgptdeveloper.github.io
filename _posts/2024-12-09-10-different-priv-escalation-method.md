---
title: "List of linux privilege escalation methods"
tags:
  - PrivEscalation
---

List of Linux privilege escalation vulnerabilities with available Proof-of-Concepts (POCs) from 2019 to 2024:

---

1. **CVE-2019-14287**: Sudo vulnerability allowing a user to run commands as root by specifying the UID as -1. Exploit and details available on GitHub.

2. **CVE-2020-8835**: A flaw in Linux's kernel `overlayfs` file system allows privilege escalation. POC available on GitHub.

3. **CVE-2021-4034** ("PwnKit"): Exploits `pkexec` in Polkit for root access. Widely documented with POCs available.

4. **CVE-2022-0847** ("Dirty Pipe"): Exploits a flaw in the Linux pipe subsystem introduced in kernel 5.8. POC widely available.

5. **CVE-2022-34918**: A flaw in the Netfilter subsystem. It can be exploited for local privilege escalation on Linux kernels 5.17 to 5.19. POC provided in GitHub repositories.

6. **CVE-2023-2640** and **CVE-2023-32629**: Vulnerabilities affecting Ubuntu and Kali Linux environments. POCs and exploitation scripts are available.

7. **CVE-2024-1086**: Universal privilege escalation exploit affecting Linux kernels 5.14 to 6.6. Detailed POC and write-up available.

8. **CVE-2020-14386**: Exploits an issue in the Linux kernel’s user namespaces allowing privilege escalation. Exploit scripts can be found on GitHub.

9. **CVE-2019-15666**: A vulnerability in the `rds` kernel module allows local users to escalate privileges. Exploit details and POC are available.

10. **CVE-2023-30829**: Related to a vulnerability in the Ubuntu kernel, enabling unauthorized privilege escalation. POC available.

---

 - [Linux Privilege Escalation methods](https://github.com/topics/linux-privilege-escalation) 

 - [https://gist.github.com/win3zz/aa1ac16c4458aaaec6dd79343b8cd46f](https://gist.github.com/win3zz/aa1ac16c4458aaaec6dd79343b8cd46f)
 - [https://github.com/JlSakuya/Linux-Privilege-Escalation-Exploits](https://github.com/JlSakuya/Linux-Privilege-Escalation-Exploits)
 - [https://github.com/JlSakuya/Linux-Privilege-Escalation-Exploits/tree/main/2019/CVE-2019-15666](https://github.com/JlSakuya/Linux-Privilege-Escalation-Exploits/tree/main/2019/CVE-2019-15666)
 - [https://github.com/lrh2000/StackRot](https://github.com/lrh2000/StackRot)
 - [https://github.com/Notselwyn/CVE-2024-1086](https://github.com/Notselwyn/CVE-2024-1086)
 - [https://github.com/pqlx/CVE-2022-1015](https://github.com/pqlx/CVE-2022-1015)
 - [https://github.com/topics/linux-privilege-escalation](https://github.com/topics/linux-privilege-escalation)

- **Linux Kernel <= 2.6.37 local privilege escalation**:
  - [https://gist.github.com/1990490](https://gist.github.com/1990490)
- **Linux Kernel 2.6.19 < 5.9 - 'Netfilter Local Privilege ...**:
  - [https://gist.github.com/mpfund/98289230abd729417c8192fd6248dae0](https://gist.github.com/mpfund/98289230abd729417c8192fd6248dae0)
- **Linux Kernel - local privilege escalation**:
  - [https://gist.github.com/isrvb/2a601701f4b0433be649e42cf42dcb39](https://gist.github.com/isrvb/2a601701f4b0433be649e42cf42dcb39)
- **CVE-2014-4014 Linux Kernel Local Privilege Escalation PoC**:
  - [https://gist.github.com/infoslack/8606734bd02a6ab3e3ea](https://gist.github.com/infoslack/8606734bd02a6ab3e3ea)
- **Mike Czumak's Linux Privilege Escalation Check Script**:
  - [https://gist.github.com/smellslikeml/3078007438de6b5181ed7f3800060f8b](https://gist.github.com/smellslikeml/3078007438de6b5181ed7f3800060f8b)
- **Local Linux Enumeration & Privilege Escalation.md**:
  - [https://gist.github.com/juhuasannu/6954944](https://gist.github.com/juhuasannu/6954944)
- **Linux Kernel 4.3.3 (Ubuntu 14.04/15.10) - 'overlayfs' ...**:
  - [https://gist.github.com/9482698e2ec389e4517fab8122358c98](https://gist.github.com/9482698e2ec389e4517fab8122358c98)
- **Linux privilege escalation checker script**:
  - [https://gist.github.com/728078d06eb6f61c106080fc30350029](https://gist.github.com/728078d06eb6f61c106080fc30350029)
- **Linux Privilege Escalation Techniques**:
  - [https://gist.github.com/sckalath/8b8fe29ee5489eaefda1](https://gist.github.com/sckalath/8b8fe29ee5489eaefda1)
- **Cheat sheet basic Linux Privilege escalation**:
  - [https://gist.github.com/j1g54w1337/a2c0cc956485c9ddef3f627273fa886d](https://gist.github.com/j1g54w1337/a2c0cc956485c9ddef3f627273fa886d)
- **OSCP_Privilege_Escalation.md**:
  - [https://gist.github.com/ssstonebraker/fb2c43ad37a8a704bf952954ce95ec40](https://gist.github.com/ssstonebraker/fb2c43ad37a8a704bf952954ce95ec40)
- **exp-suggest.sh · GitHub**:
  - [https://gist.github.com/0xPwny/efd5f667b53727f5f43a19188393d96b](https://gist.github.com/0xPwny/efd5f667b53727f5f43a19188393d96b)
- **Linux Privilege Escalation Techniques**:
  - [https://gist.github.com/c0605da03558c69f11dc128f9cb06204](https://gist.github.com/c0605da03558c69f11dc128f9cb06204)
- **CVE-2010-3904 | by Dan Rosenberg and Vasileios P. ...**:
  - [https://gist.github.com/brant-ruan/2ca50705e194b99acd353c6a7afc4ae2](https://gist.github.com/brant-ruan/2ca50705e194b99acd353c6a7afc4ae2)
- **Linux priv esc. Might be out-dated script versions**:
  - [https://gist.github.com/unfo/8bc4923240c2fc119967fd1a4ad29fb9](https://gist.github.com/unfo/8bc4923240c2fc119967fd1a4ad29fb9)
- **cve-2014-0196-md.c**:
  - [https://gist.github.com/vito/e2ef567358671b91ab7f](https://gist.github.com/vito/e2ef567358671b91ab7f)
- **brant-ruan's gists**:
  - [https://gist.github.com/brant-ruan](https://gist.github.com/brant-ruan)
- **hacking-resources**:
  - [https://gist.github.com/PsychedelicShayna/dc3e0976683b3998cb920e7e3bad66c2](https://gist.github.com/PsychedelicShayna/dc3e0976683b3998cb920e7e3bad66c2)
- **Useful OSCP Links**:
  - [https://gist.github.com/ubogdan/d8c0ccfc64cb528deb7b4ad74be74c3f](https://gist.github.com/ubogdan/d8c0ccfc64cb528deb7b4ad74be74c3f)
- **output_peas.txt**:
  - [https://gist.github.com/KevinLiebergen/6b86a1caacbb57248353bac3fe31592b](https://gist.github.com/KevinLiebergen/6b86a1caacbb57248353bac3fe31592b)
- **ret2dir | CVE-2013-2094 | by Vasileios P. Kemerlis**:
  - [https://gist.github.com/brant-ruan/c3ea2ae513456a650909187872446972](https://gist.github.com/brant-ruan/c3ea2ae513456a650909187872446972)
- **disconnect3d's gists**:
  - [https://gist.github.com/disconnect3d](https://gist.github.com/disconnect3d)
- **cves.txt · GitHub**:
  - [https://gist.github.com/cranelab/284651e897185674666da5915709f3d4](https://gist.github.com/cranelab/284651e897185674666da5915709f3d4)
- **Pfoten chall solution from hxp 2020 ctf; tl;dr: swap was RW ...**:
  - [https://gist.github.com/disconnect3d/2d644e406221c9b37462e2fc98265e1b](https://gist.github.com/disconnect3d/2d644e406221c9b37462e2fc98265e1b)
- **security.txt · GitHub**:
  - [https://gist.github.com/b1tg/766d86eef9506899d90bd937beecbbec](https://gist.github.com/b1tg/766d86eef9506899d90bd937beecbbec)
- **hackingarticles.txt**:
  - [https://gist.github.com/cyberheartmi9/f545008cfcfa34c4f73d30a95fd01aa1](https://gist.github.com/cyberheartmi9/f545008cfcfa34c4f73d30a95fd01aa1)
- **Removed PWK Cheatsheet by sergey-pronin**:
  - [https://gist.github.com/prosecurity/cd74ea3120be3c5b88bbad590221be18](https://gist.github.com/prosecurity/cd74ea3120be3c5b88bbad590221be18)
- **Linux Security Guide.md**:
  - [https://gist.github.com/dante-robinson/3a2178e43009c8267ac02387633ff8ca](https://gist.github.com/dante-robinson/3a2178e43009c8267ac02387633ff8ca)
- **Zero to OSCP: Concise Edition**:
  - [https://gist.github.com/chrisolsen/7c0e5d92a4a0134c259e4ac50ac97c43](https://gist.github.com/chrisolsen/7c0e5d92a4a0134c259e4ac50ac97c43)
- **Red-Teaming-tool.md**:
  - [https://gist.github.com/z0rs/e1c640e2892cb6737602fec5d5496480](https://gist.github.com/z0rs/e1c640e2892cb6737602fec5d5496480)
- **OSCP notes A & B may have some commons**:
  - [https://gist.github.com/tthtlc/74bba74dcae998296b089888e881a5b1](https://gist.github.com/tthtlc/74bba74dcae998296b089888e881a5b1)
- **linux notes and cheatsheet**:
  - [https://gist.github.com/joshschmelzle/b758d9e42c048b2a196c6100de1562a8](https://gist.github.com/joshschmelzle/b758d9e42c048b2a196c6100de1562a8)
- **4.4.0-116-generic**:
  - [https://gist.github.com/thinkycx/7b537e4346410677ab3e1d74431c4725](https://gist.github.com/thinkycx/7b537e4346410677ab3e1d74431c4725)
- **AppSec Ezines Url (https://github.com/Simpsonpt/ ...**:
  - [https://gist.github.com/helcaraxeals/d73fd1fa46b0c9d8deb9877be73ad1b3](https://gist.github.com/helcaraxeals/d73fd1fa46b0c9d8deb9877be73ad1b3)
- **Buffer overflow demonstration in Kali Linux, based on the ...**:
  - [https://gist.github.com/apolloclark/6cffb33f179cc9162d0a](https://gist.github.com/apolloclark/6cffb33f179cc9162d0a)
- **SUID-root Binaries in Fedora Server 38**:
  - [https://gist.github.com/ok-ryoko/1ff42a805d496cb1ca22e5cdf6ddefb0](https://gist.github.com/ok-ryoko/1ff42a805d496cb1ca22e5cdf6ddefb0)
- **Windows PrivEsc Notes for OSCP Tib3rius Udemy course**:
  - [https://gist.github.com/Andross/bf990e87f3594dff58feb385e96c6b12](https://gist.github.com/Andross/bf990e87f3594dff58feb385e96c6b12)
- **OSCP PREPARATION**:
  - [https://gist.github.com/juanga333/fcd2699af8b38321e1acc7b7533445ef](https://gist.github.com/juanga333/fcd2699af8b38321e1acc7b7533445ef)
- **vuls to vyos**:
  - [https://gist.github.com/higebu/f33d14b5e575cd8079ced76532d50f42](https://gist.github.com/higebu/f33d14b5e575cd8079ced76532d50f42)
- **Pwn2Own bugs from ZDI offcial site**:
  - [https://gist.github.com/ChiChou/ad9c4aa8546007b853a7a396ab4c12d3](https://gist.github.com/ChiChou/ad9c4aa8546007b853a7a396ab4c12d3)
- **Pentesting-Exploitation**:
  - [https://gist.github.com/yezz123/52d2fc45c5de284ec89131c2a3dde389](https://gist.github.com/yezz123/52d2fc45c5de284ec89131c2a3dde389)
- **Cyber Sec. · GitHub**:
  - [https://gist.github.com/furusiyya/6bfe838ed7185e09ac0940a990b0c964](https://gist.github.com/furusiyya/6bfe838ed7185e09ac0940a990b0c964)
- **How to pass the OSCP**:
  - [https://gist.github.com/meldridge/d45a1886662a0b59f29bb94114163a0e](https://gist.github.com/meldridge/d45a1886662a0b59f29bb94114163a0e)
- **dradis-security-scan**:
  - [https://gist.github.com/charlesgreen/85e241159b1448002198c65b3bab674f](https://gist.github.com/charlesgreen/85e241159b1448002198c65b3bab674f)
- **Container Security**:
  - [https://gist.github.com/fcd4453e309b986c9076851657175f1f](https://gist.github.com/fcd4453e309b986c9076851657175f1f)
- **ulasacikel**:
  - [https://gist.github.com/ulasacikel](https://gist.github.com/ulasacikel)
- **Readme of Amazon Elastic Beanstalk AMI running ...**:
  - [https://gist.github.com/791135](https://gist.github.com/791135)
- **Client-side software update verification failures**:
  - [https://gist.github.com/roycewilliams/cf7fce5777d47a8b22265515dba8d004](https://gist.github.com/roycewilliams/cf7fce5777d47a8b22265515dba8d004)
- **Red-Teaming-tool.md**:
  - [https://gist.github.com/filipesam/39b94d093b53a8e961fdc1198df93a4b](https://gist.github.com/filipesam/39b94d093b53a8e961fdc1198df93a4b)
- **pocket backup · GitHub**:
  - [https://gist.github.com/breadchris/525a33a376565cc85595dda435abab38](https://gist.github.com/breadchris/525a33a376565cc85595dda435abab38)
- **ansible cheat sheet**:
  - [https://gist.github.com/githubfoam/94521cd6ebac9494939cba28c08f2eb3](https://gist.github.com/githubfoam/94521cd6ebac9494939cba28c08f2eb3)
- **Building a Secure Arch Linux Device**:
  - [https://gist.github.com/umbernhard/d1f4a44430d6d21b3881652c7a7c9ae5?permalink_comment_id=4117538](https://gist.github.com/umbernhard/d1f4a44430d6d21b3881652c7a7c9ae5?permalink_comment_id=4117538)
- **vadimszzz**:
  - [https://gist.github.com/vadimszzz](https://gist.github.com/vadimszzz)
- **vuls server · GitHub**:
  - [https://gist.github.com/hdhoang/b88afd48e3c5aa034315f58b89819818](https://gist.github.com/hdhoang/b88afd48e3c5aa034315f58b89819818)
- **100 GPT-2 Generated Fake CVE Descriptions Using ...**:
  - [https://gist.github.com/jgamblin/fc6b11df1fee148519e9b6ee1975fb7c](https://gist.github.com/jgamblin/fc6b11df1fee148519e9b6ee1975fb7c)
- **ZacFran**:
  - [https://gist.github.com/ZacFran](https://gist.github.com/ZacFran)
- **Antrea v0.1.1 vulnerabilities**:
  - [https://gist.github.com/antoninbas/96963c4c134133900642c755c60aca6b](https://gist.github.com/antoninbas/96963c4c134133900642c755c60aca6b)
- **Mr0maks's gists**:
  - [https://gist.github.com/Mr0maks](https://gist.github.com/Mr0maks)
- **FartKnocker · GitHub**:
  - [https://gist.github.com/SecurityIsIllusion/01ff3c256134ed8409765e164a83e2b1](https://gist.github.com/SecurityIsIllusion/01ff3c256134ed8409765e164a83e2b1)
- **Ubuntu 12.04, 14.04, 14.10, 15.04, overlayfs Local Root ( ...**:
  - [https://gist.github.com/90b77ae3d87485c4629d](https://gist.github.com/90b77ae3d87485c4629d)
- **oscp-cheatsheet.md**:
  - [https://gist.github.com/jusN-time/aba7ec6951721b561663254745175649](https://gist.github.com/jusN-time/aba7ec6951721b561663254745175649)
- **LTS1 Patch 12.1 Open Vulnerabilities**:
  - [https://gist.github.com/mithilarun/7f94a5e085d134acb4f27f770ddc0048](https://gist.github.com/mithilarun/7f94a5e085d134acb4f27f770ddc0048)
- **hacking-resources.md**:
  - [https://gist.github.com/selftaught/23943c6f04e59171cf11d625f220bf24](https://gist.github.com/selftaught/23943c6f04e59171cf11d625f220bf24)
- **totoroha**:
  - [https://gist.github.com/totoroha](https://gist.github.com/totoroha)
- **CVE-2021-22555 注释版**:
  - [https://gist.github.com/Junyi-99/ba18684e524c0b7addcf00950275bda7](https://gist.github.com/Junyi-99/ba18684e524c0b7addcf00950275bda7)
- **Red-Teaming-AD.md**:
  - [https://gist.github.com/z0rs/701b7c17be680ce53fc204e3c50570fc](https://gist.github.com/z0rs/701b7c17be680ce53fc204e3c50570fc)
- **pwnd · GitHub**:
  - [https://gist.github.com/MattKetmo/96d703bc23ce432d4591](https://gist.github.com/MattKetmo/96d703bc23ce432d4591)
- **Awesome-Pentesting**:
  - [https://gist.github.com/gofullthrottle/a9e4d73b407895fd24a3511a6caea52b](https://gist.github.com/gofullthrottle/a9e4d73b407895fd24a3511a6caea52b)
- **pushou's gists**:
  - [https://gist.github.com/pushou?direction=asc&sort=created](https://gist.github.com/pushou?direction=asc&sort=created)
- **linPEAS script**:
  - [https://gist.github.com/Rajchowdhury420/0cb984cb3997b129e1a388fc2bb764a6](https://gist.github.com/Rajchowdhury420/0cb984cb3997b129e1a388fc2bb764a6)
- **RPM .spec setup for building 2.6.32 kernel package ...**:
  - [https://gist.github.com/cheyinl/f94069a0e10d63c6774376588aee0a3a](https://gist.github.com/cheyinl/f94069a0e10d63c6774376588aee0a3a)
- **Docker Notes · GitHub**:
  - [https://gist.github.com/bbrk364/ffebc524f49e59fb484a2be8eefd9a6f](https://gist.github.com/bbrk364/ffebc524f49e59fb484a2be8eefd9a6f)
- **Ansible playbook that uses apt to upgrade packages and ...**:
  - [https://gist.github.com/corny/1563378d459d74f8a696?permalink_comment_id=3039580](https://gist.github.com/corny/1563378d459d74f8a696?permalink_comment_id=3039580)
- **my auditd ruleset along with some documentation**:
  - [https://gist.github.com/jakewarren/136707093f3cfdedb6fabfaddd513072](https://gist.github.com/jakewarren/136707093f3cfdedb6fabfaddd513072)
- **TryHackMe Kali Complete Docker Image**:
  - [https://gist.github.com/AshtonIzmev/72f33ae4ff93a6603d55959b2b1e8078](https://gist.github.com/AshtonIzmev/72f33ae4ff93a6603d55959b2b1e8078)
- **Setup Docker on Amazon Linux 2023**:
  - [https://gist.github.com/thimslugga/36019e15b2a47a48c495b661d18faa6d?permalink_comment_id=5057205](https://gist.github.com/thimslugga/36019e15b2a47a48c495b661d18faa6d?permalink_comment_id=5057205)
- **MITRE ATT&CK - Enterprise · GitHub**:
  - [https://gist.github.com/namishelex01/16c6fa27dab60549f66f896315a19386](https://gist.github.com/namishelex01/16c6fa27dab60549f66f896315a19386)
- **Bookmarks of Parrot OS**:
  - [https://gist.github.com/chukfinley/08f4154c913d588033e9871e82809dad](https://gist.github.com/chukfinley/08f4154c913d588033e9871e82809dad)
- **Update PoC code to try /sbin/ip if /sbin/ifconfig is not ...**:
  - [https://gist.github.com/brompwnie/ac38f8229cbebf5b6199ba9bc1f52052](https://gist.github.com/brompwnie/ac38f8229cbebf5b6199ba9bc1f52052)
- **startingwithhacking.md**:
  - [https://gist.github.com/rava-dosa/4e425406efe8112a260ff364befe1d46](https://gist.github.com/rava-dosa/4e425406efe8112a260ff364befe1d46)
- **Cobalt-Strike.md**:
  - [https://gist.github.com/z0rs/164335d94f9c19fc7fd52411ef27fb3e](https://gist.github.com/z0rs/164335d94f9c19fc7fd52411ef27fb3e)
- **julianlam's gists**:
  - [https://gist.github.com/julianlam?direction=desc&sort=updated](https://gist.github.com/julianlam?direction=desc&sort=updated)
- **pentest cheat sheet**:
  - [https://gist.github.com/githubfoam/4d3c99383b5372ee019c8fbc7581637d](https://gist.github.com/githubfoam/4d3c99383b5372ee019c8fbc7581637d)
- **Notes on getting Rocky 9 and Ubuntu 24.04 compliant ...**:
  - [https://gist.github.com/AfroThundr3007730/a65a171eb0e53ebd31ee34d6f7d08748](https://gist.github.com/AfroThundr3007730/a65a171eb0e53ebd31ee34d6f7d08748)
- **vadim-a-yegorov's gists**:
  - [https://gist.github.com/vadim-a-yegorov/forked?direction=asc&sort=created](https://gist.github.com/vadim-a-yegorov/forked?direction=asc&sort=created)
- **time-river's gists**:
  - [https://gist.github.com/time-river](https://gist.github.com/time-river)
- **Ipython_NVD.ipynb**:
  - [https://gist.github.com/brennap3/63413e12f2299e056469?short_path=e272269](https://gist.github.com/brennap3/63413e12f2299e056469?short_path=e272269)
- **Preparación para el OSCP (by s4vitar)**:
  - [https://gist.github.com/s4vitar/b88fefd5d9fbbdcc5f30729f7e06826e?permalink_comment_id=3418728](https://gist.github.com/s4vitar/b88fefd5d9fbbdcc5f30729f7e06826e?permalink_comment_id=3418728)
- **linux-malware to ATTACK.md**:
  - [https://gist.github.com/timb-machine/05043edd6e3f71569f0e6d2fe99f5e8c](https://gist.github.com/timb-machine/05043edd6e3f71569f0e6d2fe99f5e8c)
- **DFIR_IT Contest Submission**:
  - [https://gist.github.com/1aN0rmus/f59de12be167536f013461debef5a474](https://gist.github.com/1aN0rmus/f59de12be167536f013461debef5a474)
- **cedric cedriczirtacic**:
  - [https://gist.github.com/cedriczirtacic](https://gist.github.com/cedriczirtacic)
- **wdormann's gists**:
  - [https://gist.github.com/wdormann?direction=desc&sort=updated](https://gist.github.com/wdormann?direction=desc&sort=updated)
- **Bibliography for an AEG talk**:
  - [https://gist.github.com/SeanHeelan/99b24620c1655495caa2c69693ea72ec](https://gist.github.com/SeanHeelan/99b24620c1655495caa2c69693ea72ec)
- **dpkg-l · GitHub**:
  - [https://gist.github.com/urozavi/018f92df35970645a227](https://gist.github.com/urozavi/018f92df35970645a227)
- **mrpeas · GitHub**:
  - [https://gist.github.com/ssstonebraker/0a5924d9be512f2a8c14b562aa2f6038](https://gist.github.com/ssstonebraker/0a5924d9be512f2a8c14b562aa2f6038)
- **Command line scripts for CTF's**:
  - [https://gist.github.com/FrankSpierings/4af182c7c3aee32796792d35bedbe0fb](https://gist.github.com/FrankSpierings/4af182c7c3aee32796792d35bedbe0fb)
- **Iranian APT Groups & Possible Commands Used By These ...**:
  - [https://gist.github.com/chubbymaggie/2ddc25b8d85a0193b7d96968fc999536](https://gist.github.com/chubbymaggie/2ddc25b8d85a0193b7d96968fc999536)
- **DFIR Links · GitHub**:
  - [https://gist.github.com/Pitteuchar/a516aad08ed1e319fae004d2e24479eb](https://gist.github.com/Pitteuchar/a516aad08ed1e319fae004d2e24479eb)
- **Some Pentesting Notes · GitHub**:
  - [https://gist.github.com/binarytrails/7f1429d9af419774139cfad337280278](https://gist.github.com/binarytrails/7f1429d9af419774139cfad337280278)
- **Ultimate-Cheatsheet**:
  - [https://gist.github.com/johnfelipe/36cab7baf2693fa65817f0cd697fd689](https://gist.github.com/johnfelipe/36cab7baf2693fa65817f0cd697fd689)

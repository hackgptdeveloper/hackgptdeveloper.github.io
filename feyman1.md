
A clean way to demonstrate how a Feynman diagram becomes equations is to use the tree-level scattering of two distinguishable charged fermions through exchange of a virtual photon:

\[
e^-(p_1)+\mu^-(p_2)\longrightarrow e^-(p_3)+\mu^-(p_4).
\]

The diagram is a shorthand for a perturbative contribution to the quantum amplitude—not literally a picture of particles’ paths. Each vertex and internal line maps to a factor prescribed by QED. [arxiv](https://arxiv.org/pdf/1602.04182.pdf)

## 1. Start from QED

Use natural units, \(\hbar=c=1\), and metric convention \(g^{\mu\nu}=\mathrm{diag}(1,-1,-1,-1)\).

The QED Lagrangian for electrons and muons coupled to electromagnetism is

\[
\mathcal L =
\bar\psi_e(i\gamma^\mu\partial_\mu-m_e)\psi_e
+
\bar\psi_\mu(i\gamma^\mu\partial_\mu-m_\mu)\psi_\mu
-\frac14 F_{\mu\nu}F^{\mu\nu}
-\underbrace{e\,\bar\psi_e\gamma^\mu A_\mu\psi_e
-e\,\bar\psi_\mu\gamma^\mu A_\mu\psi_\mu}_{\mathcal L_{\mathrm{int}}},
\]

where

\[
F_{\mu\nu}=\partial_\mu A_\nu-\partial_\nu A_\mu.
\]

The interaction term,

\[
\mathcal L_{\mathrm{int}}=-e\bar\psi\gamma^\mu A_\mu\psi,
\]

says that a charged fermion can emit or absorb a photon. It produces the QED vertex factor

\[
\boxed{-ie\gamma^\mu}.
\]

The coupling satisfies

\[
\alpha \equiv \frac{e^2}{4\pi}\approx \frac{1}{137},
\]

where \(\alpha\) is the fine-structure constant.

## 2. The diagram

With momenta labelled as above, the exchange channel is

```text
electron:  p1  ───►●────────►  p3
                   │
                   │ q = p1 − p3
                   │
muon:      p2  ───►●────────►  p4
```

- Straight directed external lines: incoming/outgoing electron or muon states.
- Wavy internal line: a virtual photon.
- Each dot: an electromagnetic interaction vertex.
- Momentum conservation at the vertices implies

\[
p_1+p_2=p_3+p_4,
\]

and the momentum through the virtual photon can be chosen as

\[
q=p_1-p_3=p_4-p_2.
\]

Since the photon is internal, it need not obey the real-photon relation \(q^2=0\). Its off-shell four-momentum appears in the propagator denominator.

## 3. Translate diagram to factors

For a basic QED calculation in Feynman gauge, use:

| Diagram element | Mathematical factor |
|---|---|
| Incoming fermion with momentum \(p\), spin \(s\) | \(u(p,s)\) |
| Outgoing fermion | \(\bar u(p,s)\) |
| Electron/photon or muon/photon vertex | \(-ie\gamma^\mu\) |
| Internal photon carrying momentum \(q\) | \(\displaystyle \frac{-ig_{\mu\nu}}{q^2+i\epsilon}\) |
| Four-momentum conservation | \(\displaystyle (2\pi)^4\delta^{(4)}\!\left(\sum p_{\rm in}-\sum p_{\rm out}\right)\) |

The \(i\epsilon\) prescription means \(q^2\to q^2+i\epsilon\); it specifies how the propagator’s pole is handled and encodes causal time ordering. The scalar propagator has the analogous form \(i/(p^2-m^2+i\epsilon)\). [southampton.ac](https://www.southampton.ac.uk/~doug/ft1/ft18.pdf)

## 4. Derive the amplitude

Apply the factors in the order of the fermion lines. For the electron line,

\[
\bar u_e(p_3)\,(-ie\gamma^\mu)\,u_e(p_1).
\]

For the muon line,

\[
\bar u_\mu(p_4)\,(-ie\gamma^\nu)\,u_\mu(p_2).
\]

For the exchanged photon,

\[
\frac{-ig_{\mu\nu}}{q^2+i\epsilon}.
\]

Multiplying them gives the \(S\)-matrix contribution:

\[
i\mathcal M
=
\left[\bar u_e(p_3)(-ie\gamma^\mu)u_e(p_1)\right]
\left[\frac{-ig_{\mu\nu}}{q^2+i\epsilon}\right]
\left[\bar u_\mu(p_4)(-ie\gamma^\nu)u_\mu(p_2)\right].
\]

Collecting constants and contracting the Lorentz indices:

\[
i\mathcal M
=
i\,\frac{e^2}{q^2+i\epsilon}
\left[\bar u_e(p_3)\gamma^\mu u_e(p_1)\right]
\left[\bar u_\mu(p_4)\gamma_\mu u_\mu(p_2)\right].
\]

Therefore, with the common convention in which the \(S\)-matrix contains \(i\mathcal M\),

\[
\boxed{
\mathcal M
=
\frac{e^2}{q^2+i\epsilon}
\left[\bar u_e(p_3)\gamma^\mu u_e(p_1)\right]
\left[\bar u_\mu(p_4)\gamma_\mu u_\mu(p_2)\right]
}
\]

together with the overall conservation factor

\[
(2\pi)^4\delta^{(4)}(p_1+p_2-p_3-p_4).
\]

This has a useful interpretation:

\[
J_e^\mu=\bar u_e(p_3)\gamma^\mu u_e(p_1),
\qquad
J_{\mu}^\nu=\bar u_\mu(p_4)\gamma^\nu u_\mu(p_2),
\]

so that

\[
\mathcal M = \frac{e^2}{q^2+i\epsilon}\,J_e^\mu J_{\mu,\mu}.
\]

In words: the electron current produces a virtual photon, the photon propagates, and the muon current absorbs it.

## 5. From amplitude to an observable

A single diagram yields an amplitude, not directly a probability. For an unpolarized scattering experiment, one averages over initial spins and sums over final spins:

\[
\overline{|\mathcal M|^2}
=
\frac14\sum_{\text{spins}}|\mathcal M|^2.
\]

The spin sums are reduced using

\[
\sum_s u(p,s)\bar u(p,s)=\slashed p+m,
\qquad
\slashed p\equiv \gamma^\mu p_\mu.
\]

Thus,

\[
\overline{|\mathcal M|^2}
=
\frac{e^4}{4(q^2)^2}
\operatorname{Tr}
\left[
(\slashed p_3+m_e)\gamma^\mu
(\slashed p_1+m_e)\gamma^\nu
\right]
\operatorname{Tr}
\left[
(\slashed p_4+m_\mu)\gamma_\mu
(\slashed p_2+m_\mu)\gamma_\nu
\right].
\]

The differential cross section for a generic \(2\to2\) process is then

\[
d\sigma
=
\frac{1}{4\sqrt{(p_1\cdot p_2)^2-m_e^2m_\mu^2}}
\,
\overline{|\mathcal M|^2}
\,
d\Phi_2,
\]

where the two-body Lorentz-invariant phase-space element is

\[
d\Phi_2
=
(2\pi)^4\delta^{(4)}(p_1+p_2-p_3-p_4)
\prod_{f=3,4}
\frac{d^3\mathbf p_f}{(2\pi)^3\,2E_f}.
\]

This workflow—draw all permitted diagrams at a chosen perturbative order, write \(\mathcal M\), sum amplitudes, square the total, then integrate phase space—is the standard diagram-to-prediction pipeline. [arxiv](https://arxiv.org/pdf/1602.04182.pdf)

## Why this is a good demonstration

Electron–muon scattering is simpler than electron–electron scattering because the final particles are distinguishable. For \(e^-e^-\to e^-e^-\), there is an additional exchange diagram, and the total amplitude becomes

\[
\mathcal M_{\text{total}}
=
\mathcal M_t-\mathcal M_u,
\]

with the relative minus sign coming from exchanging identical fermions. That interference is physically important, but it obscures the core “vertex × propagator × vertex” idea for a first example.

At low momentum transfer, the photon factor \(1/q^2\) becomes the momentum-space origin of the familiar long-range Coulomb interaction. In the nonrelativistic static limit, \(q^0\simeq0\), so \(q^2\simeq-\mathbf q^2\), and Fourier transforming a \(1/\mathbf q^2\) dependence yields a \(1/r\) potential. Thus the diagrammatic QED calculation connects directly back to

\[
V(r)=\frac{e^2}{4\pi r}
=
\frac{\alpha}{r},
\]

for like charges, with the appropriate sign determined by the charges involved.

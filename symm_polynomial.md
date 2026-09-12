
A **symmetric polynomial** in \(n\) variables is a polynomial unchanged by every permutation of its variables. Their central structural fact is that all of them are generated—uniquely—by the elementary symmetric polynomials. [kconrad.math.uconn](https://kconrad.math.uconn.edu/blurbs/galoistheory/symmfunction.pdf)

## Definition and invariance

Let \(R\) be a commutative ring and let

\[
f(x_1,\dots,x_n)\in R[x_1,\dots,x_n].
\]

It is symmetric if, for every \(\sigma\in S_n\),

\[
f(x_{\sigma(1)},\dots,x_{\sigma(n)})=f(x_1,\dots,x_n).
\]

Equivalently, it is enough to check invariance under swaps of two variables, since transpositions generate \(S_n\).

Examples in three variables:

\[
x_1+x_2+x_3,
\qquad
x_1x_2+x_1x_3+x_2x_3,
\qquad
x_1^2+x_2^2+x_3^2,
\]

\[
x_1^2x_2+x_1^2x_3+x_2^2x_1+x_2^2x_3+x_3^2x_1+x_3^2x_2.
\]

By contrast,

\[
x_1^2x_2+x_2^2x_3+x_3^2x_1
\]

is generally not symmetric: swapping \(x_1\) and \(x_2\) changes it.

Formally, \(S_n\) acts on \(R[x_1,\ldots,x_n]\) by permuting variables, and the symmetric polynomials form the invariant subring

\[
R[x_1,\ldots,x_n]^{S_n}.
\]

This invariant-theoretic perspective is fundamental: symmetric polynomials are precisely those expressions that depend on an unordered multiset \(\{x_1,\ldots,x_n\}\), rather than on an ordering of its elements. [sites.math.washington](https://sites.math.washington.edu/~julia/teaching/504_Fall2018/WK_Polynomials.pdf)

## Ring and grading properties

The symmetric polynomials form a subring:

\[
f,g\text{ symmetric}
\quad\Longrightarrow\quad
f+g,\; -f,\; fg\text{ symmetric}.
\]

If \(R\) is an algebra over a field or ring, then scalar multiples are symmetric as well. Thus

\[
R[x_1,\ldots,x_n]^{S_n}
\]

is closed under the standard algebraic operations.

They also inherit the ordinary total-degree grading:

\[
R[x_1,\ldots,x_n]^{S_n}
=
\bigoplus_{d\ge 0}\Lambda_n^d,
\]

where \(\Lambda_n^d\) denotes symmetric homogeneous polynomials of total degree \(d\).

A polynomial \(f\) is **homogeneous of degree \(d\)** if each monomial appearing in it has total degree \(d\). For example,

\[
x_1^2+x_2^2+x_3^2
\]

is symmetric and homogeneous of degree \(2\), whereas

\[
1+(x_1+x_2+x_3)+x_1x_2x_3
\]

is symmetric but not homogeneous.

Every symmetric polynomial decomposes uniquely into homogeneous symmetric pieces:

\[
f=f_0+f_1+\cdots+f_d,
\]

where each \(f_i\) is symmetric and homogeneous of degree \(i\).

This matters because the structure of symmetric polynomials can be studied degree by degree. In degree \(d\), a natural basis is indexed by partitions of \(d\) with at most \(n\) parts.

## Elementary symmetric polynomials

The most important generators are the **elementary symmetric polynomials**:

\[
e_k(x_1,\ldots,x_n)
=
\sum_{1\le i_1<\cdots<i_k\le n}
x_{i_1}\cdots x_{i_k}.
\]

Explicitly,

\[
e_0=1,
\]

\[
e_1=x_1+\cdots+x_n,
\]

\[
e_2=\sum_{i<j}x_ix_j,
\]

and

\[
e_n=x_1x_2\cdots x_n.
\]

For \(n=3\),

\[
e_1=x+y+z,\qquad
e_2=xy+xz+yz,\qquad
e_3=xyz.
\]

Their generating polynomial is

\[
\prod_{i=1}^n(1+x_it)
=
\sum_{k=0}^n e_k(x_1,\ldots,x_n)t^k.
\]

This one identity packages all elementary symmetric polynomials simultaneously.

The elementary symmetric polynomials are homogeneous, with

\[
\deg e_k=k.
\]

They are also algebraically independent: there is no nonzero polynomial

\[
F(T_1,\ldots,T_n)\in R[T_1,\ldots,T_n]
\]

such that

\[
F(e_1,\ldots,e_n)=0.
\]

Over the usual coefficient rings such as \(\mathbb Z\), \(\mathbb Q\), or a field, this means the invariant ring is a genuine polynomial ring in \(n\) independent generators.

## Fundamental theorem

The **Fundamental Theorem of Symmetric Polynomials** states:

\[
R[x_1,\ldots,x_n]^{S_n}
=
R[e_1,\ldots,e_n].
\]

In words: every symmetric polynomial can be expressed as a polynomial in \(e_1,\ldots,e_n\). Moreover, this expression is unique. [kconrad.math.uconn](https://kconrad.math.uconn.edu/blurbs/galoistheory/symmfunction.pdf)

Thus,

\[
R[x_1,\ldots,x_n]^{S_n}
\cong R[t_1,\ldots,t_n],
\]

under the correspondence

\[
t_k\longmapsto e_k.
\]

### Example

For three variables, let

\[
f=x^2+y^2+z^2.
\]

Since

\[
(x+y+z)^2=x^2+y^2+z^2+2(xy+xz+yz),
\]

we get

\[
x^2+y^2+z^2=e_1^2-2e_2.
\]

Similarly,

\[
x^3+y^3+z^3=e_1^3-3e_1e_2+3e_3.
\]

And

\[
x^2y^2+x^2z^2+y^2z^2=e_2^2-2e_1e_3.
\]

So expressions that seem to involve individual roots or variables can be reduced to expressions involving only the unordered data encoded by \(e_1,\ldots,e_n\).

### Constructive proof idea

A standard proof uses a monomial-order elimination argument:

1. Take the lexicographically largest monomial of a symmetric polynomial.
2. Symmetry forces all its distinct permutations to occur with the same coefficient.
3. Construct a product of elementary symmetric polynomials whose leading term matches that symmetric monomial pattern.
4. Subtract an appropriate multiple to cancel the leading term.
5. Repeat; because monomial order is well-founded, the process terminates.

This not only proves existence but yields an algorithm for rewriting a symmetric polynomial in elementary symmetric coordinates.

## Alternative bases

The same ring has several important bases, each suited to a different problem.

| Family | Definition / role | Main property |
|---|---|---|
| Elementary \(e_\lambda\) | Products \(e_{\lambda_1}e_{\lambda_2}\cdots\) | Natural for Vieta’s formulas and generation |
| Complete homogeneous \(h_r\) | Sum of all monomials of total degree \(r\) | Natural for generating functions and representation theory |
| Power sums \(p_r\) | \(p_r=\sum_i x_i^r\) | Natural for Newton identities and spectral data |
| Monomial symmetric \(m_\lambda\) | Sum of distinct monomials obtained by permuting an exponent pattern | Integral basis indexed by partitions |
| Schur \(s_\lambda\) | Defined by tableaux or alternant quotients | Central in \(GL_n\) representation theory and geometry |

Here, a partition is a nonincreasing sequence

\[
\lambda=(\lambda_1,\lambda_2,\ldots,\lambda_\ell),
\qquad
\lambda_1\ge\lambda_2\ge\cdots\ge\lambda_\ell>0.
\]

For instance, in three variables, the partition \((2,1)\) produces

\[
m_{(2,1)}
=
x_1^2x_2+x_1^2x_3+x_2^2x_1+x_2^2x_3+x_3^2x_1+x_3^2x_2.
\]

### Monomial symmetric basis

For fixed \(n\), the monomial symmetric polynomials

\[
m_\lambda(x_1,\ldots,x_n)
\]

with \(\ell(\lambda)\le n\) form a \(\mathbb Z\)-basis of the ring of symmetric polynomials. Consequently, the dimension of the degree-\(d\) homogeneous component equals

\[
\dim \Lambda_n^d
=
\#\{\lambda\vdash d:\ell(\lambda)\le n\}.
\]

That is, it is the number of partitions of \(d\) with at most \(n\) parts.

If the number of variables is unrestricted—symmetric functions rather than symmetric polynomials in a fixed \(n\)—the degree-\(d\) component has dimension \(p(d)\), the partition number.

### Complete homogeneous polynomials

The complete homogeneous symmetric polynomial is

\[
h_r(x_1,\ldots,x_n)
=
\sum_{i_1\le\cdots\le i_r}x_{i_1}\cdots x_{i_r}.
\]

For example,

\[
h_2=x_1^2+\cdots+x_n^2+\sum_{i<j}x_ix_j.
\]

The generating function is

\[
H(t)=\sum_{r\ge0}h_rt^r
=
\prod_{i=1}^n\frac{1}{1-x_it}.
\]

Together with

\[
E(t)=\sum_{r\ge0}e_rt^r
=
\prod_{i=1}^n(1+x_it),
\]

one obtains the reciprocal relation

\[
H(t)E(-t)=1.
\]

This encodes many identities between the \(h_r\) and \(e_r\).

## Newton identities

The power sums

\[
p_k=x_1^k+\cdots+x_n^k
\]

are symmetric. Newton’s identities connect them to the elementary symmetric polynomials:

\[
p_k-e_1p_{k-1}+e_2p_{k-2}-\cdots+(-1)^{k-1}e_{k-1}p_1+(-1)^k k e_k=0
\]

for \(1\le k\le n\).

For \(k>n\), set \(e_k=0\), and the recurrence becomes

\[
p_k-e_1p_{k-1}+e_2p_{k-2}-\cdots+(-1)^n e_np_{k-n}=0.
\]

The first few are

\[
p_1=e_1,
\]

\[
p_2=e_1^2-2e_2,
\]

\[
p_3=e_1^3-3e_1e_2+3e_3,
\]

\[
p_4=e_1^4-4e_1^2e_2+2e_2^2+4e_1e_3-4e_4.
\]

Over a coefficient ring containing \(\mathbb Q\), Newton’s identities also let one express \(e_k\) in terms of \(p_1,\ldots,p_k\). Hence

\[
\mathbb Q[x_1,\ldots,x_n]^{S_n}
=
\mathbb Q[p_1,\ldots,p_n].
\]

The qualification “over \(\mathbb Q\)” matters: recovering \(e_k\) from \(p_i\) often requires dividing by \(k\). Over \(\mathbb Z\), the elementary symmetric functions give a better integral generating system.

## Connection with roots and coefficients

Suppose

\[
f(t)=\prod_{i=1}^n(t-x_i)
\]

is the monic polynomial with roots \(x_1,\ldots,x_n\). Then

\[
f(t)
=
t^n-e_1t^{n-1}+e_2t^{n-2}-\cdots+(-1)^ne_n.
\]

Therefore, the coefficients are exactly the elementary symmetric functions of the roots, up to alternating signs. This is Vieta’s theorem. [isa-afp](https://isa-afp.org/browser_info/current/AFP/Symmetric_Polynomials/outline.pdf)

If

\[
f(t)=t^n+a_1t^{n-1}+\cdots+a_n,
\]

then

\[
e_k(x_1,\ldots,x_n)=(-1)^k a_k.
\]

This has an important algebraic consequence:

> Any symmetric polynomial expression in the roots of a monic polynomial can be written purely in terms of its coefficients.

For example, if \(r_1,r_2,r_3\) are roots of

\[
t^3+a t^2+b t+c,
\]

then

\[
r_1^2+r_2^2+r_3^2
=
(r_1+r_2+r_3)^2
-
2(r_1r_2+r_1r_3+r_2r_3)
=
a^2-2b.
\]

No explicit root formula is required.

This principle is central to Galois theory: coefficients are invariant under permutations of roots, while individual roots generally are not. Symmetric expressions descend from a splitting field to the coefficient field.

## Discriminant and alternating polynomials

A polynomial \(a(x_1,\ldots,x_n)\) is **alternating** if

\[
a(x_{\sigma(1)},\ldots,x_{\sigma(n)})
=
\operatorname{sgn}(\sigma)a(x_1,\ldots,x_n).
\]

The fundamental alternating polynomial is the Vandermonde determinant:

\[
\Delta(x_1,\ldots,x_n)
=
\prod_{1\le i<j\le n}(x_i-x_j).
\]

It changes sign under odd permutations and is unchanged under even permutations.

Key properties:

- \(\Delta=0\) exactly when at least two variables coincide.
- Every alternating polynomial is divisible by \(\Delta\).
- The quotient of an alternating polynomial by \(\Delta\) is symmetric.
- Consequently, the alternating polynomials form a free rank-one module over the symmetric polynomial ring:

\[
\operatorname{Alt}_n
=
\Delta\cdot R[x_1,\ldots,x_n]^{S_n}.
\]

The square

\[
\Delta^2=\prod_{i<j}(x_i-x_j)^2
\]

is symmetric, so it can be expressed as a polynomial in \(e_1,\ldots,e_n\). This is the **discriminant** of the monic polynomial with roots \(x_1,\ldots,x_n\). It vanishes precisely when the polynomial has a repeated root. [people.reed](https://people.reed.edu/~jerry/332/20sympoly.pdf)

For a quadratic

\[
t^2-e_1t+e_2,
\]

the discriminant is

\[
\Delta^2=(x_1-x_2)^2=e_1^2-4e_2.
\]

For a cubic

\[
t^3-e_1t^2+e_2t-e_3,
\]

it is

\[
e_1^2e_2^2
-4e_2^3
-4e_1^3e_3
-27e_3^2
+18e_1e_2e_3.
\]

## Symmetrization and orbit sums

Given any polynomial \(f\), one can construct a symmetric polynomial by averaging over the symmetric group:

\[
\operatorname{Sym}(f)
=
\sum_{\sigma\in S_n}
\sigma\cdot f.
\]

If the coefficient ring allows division by \(n!\), one often uses the normalized average

\[
\frac{1}{n!}\sum_{\sigma\in S_n}\sigma\cdot f.
\]

For example, with \(f=x_1^2x_2\) in three variables,

\[
\operatorname{Sym}(x_1^2x_2)
=
2m_{(2,1)}.
\]

The coefficient \(2\) occurs because each distinct monomial in the orbit appears multiple times in the full group sum.

Symmetrization is a projection onto the invariant subspace when \(n!\) is invertible in the base ring. In characteristic dividing \(n!\), this averaging construction may fail as a projection, even though the definition and much of the elementary-symmetric structure remain meaningful.

## Schur polynomials

Schur polynomials provide the basis most closely tied to representation theory, algebraic geometry, and combinatorics. For a partition \(\lambda\) with at most \(n\) parts,

\[
s_\lambda(x_1,\ldots,x_n)
=
\frac{
\det\left(x_i^{\lambda_j+n-j}\right)_{1\le i,j\le n}
}{
\det\left(x_i^{n-j}\right)_{1\le i,j\le n}
}.
\]

The denominator is the Vandermonde determinant, and the quotient is symmetric because the numerator and denominator are both alternating.

Important properties include:

- \(s_\lambda\) is homogeneous of degree \(|\lambda|=\lambda_1+\cdots+\lambda_\ell\).
- The Schur polynomials form a \(\mathbb Z\)-basis of the symmetric polynomial ring.
- \(s_{(r)}=h_r\).
- \(s_{(1^r)}=e_r\).
- Products have nonnegative integer structure constants:

\[
s_\lambda s_\mu
=
\sum_\nu c_{\lambda\mu}^{\nu}s_\nu,
\]

where \(c_{\lambda\mu}^{\nu}\) are Littlewood–Richardson coefficients.
- \(s_\lambda(1,\ldots,1)\) gives the dimension of the corresponding irreducible polynomial representation of \(GL_n\).
- Schur functions also encode characters in representation theory and can be counted through semistandard Young tableaux. [math.uchicago](https://math.uchicago.edu/~may/REU2020/REUPapers/Graham.pdf)

For example,

\[
s_{(2)}=h_2=e_1^2-e_2,
\]

while

\[
s_{(1,1)}=e_2.
\]

The decomposition

\[
s_{(1)}^2=s_{(2)}+s_{(1,1)}
\]

reflects the decomposition of the tensor square of the defining representation into symmetric and exterior parts.

## Stable symmetric functions

For each fixed \(n\), symmetric polynomials live in

\[
R[x_1,\ldots,x_n]^{S_n}.
\]

One can pass to infinitely many variables by requiring compatibility under

\[
x_{n+1}=0.
\]

The resulting graded ring is the ring of symmetric functions, commonly denoted

\[
\Lambda.
\]

Over \(\mathbb Z\),

\[
\Lambda_{\mathbb Z}
=
\mathbb Z[e_1,e_2,e_3,\ldots],
\]

and equivalently it has integral bases \(\{m_\lambda\}\), \(\{h_\lambda\}\), \(\{e_\lambda\}\), and \(\{s_\lambda\}\), indexed by all partitions.

The stable viewpoint removes the artificial upper bound of \(n\) variables. For example, in degree \(d\), the basis is indexed by every partition of \(d\), rather than only those with at most \(n\) parts.

## Why the theory matters

Symmetric polynomials repeatedly arise whenever a problem is unchanged by relabeling:

- **Algebra and Galois theory:** coefficients of a polynomial are symmetric functions of its roots; the fundamental theorem explains why these expressions lie in the coefficient field.
- **Linear algebra:** if \(A\) has eigenvalues \(\lambda_1,\ldots,\lambda_n\), then the characteristic polynomial coefficients are \(e_k(\lambda_1,\ldots,\lambda_n)\), while \(\operatorname{tr}(A^m)=p_m(\lambda_1,\ldots,\lambda_n)\).
- **Matrix identities:** Newton identities relate traces of powers, determinants, and characteristic coefficients.
- **Algebraic geometry:** the quotient of affine \(n\)-space by \(S_n\) is described by elementary symmetric coordinates; geometrically, unordered \(n\)-tuples are parameterized by polynomial coefficients.
- **Combinatorics:** partitions, tableaux, generating functions, and counting problems are organized by symmetric-function bases.
- **Representation theory:** Schur polynomials encode irreducible polynomial representations of \(GL_n\), and their multiplication records tensor-product decomposition.
- **Invariant theory:** \(R[x_1,\ldots,x_n]^{S_n}\) is the canonical example of a polynomial invariant ring.

The concise structural summary is

\[
R[x_1,\ldots,x_n]^{S_n}
=
R[e_1,\ldots,e_n],
\]

with the elementary symmetric functions serving as coordinates on unordered collections of \(n\) variables. The richer theory comes from changing bases—power sums for spectral and trace identities, monomial functions for partition combinatorics, and Schur functions for representation theory.

---
title: "Computing configuration integrals"
tags:
  - Physics
---

**Configurational integrals**, which sit at the heart of **statistical mechanics** and **computational chemistry/physics**, especially in molecular simulations (Monte Carlo, Molecular Dynamics).

Let’s carefully build this up from **first principles**, step by step, with all the **mathematical formulations** that appear in computing configurational integrals.

---

# 1. Partition Function as the Starting Point

In statistical mechanics, the **canonical partition function** for (N) particles at temperature (T) in volume (V) is:

[
Q_N(V, T) = \frac{1}{N! h^{3N}} \int d^{3N}p , d^{3N}q , e^{-\beta H(p, q)}
]

* (N!) : indistinguishability correction
* (h) : Planck’s constant (ensures correct units in phase space)
* (d^{3N}p) : integration over momentum coordinates of all (N) particles
* (d^{3N}q) : integration over spatial coordinates of all (N) particles
* (H(p, q)) : Hamiltonian of the system
* (\beta = \frac{1}{k_B T}), where (k_B) is Boltzmann’s constant

---

# 2. Separation into Momentum and Configurational Parts

The Hamiltonian separates into kinetic and potential energy:

[
H(p, q) = K(p) + U(q)
]

where

* (K(p) = \sum_{i=1}^N \frac{p_i^2}{2m_i})
* (U(q)) is the potential energy depending on positions only

So:

[
Q_N(V, T) = \frac{1}{N! h^{3N}} \int d^{3N}p , e^{-\beta K(p)} \int d^{3N}q , e^{-\beta U(q)}
]

---

# 3. Momentum Integral (Gaussian Integral)

The momentum part is separable and Gaussian:

[
\int d^{3N}p , e^{-\beta \sum_i \frac{p_i^2}{2m_i}} = \prod_{i=1}^N \left( \int d^3p_i , e^{-\beta \frac{p_i^2}{2m_i}} \right)
]

Each integral is a Gaussian in 3D:

[
\int d^3p , e^{-\beta \frac{p^2}{2m}} = \left( 2\pi m k_B T \right)^{3/2}
]

So the total kinetic integral is:

[
\int d^{3N}p , e^{-\beta K(p)} = (2\pi k_B T)^{3N/2} \prod_{i=1}^N m_i^{3/2}
]

---

# 4. Configurational Integral

What remains is the **configurational integral**:

[
Z_N(V, T) = \int d^{3N}q , e^{-\beta U(q)}
]

This is **the central object** in computing molecular systems:

* (d^{3N}q) means integrate over all possible positions of (N) particles.
* (U(q)) encodes the interactions (pair potentials, many-body forces, etc).

Thus:

[
Q_N(V, T) = \frac{1}{N! h^{3N}} (2\pi k_B T)^{3N/2} \left( \prod_{i=1}^N m_i^{3/2} \right) \cdot Z_N(V, T)
]

---

# 5. Potential Energy Decomposition

For pairwise additive interactions:

[
U(q) = \sum_{i<j} u(r_{ij})
]

where (r_{ij} = |q_i - q_j|).

So:

[
Z_N(V, T) = \int_V \cdots \int_V \exp!\left( -\beta \sum_{i<j} u(r_{ij}) \right) d^3q_1 \cdots d^3q_N
]

This is **intractable analytically** for large (N). That’s why **Monte Carlo** and **Molecular Dynamics** are used.

---

# 6. Thermodynamic Connections

The configurational integral connects directly to **thermodynamic observables**:

* **Helmholtz free energy**:
  [
  A = -k_B T \ln Q_N(V,T)
  ]

* **Pressure (virial route)**:
  [
  P = k_B T \frac{\partial \ln Z_N}{\partial V}
  ]

* **Internal energy**:
  [
  U = -\frac{\partial \ln Z_N}{\partial \beta}
  ]

---

# 7. Approximations and Series Expansions

In practice, we approximate (Z_N).

### Mayer Cluster Expansion:

Introduce the **Mayer f-function**:

[
f_{ij}(r_{ij}) = e^{-\beta u(r_{ij})} - 1
]

Then:

[
Z_N = \int \cdots \int \prod_{i<j} \left(1 + f_{ij}\right) d^3q_1 \cdots d^3q_N
]

This expansion is used to derive **virial coefficients** for real gases.

---

# 8. Computing (Z_N) in Simulation

* **Monte Carlo**:
  Sample configurations ({q}) with probability (P(q) \propto e^{-\beta U(q)}), then compute averages.

* **Molecular Dynamics**:
  Generate trajectories consistent with (e^{-\beta U(q)}), and time averages approximate ensemble averages.

---

# 9. Example: Ideal Gas Case

For (U(q) = 0):

[
Z_N(V, T) = \int_V \cdots \int_V 1 , d^3q_1 \cdots d^3q_N = V^N
]

So:

[
Q_N^{\text{ideal}} = \frac{1}{N! h^{3N}} (2\pi k_B T)^{3N/2} \left( \prod_{i=1}^N m_i^{3/2} \right) V^N
]

---

✅ **Summary of Key Mathematical Formulas** in configurational integrals:

1. Partition function:
   [
   Q_N = \frac{1}{N! h^{3N}} \int d^{3N}p , d^{3N}q , e^{-\beta H}
   ]

2. Configurational integral:
   [
   Z_N = \int d^{3N}q , e^{-\beta U(q)}
   ]

3. Pairwise potential:
   [
   Z_N = \int \cdots \int \exp!\Big(-\beta \sum_{i<j} u(r_{ij})\Big) d^{3N}q
   ]

4. Mayer expansion:
   [
   Z_N = \int \cdots \int \prod_{i<j} (1 + f_{ij}) d^{3N}q
   ]

---

Would you like me to **derive the computational Monte Carlo estimator** for (Z_N) (how we *numerically* compute configurational integrals in practice), or should I keep it purely **analytical expansions** like cluster/Mayer series?


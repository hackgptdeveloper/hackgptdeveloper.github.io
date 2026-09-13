
Earth’s motion can be modeled as the superposition of two distinct motions: a nearly uniform **spin** about its own axis and a non-uniform Keplerian orbit about the Sun. The Earth’s spin is extremely regular for ordinary purposes but not perfectly constant; importantly, its physical spin period does **not** become measurably different merely because Earth is at perihelion versus aphelion. The apparent solar-day timing does change seasonally because orbital angular speed changes along the ellipse. [iers](https://www.iers.org/IERS/EN/Science/EarthRotation/UT1LOD.html)

## Two motions

Let an inertial heliocentric frame have the Sun at the origin. Then Earth’s center follows an ellipse, while a point fixed to Earth additionally rotates around Earth’s spin axis.

### Earth’s elliptical orbit

In the orbital plane, use the eccentric anomaly \(E\). A standard parametrization is

\[
\mathbf R(E)
=
\begin{pmatrix}
a(\cos E-e)\\
a\sqrt{1-e^2}\sin E\\
0
\end{pmatrix},
\]

where:

- \(a\) is the orbital semimajor axis, approximately 1 AU.
- \(e\) is orbital eccentricity, approximately \(0.0167\).
- \(E\) is not uniform in time; it satisfies Kepler’s equation

\[
\boxed{
M=nt=E-e\sin E,
}
\]

where

\[
n=\sqrt{\frac{\mu_\odot}{a^3}}=\frac{2\pi}{T}
\]

is the mean motion, \(T\) is the sidereal orbital period, and \(\mu_\odot=GM_\odot\).

Equivalently, using true anomaly \(\nu\),

\[
\boxed{
r(\nu)=\frac{a(1-e^2)}{1+e\cos\nu}.
}
\]

At perihelion \(\nu=0\), Earth is closest to the Sun; at aphelion \(\nu=\pi\), it is farthest. Earth is fastest at perihelion and slowest at aphelion, exactly as Kepler’s second law requires. [science.nasa](https://science.nasa.gov/solar-system/orbits-and-keplers-laws/)

Earth’s perihelion and aphelion distances are approximately

\[
r_{\rm peri}=0.9833\ \mathrm{AU},
\qquad
r_{\rm aph}=1.0167\ \mathrm{AU}.
\]

The corresponding orbital speeds are roughly 30.29 km/s and 29.29 km/s. [tfaws.nasa](https://tfaws.nasa.gov/wp-content/uploads/Rickman-Presentation.pdf)

### Rotation about Earth’s axis

Let \(\boldsymbol\rho_0\) be the position of a point relative to Earth’s center in an Earth-fixed reference orientation. Ignoring polar motion, nutation, and small time-dependent corrections, its inertial position is

\[
\boxed{
\mathbf r(t)
=
\mathbf R_{\rm orbit}(t)
+
Q_{\rm tilt}\,
R_z(\theta_{\rm spin}(t))\,
\boldsymbol\rho_0,
}
\]

where:

- \(\mathbf R_{\rm orbit}(t)\) is Earth’s heliocentric position.
- \(Q_{\rm tilt}\) rotates from Earth’s equatorial orientation into the ecliptic/inertial frame, incorporating approximately \(23.44^\circ\) axial tilt.
- \(R_z(\theta)\) is a rotation about the Earth spin axis.
- \(\theta_{\rm spin}(t)\) is Earth’s sidereal rotation angle.

In an idealized rigid-Earth model,

\[
\boxed{
\theta_{\rm spin}(t)=\theta_0+\omega_\oplus t,
}
\]

with

\[
\omega_\oplus
=
\frac{2\pi}{T_{\rm sid}},
\qquad
T_{\rm sid}\approx 86164.09\ \mathrm{s}.
\]

The sidereal day is about 23 h 56 min 4 s. It is the period for one complete Earth rotation relative to distant inertial directions—not relative to the Sun.

## How regular is Earth’s rotation?

Earth’s spin is highly stable but not a perfect uniform rotation. The monitored quantity is the **length of day** (LOD): its departure from 86,400 SI seconds. The International Earth Rotation and Reference Systems Service (IERS) measures and publishes Earth-orientation data, including UT1 and LOD. [iers](https://www.iers.org/IERS/EN/Science/EarthRotation/UT1LOD.html)

The instantaneous angular speed and length of day satisfy approximately

\[
\omega
=
\frac{2\pi}{\mathrm{LOD}}.
\]

For a small excess \(\Delta\mathrm{LOD}\) over 86,400 s,

\[
\frac{\Delta\omega}{\omega}
\approx
-\frac{\Delta\mathrm{LOD}}{86400\ \mathrm{s}}.
\]

For example, a 1 ms lengthening of the day gives a fractional spin-rate change of only

\[
\frac{\Delta\omega}{\omega}
\approx
-1.16\times10^{-8}.
\]

The sources of real variation include:

- **Solid-Earth and ocean tides**, which produce periodic short-term changes.
- **Atmospheric angular-momentum exchange**: large-scale winds redistribute angular momentum between atmosphere and solid Earth.
- **Ocean circulation and hydrology**: moving water changes Earth’s moment of inertia and angular momentum distribution.
- **Core–mantle coupling**: flow in the liquid outer core can drive changes on multi-year to decadal scales.
- **Tidal braking by the Moon**: a very long-term trend that gradually slows Earth’s rotation.

IERS reports zonal tidal LOD variations below about 2.5 ms in magnitude, ocean-tide effects below about 0.03 ms, plus atmospheric, internal, and lunar angular-momentum effects.  NASA describes the long-term tidal contribution as an increase in day length of roughly 2.3 ms per century, though shorter-term fluctuations can be much larger than the smooth secular trend over an individual year. [iers](https://www.iers.org/IERS/EN/Science/EarthRotation/UT1LOD.html)

## Perihelion vs. aphelion

There are two different questions that are easy to mix up.

| Quantity | Does it change between perihelion and aphelion? | Main reason |
|---|---|---|
| Earth’s physical sidereal rotation period | Not in a meaningful deterministic way from orbital position alone | Spin is governed mainly by Earth’s angular momentum, tides, atmosphere, oceans, and core dynamics |
| Earth’s orbital angular speed around the Sun | Yes | Kepler’s second law |
| Length of the mean civil day | Defined as 86,400 SI seconds | UTC convention, adjusted against UT1 historically through leap seconds |
| Apparent solar day | Yes, seasonally | Earth must rotate extra to catch up with changing Sun direction; orbital angular speed is greater near perihelion |
| Solar declination / seasonal geometry | Yes | The tilted spin axis retains nearly fixed inertial direction during the orbit |

Thus:

\[
\boxed{
T_{\rm sidereal\ spin}(\text{perihelion})
\approx
T_{\rm sidereal\ spin}(\text{aphelion}).
}
\]

Any actual difference depends on Earth-orientation measurements over specific dates, rather than a simple formula involving the major or minor axes of the orbit.

Also, the extrema of the **major axis** are perihelion and aphelion. The endpoints of the **minor axis** occur at true anomalies

\[
\nu=\frac{\pi}{2},
\qquad
\nu=\frac{3\pi}{2},
\]

where the Sun–Earth distance is

\[
r=a(1-e^2).
\]

They are not the closest or farthest locations. For Earth’s modest eccentricity, the minor-axis points are close to—but not exactly at—the mean orbital radius.

## Why the solar day changes

A solar day measures the interval between successive meridian crossings of the Sun. During one spin, Earth advances in its orbit, so it must rotate slightly more than \(2\pi\) relative to inertial space to bring the Sun back to the same local meridian.

Let:

\[
\omega_\oplus
\]

be Earth’s inertial spin angular speed, and let

\[
\dot\lambda_\odot
\]

be the apparent angular rate of the Sun along the ecliptic as seen from Earth. Ignoring axial tilt for the moment, the apparent solar angular speed is

\[
\omega_{\rm solar}
=
\omega_\oplus-\dot\lambda_\odot.
\]

Therefore,

\[
\boxed{
T_{\rm solar}
=
\frac{2\pi}{\omega_\oplus-\dot\lambda_\odot}.
}
\]

Because \(\dot\lambda_\odot\) is larger at perihelion, the apparent solar day is slightly longer there; it is shorter at aphelion.

At perihelion and aphelion, the orbital angular rate is

\[
\dot\nu_{\rm peri}
=
n\frac{\sqrt{1-e^2}}{(1-e)^2},
\]

\[
\dot\nu_{\rm aph}
=
n\frac{\sqrt{1-e^2}}{(1+e)^2}.
\]

For Earth, using \(e\approx0.0167\) and mean motion

\[
n\approx 0.9856^\circ/\text{day},
\]

these are approximately

\[
\dot\nu_{\rm peri}\approx1.019^\circ/\text{day},
\]

\[
\dot\nu_{\rm aph}\approx0.953^\circ/\text{day}.
\]

So the orbital angular advance differs by about

\[
\boxed{
0.066^\circ/\text{day}.
}
\]

In time terms, that is approximately

\[
\frac{0.066^\circ}{15^\circ/\text{hour}}
=
0.0044\ \text{hour}
\approx 16\ \text{s}
\]

of additional spin needed per mean solar day near perihelion relative to aphelion.

That is an idealized orbital contribution. For the Sun observed from a location on Earth, axial tilt also changes the mapping between ecliptic motion and right ascension. Together, orbital eccentricity and obliquity generate the familiar **equation of time**, which makes apparent solar time run ahead of or behind mean solar time by up to roughly a quarter hour during the year.

## Direct answer

If by “one full rotation” you mean an inertial, 360-degree rotation relative to distant stars:

\[
\boxed{
\text{There is no appreciable perihelion–aphelion difference caused by the elliptical orbit itself.}
}
\]

It remains approximately the sidereal period:

\[
\boxed{
T_{\rm sid}\approx86164.09\ \mathrm{s}.
}
\]

The actual departure on a particular day is usually discussed in milliseconds and must be obtained from Earth-orientation/LOD observations, not just orbital geometry. [iers](https://www.iers.org/IERS/EN/Science/EarthRotation/UT1LOD.html)

If you mean a rotation returning the **Sun** to the same local meridian:

\[
\boxed{
\text{the apparent solar day is longer near perihelion and shorter near aphelion.}
}
\]

From elliptical-orbit speed alone, the perihelion-versus-aphelion difference is about

\[
\boxed{\sim16\ \text{seconds per solar day}.}
\]

That is a seasonal apparent-solar-time effect, not a substantial speeding up or slowing down of Earth’s physical spin.

# Efficient 3D gravity simulation

A normal gravity simulation that calculates the force between every pair of the simulated particles runs in n squared time complexity. This does not scale well.

## Plan to reduce runtime complexity:
Instead of calculating the force between each individual pair of particles the following is done:

For purposes of making the whole thing easier to think about all of the explanation will be done in 2D. It scales seemlessly into 3D

- At every time step the space of the simulation is split into grids with individual fields of various sizes
- The total mass of particles in each field of the grid is calculated
- Now forces are not calculated between all pairs of particles, but between each particle and the surrounding grid fields. By surrounding only the ones directly bordering the one containing the particle

---

## Implementation

At every time step the following are calculated:

- For each Particle and each grid size, the grid field that particle is in. This is stored in a dedicated field of the Body struct: ```gridinfo```

- For every individual field size:
    - 

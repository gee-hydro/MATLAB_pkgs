smooth_HdH = function(y, w = 0 * y + 1, lambda = 1e4) {
    # Whittaker smoothing with second order differences
    # Computation of the hat diagonal (Hutchinson and de Hoog, 1986)
    # In: data vector (y), weigths (w), smoothing parameter (lambda)
    # Out: list with smooth vector (z), hat diagonal (dhat)
    # Paul Eilers, 2013
    # Prepare vectors to store system
    n     = length(y)
    g0    = rep(6, n)
    g0[1] = g0[n]      = 1
    g0[2] = g0[n - 1]  = 5
    g1    = rep(-4, n)
    g1[1] = g1[n-1]    = -2
    g1[n] = 0
    g2    = rep(1, n)
    g2[n  -1] = g2[n]  = 0
    # Store matrix G = W + lambda * D’ * D in vectors
    g0 = g0 * lambda + w
    g1 = g1 * lambda
    g2 = g2 * lambda

    # print(g0)
    # Compute U’VU decomposition (upper triangular U, diagonal V)
    u1 = u2 = v = rep(0, n)
    for (i in 1:n) {
        vi = g0[i]
        if (i > 1)
            vi = vi - v[i - 1] * u1[i - 1] ^ 2
        if (i > 2)
            vi = vi - v[i - 2] * u2[i - 2] ^ 2
        v[i] = vi
        if (i < n) {
            u = g1[i]
            if (i > 1)
                u = u - v[i - 1] * u1[i - 1] * u2[i - 1]
            u1[i] = u / vi
        }
        if (i < n - 1)
            u2[i] = g2[i] / vi
    }
    # print(u1)
    # print(u2)
    # Solve for smooth vector
    z = 0 * y
    for (i in 1:n) {
        zi = y[i] * w[i]
        if (i > 1)
            zi = zi - u1[i - 1] * z[i - 1]
        if (i > 2)
            zi = zi - u2[i - 2] * z[i - 2]
        z[i] = zi
    }
    z = z / v
    print(z)

    for (i in n:1) {
        zi = z[i]
        if (i < n)
            zi = zi - u1[i] * z[i + 1]
        if (i < n - 1)
            zi = zi - u2[i] * z[i + 2]
        z[i] = zi
    }
    s0 = s1 = s2 = rep(0, n)
    # Compute diagonal of inverse
    for (i in n:1) {
        i1 = i + 1
        i2 = i + 2
        s0[i] = 1 / v[i]
        if (i < n) {
            s1[i] =  - u1[i] * s0[i1]
            s0[i] = 1 / v[i] - u1[i] * s1[i]
        }
        if (i < n - 1) {
            s1[i] =  - u1[i] * s0[i1] - u2[i] * s1[i1]
            s2[i] =  - u1[i] * s1[i1] - u2[i] * s0[i2]
            s0[i] = 1 / v[i] - u1[i] * s1[i] - u2[i] * s2[i]
        }
    }

    r = (y - z) / (1 - s0)
    cve = sqrt(sum(r*r /length(y)))
    return(list(z = z, dhat = s0, cve))
}

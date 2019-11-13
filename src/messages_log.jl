# Same methods as in `messages.jl` but using the
# samples log-likelihood instead of the likelihood.

# In-place forward pass, where α and c are allocated beforehand.
function forwardlog!(α::AbstractMatrix, c::AbstractVector, a::AbstractVector, A::AbstractMatrix, LL::AbstractMatrix)
    @argcheck size(α, 1) == size(LL, 1) == size(c, 1)
    @argcheck size(α, 2) == size(LL, 2) == size(a, 1) == size(A, 1) == size(A, 2)

    T, K = size(LL)
    (T == 0) && return

    fill!(α, 0.0)
    fill!(c, 0.0)

    m = vec_maximum(view(LL, 1, :))

    for j in OneTo(K)
        α[1,j] = a[j] * exp(LL[1,j] - m)
        c[1] += α[1,j]
    end

    for j in OneTo(K)
        α[1,j] /= c[1]
    end

    c[1] *= exp(m) + eps()

    @inbounds for t in 2:T
        m = vec_maximum(view(LL, t, :))

        for j in OneTo(K)
            for i in OneTo(K)
                α[t,j] += α[t-1,i] * A[i,j]
            end
            α[t,j] *= exp(LL[t,j] - m)
            c[t] += α[t,j]
        end

        for j in OneTo(K)
            α[t,j] /= c[t]
        end

        c[t] *= exp(m) + eps()
    end
end

# In-place backward pass, where β and c are allocated beforehand.
function backwardlog!(β::AbstractMatrix, c::AbstractVector, a::AbstractVector, A::AbstractMatrix, LL::AbstractMatrix)
    @argcheck size(β, 1) == size(LL, 1) == size(c, 1)
    @argcheck size(β, 2) == size(LL, 2) == size(a, 1) == size(A, 1) == size(A, 2)

    T, K = size(LL)
    L = zeros(K)
    (T == 0) && return

    fill!(β, 0.0)
    fill!(c, 0.0)

    for j in OneTo(K)
        β[end,j] = 1.0
    end

    @inbounds for t in T-1:-1:1
        m = vec_maximum(view(LL, t+1, :))

        for i in OneTo(K)
            L[i] = exp(LL[t+1,i] - m)
        end

        for j in OneTo(K)
            for i in OneTo(K)
                β[t,j] += β[t+1,i] * A[j,i] * L[i]
            end
            c[t+1] += β[t,j]
        end

        for j in OneTo(K)
            β[t,j] /= c[t+1]
        end

        c[t+1] *= exp(m) + eps()
    end

    m = vec_maximum(view(LL, 1,:))

    for j in OneTo(K)
        c[1] += a[j] * exp(LL[1,j] - m) * β[1,j]
    end

    c[1] *= exp(m) + eps();
end

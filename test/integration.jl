using Test
using HMMBase
using Distributions
using Random

Random.seed!(2019)

hmms = [
    HMM([0.9 0.1; 0.1 0.9], [Normal(10,1), Gamma(1,1)]),
    HMM([0.9 0.1; 0.1 0.9], [Categorical([0.1, 0.2, 0.7]), Categorical([0.5, 0.5])]),
    HMM([0.9 0.1; 0.1 0.9], [MvNormal([0.0,0.0], [1.0,1.0]), MvNormal([10.0,10.0], [1.0,1.0])])
]

@testset "Integration $(typeof(hmm))" for hmm in hmms
    # HMM API
    @test hmm !== copy(hmm)

    z, y = rand(hmm, 1000, seq = true)
    @test size(z, 1) == size(y, 1)
    @test size(y, 2) == size(hmm, 2)

    yp = rand(hmm, z)
    @test size(z, 1) == size(y, 1)
    @test size(y, 2) == size(hmm, 2)

    L = likelihoods(hmm, y)
    LL = likelihoods(hmm, y, logl = true)
    @test size(L) == size(LL)

    # Forward/Backward
    α1, logtot1 = forward(hmm, y)
    α2, logtot2 = forward(hmm, y, logl = true)

    @test logtot1 ≈ logtot2
    @test α1 ≈ α2

    β1, logtot3 = backward(hmm, y)
    β2, logtot4 = backward(hmm, y, logl = true)

    @test logtot3 ≈ logtot4
    @test β1 ≈ β2

    logtot5 = loglikelihood(hmm, y)

    @test size(α1) == size(α2) == size(β1) == size(β2)
    @test logtot1 ≈ logtot2 ≈ logtot3 ≈ logtot4 ≈ logtot5

    γ1 = posteriors(hmm, y)
    γ2 = posteriors(hmm, y, logl = true)

    @test γ1 ≈ γ2

    # Viterbi
    zv1 = viterbi(hmm, y)
    zv2 = viterbi(hmm, y; logl = true)
    @test size(zv1) == size(zv2) == size(z)

    # MLE
    hmm2, _ = fit_mle(hmm, y, maxiter = 1)
    @test size(hmm2) == size(hmm)
    @test typeof(hmm2) == typeof(hmm)

    hmm2, _ = fit_mle(hmm, y, init = nothing)
    @test size(hmm2) == size(hmm)
    @test typeof(hmm2) == typeof(hmm)

    hmm2, _ = fit_mle(hmm, y, init = :kmeans, robust = true)
    @test size(hmm2) == size(hmm)
    @test typeof(hmm2) == typeof(hmm)
end

# Test edge cases (no observations, one observation)
@testset "Integration T=$T" for T in [0, 1]
    hmm = HMM([0.9 0.1; 0.1 0.9], [Normal(10,1), Normal(1,1)])

    z, y = rand(hmm, 0, seq = true)
    @test size(z, 1) == size(y, 1)
    @test size(y, 2) == size(hmm, 2)

    yp = rand(hmm, z)
    @test size(z, 1) == size(y, 1)
    @test size(y, 2) == size(hmm, 2)

    L = likelihoods(hmm, y)
    LL = likelihoods(hmm, y, logl = true)
    @test size(L) == size(LL)

    # Forward/Backward
    α1, logtot1 = forward(hmm, y)
    α2, logtot2 = forward(hmm, y, logl = true)

    @test logtot1 ≈ logtot2
    @test α1 ≈ α2

    β1, logtot3 = backward(hmm, y)
    β2, logtot4 = backward(hmm, y, logl = true)

    @test logtot3 ≈ logtot4
    @test β1 ≈ β2

    logtot5 = loglikelihood(hmm, y)

    @test size(α1) == size(α2) == size(β1) == size(β2)
    @test logtot1 ≈ logtot2 ≈ logtot3 ≈ logtot4 ≈ logtot5

    γ1 = posteriors(hmm, y)
    γ2 = posteriors(hmm, y, logl = true)

    @test γ1 ≈ γ2

    # Viterbi
    zv1 = viterbi(hmm, y)
    zv2 = viterbi(hmm, y; logl = true)
    @test size(zv1) == size(zv2) == size(z)

    # Utilities
    @test_nowarn gettransmat(z)
    @test_nowarn gettransmat(z, relabel = true)
end
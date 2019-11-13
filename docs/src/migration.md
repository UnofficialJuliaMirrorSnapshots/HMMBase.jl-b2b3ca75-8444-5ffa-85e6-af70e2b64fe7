# Migrating to v1.0

HMMBase v1.0 introduces the following breaking changes:
- `HMM` struct renaming: `π0, π, D` become `a, A, B`
- Methods renaming, see below for a full list
- Forward/Backward algorithms uses likelihood by default (instead of log-likelihoods), use the `logl` option to use log-likelihoods
- Baum-Welch algorithm returns `hmm, history` instead of `hmm, logtot`

## Deprecated/renamed methods

```julia
# @deprecate old new

@deprecate n_parameters(hmm) nparams(hmm)
@deprecate log_likelihoods(hmm, observations) likelihoods(hmm, observations, logl = true)

@deprecate forward_backward(init_distn, trans_matrix, log_likelihoods) posteriors(init_distn, trans_matrix, log_likelihoods, logl = true)
@deprecate messages_forwards(init_distn, trans_matrix, log_likelihoods) forward(init_distn, trans_matrix, log_likelihoods, logl = true)
@deprecate messages_backwards(init_distn, trans_matrix, log_likelihoods) backward(init_distn, trans_matrix, log_likelihoods, logl = true)

@deprecate forward_backward(hmm, observations) posteriors(hmm, observations, logl = true)
@deprecate messages_forwards(hmm, observations) forward(hmm, observations, logl = true)
@deprecate messages_backwards(hmm, observations) backward(hmm, observations, logl = true)

@deprecate messages_forwards_log(init_distn, trans_matrix, log_likelihoods) log.(forward(init_distn, trans_matrix, log_likelihoods, logl = true)[1])
@deprecate messages_backwards_log(trans_matrix, log_likelihoods) log.(backward(init_distn, trans_matrix, log_likelihoods, logl = true)[1])

@deprecate compute_transition_matrix(seq) gettransmat(seq, relabel = true)
@deprecate rand_transition_matrix(K, α = 1.0) randtransmat(K, α)
```

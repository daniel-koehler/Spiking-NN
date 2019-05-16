#include "models.h"

neuron_model_t vogelsabbott;
vogelsabbott = {
        .state_size = 5,
        .E_rest     = 0.0,
        .E_L        = -60.0,
        .E_ex       = 0.0,
        .E_in       = -80.0,
        .d_gex      = 0.27,
        .d_gin      = 4.5,
        .d_gstim    = 0.27,
        .E_avg      = 0.0,
        .I_inj      = 120.0,
        .R_L        = 0.1,
        .V_th       = 10.0,
        .tau_ref    = 5.0,
        .tau_ex     = 1.0 / 10.0,
        .tau_in     = 1.0 / 5.0,
        .tau_stim   = 1.0 / 10.0,
        .tau_L      = 1.0 / 20.0,
};
#ifndef MODEL_H

#define MODEL_H

typedef struct neuron_model_t
{
    int state_size;     // number of state variables
    float E_rest;
    float E_L;
    float E_ex;
    float E_in;
    float d_gex;
    float d_gin;
    float d_gstim;
    float E_avg;
    float I_inj;
    float R_L;
    float V_th;
    float tau_ref;
    float tau_ex;
    float tau_in;
    float tau_stim;
    float tau_L;
} neuron_model_t;

#endif
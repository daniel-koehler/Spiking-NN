#include <stdlib.h> // rand()
#include <stdio.h> // printf()
#include "models.h"

#define true 1
#define false 0

typedef struct neuron_t {
    int index;
    //int type; ?? not sure if this will be used
    float t_ela;
    float V_m;
    float g_Ex;
    float g_in;
    float g_stim;
} neuron_t;

typedef enum interpolation_t {
    NONE,
    LINEAR,
    QUADRATIC,
    CUBIC
} interpolation_t;

typedef struct sim_t {
    neuron_model_t model;

    // simulation parameters
    int h;             // simulation time step
    int n;             // total number of neurons
    float ratio_ex_in; // ratio of exc. to inh. neurons
    float p_conn;      // connection probability
    float min_delay;
    float max_delay;
    int rand_weights;
    int rand_delays;
    interpolation_t interpolation; // order of interpolation for exact spike timing

    float *state_mem
} sim_t;


void solve_analytic(sim_t *sim){// model.h
}

void create_network(){
    
}


int main(void){
    sim_t sim;
    float *state_mem;
    sim = (sim_t){
        .model = vogelsabbott,

        .h = 0.1,             
        .n = 1000,             
        .ratio_ex_in = 4.0, 
        .p_conn = 0.02,
        .min_delay = 0.1,
        .max_delay = 5.0,
        .rand_weights = false,
        .rand_delays = false,
        .interpolation = LINEAR,
    };

    /* initialize state memory */
    state_mem = (float *) malloc(sizeof(float)*sim.model.state_size);
    for(int i = 0; i< sim.n; i++){
        int idx = i * sim.model.state_size;
        state_mem[idx]     = sim.model.tau_ref;
        state_mem[idx + 1] = sim.model.E_rest;
        state_mem[idx + 2] = 0.0;
        state_mem[idx + 3] = 0.0;
        state_mem[idx + 4] = 0.0;
    }

    sim.state_mem = state_mem;
    printf("%f", vogelsabbott.E_rest);
}

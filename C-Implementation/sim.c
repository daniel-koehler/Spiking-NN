#include <stdlib.h> // rand()
#include <stdio.h> // printf()
#include <math.h>
#include "neuro.h"
#include "statebuf.h"
#include "interpolation.h"

#define true 1
#define false 0
#define frand() ((double) rand() / (RAND_MAX + 1.0))

/* Parameters for Vogels/Abbott network */
neuron_model_t va = {
        .state_size = 4,
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

/* Precalculate some constants to speed up calculation of integration factors */
#define c1 = (va.E_avg - va.E_ex) * va.R_L * va.tau_L / (va.tau_L - va.tau_ex);
#define c2 = (va.E_avg - va.E_in) * va.R_L * va.tau_L / (va.tau_L - va.tau_in);
#define c3 = va.I_inj * va.R_L;
#define c4 = (va.tau_L^2 + va.tau_ex*va.tau_in + va.tau_ex*va.tau_L + va.tau_in*va.tau_L)/((va.tau_ex + va.tau_L)*(va.tau_in + va.tau_L));


typedef enum interpolation_t {
    NONE,
    LINEAR,
    QUADRATIC,
    CUBIC
} interpolation_t;

typedef struct sim_t {
    neuron_model_t model;

    // simulation parameters
    float h;                        // simulation time step
    int n;                          // total number of neurons
    int n_ex;
    int n_in;
    int n_syn;
    float ratio_ex_in;              // ratio of exc. to inh. neurons
    float p_conn;                   // connection probability
    float min_delay;
    float max_delay;
    int rand_delays;

    float t_start;
    float t_end;
    float t_input;
    
    interpolation_t interpolation;  // order of interpolation for exact spike timing
    float *factors_h;               // integration factors for time step h

    spike_t *next_spike;
    spike_t *curr_spike;
    int spike_cnt;

    state_t *state_mem;             // stores state variables for each neuron
    state_buf_t *state_buf;
    synapse_t *synapses;            // stores synaptic connections between neurons
} sim_t;


void solve_analytic(sim_t *sim){// model.h
}

void integration_factors(float dt, float *factors){
    /*
    Calculate the integration factors for time interval dt and write them to factors.
    */
   /*
    factors[0] = dt;
    factors[1] = exp(-va.tau_ex * dt);
    factors[2] = exp(-va.tau_in * dt);
    factors[3] = exp(-va.tau_L * dt);
    factors[4] = (factors[3] - factors[1]) * c1;
    factors[5] = (factors[3] - factors[2]) * c2;
    factors[6] = exp(va.tau_L * dt) * c3 * (c4 - factors[3]);
    */
}

int compare_spikes(const void *p1, const void *p2){
    /*
    Compare function for qsort, that determines the interspike interval between the given spikes
    */
    spike_t *spike1 = *(spike_t **) p1;
    spike_t *spike2 = *(spike_t **) p2;

    if(spike1->t < spike2->t) return -1;
    if(spike1->t > spike2->t) return 1;
    else return 0;
}

void create_events(sim_t *sim, float t_start, float t_end, float t_avg){
    /*
    Creates a poisson distributed input spike train for each neuron.
    */
    int n = sim->n;
    int i;
    float dt;
    int     spike_cnt    = 0;
    spike_t *new_spike   = NULL;
    spike_t *first_spike = NULL;
    spike_t *next_spike  = NULL;

    for(i = 0; i < n; i++){
        for(float t = t_start; t <= t_end; ){
            dt  = -log(1.0 - frand()) * t_avg;
            t  += dt;

            if (t > t_end){
                break;
            }

            /* Create a new input spike */
            new_spike        = (spike_t *) malloc(sizeof(spike_t));
            new_spike->t     = t;
            new_spike->index = i;
            new_spike->next  = NULL;

            if (first_spike == NULL){
                sim->curr_spike = sim->next_spike = first_spike = new_spike;
            }
            else{
                next_spike->next = new_spike;
            }
            next_spike = new_spike;
            spike_cnt++;
        }
    }
    sim->spike_cnt = spike_cnt;

    /* Sort spikes */
    i             = 0;
    next_spike    = first_spike;
    spike_t **spike_array = (spike_t **) malloc(sizeof(spike_t *)*spike_cnt);
    while(next_spike){
        spike_array[i++] = next_spike;
        next_spike = next_spike->next;
    }
    qsort(spike_array, spike_cnt, sizeof(spike_t *), compare_spikes);
    for(i = 0; i < spike_cnt - 1; i++){
        spike_array[i]->next = spike_array[i+1];
    }
    spike_array[spike_cnt - 1]->next = NULL;
    sim->curr_spike = spike_array[0];
    free(spike_array);
}

void initialize_state_mem(sim_t *sim){
    /*
    Initialize state variables of all neurons
    */
    int i;
    state_t *state_mem;
	float h          = sim->h;
	int   state_size = sim->model.state_size;
	int   n          = sim->n;
	float max_delay  = sim->max_delay;
	float min_delay  = sim->min_delay;
	int   slots      = (max_delay-min_delay)/h + 1;

	int   slot_size  = n;
    sim->state_mem = state_mem = (state_t *) malloc(sizeof(state_t)*n);
    sim->state_buf = create_buffer(slots, slot_size);
    
    for(i = 0; i < n; i++){
        state_mem[i] = (state_t) {
            .t_ela  = sim->model.tau_ref,
            .V_m    = frand() * (sim->model.V_th - sim->model.E_rest) + sim->model.E_rest,
            .g_ex   = 0.0,
            .g_in   = 0.0};
    }  
}

void create_network(sim_t *sim){
    /*
    Create synapses that represent the neural network
    */
    int i, j, idx;
    int   n_syn      = sim->n_syn;
    int   n          = sim->n;
    int   n_ex       = sim->n_ex;
    int   n_in       = sim->n_in;
    float max_delay  = sim->max_delay;
    float min_delay  = sim->min_delay;
    int   state_size = sim->model.state_size;
    float delay, weight;
    synapse_t *synapses = (synapse_t *) malloc(sizeof(synapse_t)*n_syn*n);
    for(i = 0; i < n; i++){
        for(j = 0; j < n_syn; j++){
            idx = i * n_syn + j;

            /* Target index */
            synapses[idx].target = floor(frand()*n);

            /* Synaptic propagation delays */
            if(sim->rand_delays){               
                // TODO: let delays be multiple of h
                delay = frand()*(max_delay - min_delay) + min_delay;
            }
            else     delay      = min_delay;
            synapses[idx].delay = delay;

            /* Synaptic weights */
            if(i < n_ex){
                weight = sim->model.d_gex;
                synapses[idx].type = 1;
            }
            else{
                weight = sim->model.d_gin;
                synapses[idx].type = 0;
            }
            synapses[idx].weight = weight;            
        }
    }
    sim->synapses = synapses;
}

sim_t *setup_sim(void){
    /*
    Set simulation parameters, initalize memory, generate stimulus
    */

    sim_t *sim = (sim_t *) malloc(sizeof(sim_t));
    float h;
    int   n;
    int   n_ex;
    float ratio;
    float p_conn;
    float t_start;
    float t_end;
    float t_input;
    float t_avg   = 4.0;

    sim->h       = h       = 0.1;
    sim->t_start = t_start = 0.0;
    sim->t_end   = t_end   = 100.0;
    sim->t_input = t_input = 50.0;

    sim->n           = n      = 100;
    sim->ratio_ex_in = ratio  = 4;
    sim->p_conn      = p_conn = 0.02;
    sim->min_delay   = sim->h;

    sim->n_ex  = n_ex = floor(n * ratio / (ratio + 1));
    sim->n_in  = n - n_ex;
    sim->n_syn = (n - 1) * p_conn;

    sim->model       = va;
    sim->curr_spike = (spike_t *) malloc(sizeof(spike_t));
    sim->next_spike  = (spike_t *) malloc(sizeof(spike_t));
    sim->min_delay   = h;
    sim->max_delay   = h+0.1;
    sim->rand_delays = false;
    
    create_events(sim, t_start, t_input, t_avg);

    create_network(sim);

    initialize_state_mem(sim);

    sim->factors_h = (float *) malloc(sizeof(float) * 7);
    integration_factors(h, sim->factors_h);
    
    return(sim);
}

void print_state_mem(sim_t *sim){
    state_t *state_mem = sim->state_mem;
    int   n          = sim->n;
    int   index      = 0;
    for(int i=0; i<n; i++){
        printf("Time:\t%f\n", state_mem[i].t_ela);
        printf("Voltage:\t%f\n", state_mem[i].V_m);
        printf("gEx:\t%f\n", state_mem[i].g_ex);
        printf("gIn:\t%f\n", state_mem[i].g_in);
    }
}

void print_spikes(sim_t *sim){
    spike_t *curr_spike = sim->curr_spike;
    while(curr_spike){
        printf("Neuron %i at %f ms\n", curr_spike->index, curr_spike->t);
        curr_spike = curr_spike->next;
    }
}

void simulation_loop(sim_t *sim){
    /*
    Main loop of the time based simulation
    */

    float t_start = sim->t_start;
    float t_end = sim->t_end;
    float t_input = sim->t_input;
    float t;
    float h = sim->h;
    for(t=t_start; t <= t_end; t+=h){
    }
}

int main(void){
    sim_t *sim = setup_sim();
    
    state_buf_read(sim->state_buf);
    state_t *states = (state_t *) malloc(sizeof(state_t) * sim->n);
    state_buf_write(sim->state_buf, states, sim->n, 0);
    state_t *state = (state_t *) malloc(sizeof(state_t));
    state_buf_add(sim->state_buf, state, 3, 3);
    //printf("%f, %f\n", sim->state_mem[0], sim->model.tau_ref);
    //print_state_mem(sim);
    //print_spikes(sim);
}


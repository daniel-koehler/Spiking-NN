syms h
syms V0 Vh dV0 dVh ddV0 ddVh dddV0 dddVh

% linear
vandermonde = [0 1;
               h 1];
V = [V0 Vh];
coeff1 = inv(vandermonde) * transpose(V);

% quadratic
vandermonde = [0 0 1;
               h^2 h 1;
               0 1 0]; 
V = [V0 Vh dV0];  
coeff2 = inv(vandermonde) * transpose(V);

% cubic
vandermonde = [0 0 0 1;
               h^3 h^2 h 1;
               0 0 1 0;
               3*h^2 2*h 1 0];           
V = [V0 Vh dV0 dVh];
coeff3 = inv(vandermonde) * transpose(V);

% quartic
vandermonde = [0 0 0 0 1;
               h^4 h^3 h^2 h 1;
               0 0 0 1 0;
               4*h^3 3*h^2 2*h 1 0;
               0 0 1 0 0];
V = [V0 Vh dV0 dVh ddV0];  
coeff4 = inv(vandermonde) * transpose(V);

% quintic
vandermonde = [0 0 0 0 0 1;
               h^5 h^4 h^3 h^2 h 1;
               0 0 0 0 1 0;
               5*h^4 4*h^3 3*h^2 2*h 1 0;
               0 0 0 1 0 0;
               20*h^3 12*h^2 6*h 2 0 0];
V = [V0 Vh dV0 dVh ddV0 ddVh];  
coeff5 = inv(vandermonde) * transpose(V);

% sextic
vandermonde = [0 0 0 0 0 0 1;
               h^6 h^5 h^4 h^3 h^2 h 1;
               0 0 0 0 0 1 0;
               6*h^5 5*h^4 4*h^3 3*h^2 2*h 1 0;
               0 0 0 0 1 0 0;
               30*h^4 20*h^3 12*h^2 6*h 2 0 0;
               0 0 0 1 0 0 0];
V = [V0 Vh dV0 dVh ddV0 ddVh dddV0];  
coeff6 = inv(vandermonde) * transpose(V);

% septic
vandermonde = [0 0 0 0 0 0 0 1;
               h^7 h^6 h^5 h^4 h^3 h^2 h 1;
               0 0 0 0 0 0 1 0;
               7*h^6 6*h^5 5*h^4 4*h^3 3*h^2 2*h 1 0;
               0 0 0 0 0 1 0 0;
               42*h^5 30*h^4 20*h^3 12*h^2 6*h 2 0 0;
               0 0 0 0 1 0 0 0;
               210*h^4 120*h^3 60*h^2 24*h 6 0 0 0];
V = [V0 Vh dV0 dVh ddV0 ddVh dddV0 dddVh];  
coeff7 = inv(vandermonde) * transpose(V);



           
           

%coefficients = vandermonde\V;
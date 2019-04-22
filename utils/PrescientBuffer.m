classdef PrescientBuffer < handle
    properties
        dim
        buffer
        ptr
    end
    methods
        function self = PrescientBuffer(nNeurons, nStateVars, nSlots) 
            self.dim = [nNeurons, nStateVars, nSlots];
            self.buffer = zeros(nNeurons, nStateVars, nSlots);
            self.ptr = 1;                      
        end
        
        function out = read(self, next, varargin)
        % Returns stored state variables for current slot
        % Inputs:
        %   next:   true: clear current buffer slot and increment
        %           ptr. false: just return variables for current slot
        % Optional inputs:
        %   List/array of neuron indices for which state variables
        %   shall be returned. If omitted, state variables for all
        %   neurons are returned. Example: read(true, [2 3]) or 
        %   read(true, 2, 3) returns variables for neurons 2 and 3.
        % Returns:
        %   out:    n x m array, containing m state variables for n
        %           neurons
            if nargin > 2
                index = [varargin{:}];
                %n = size(index, 2);
            else
                index = ':';
                %n = self.dim(1);
            end             
            %out = reshape(self.buffer(index, :, self.ptr), n, self.dim(2));
            out = self.buffer(index, :, self.ptr);
            if next
                self.buffer(:, :, self.ptr) = 0;	% clear current time slot
                if self.ptr >= self.dim(3)
                   self.ptr = 1; 
                else
                    self.ptr = self.ptr + 1;
                end   
            end
        end
        
        function out = add(self, value, delay, varargin)
        % Increments buffer content by value at position self.ptr+delay.
        % Inputs:
        %   value:  1 x nStateVars array of state variables
        %   delay:  value is added at self.ptr + delay
        % Optional inputs:
        %   List/array of neuron indices for which state variables
        %   shall be updated. If omitted, state variables for all
        %   neurons are updated.
        % Returns:
        %   out:    n x m array, containing m updated state variables for n
        %           neurons
            if nargin > 3
                index = [varargin{:}];
            else
                index = ':';
            end
%             if numel(delay) > 1
%                 % Possible update: allow delay to be an array and split value to
%                 % corresponding delay. E.g. value=[1 2; 3 4], delay=[0, 1]
%                 % and index=[1 2], then buffer(1,pos,:)+=[1 2] and
%                 % buffer(2,pos,:)+=[3 4]. This would remove the necessity
%                 % to call add in a loop when assigning updates to neurons
%                 % with different synaptic delays.
%                 error("delay must be a single value.")
%             end
            pos = self.ptr + delay;
            pos(pos > self.dim(3)) = pos(pos > self.dim(3)) - self.dim(3);
            
            out = self.buffer(index, :, pos) + value;
            self.buffer(index, :, pos) = out;
        end
        
        function write(self, value, delay, varargin)
        % Write value at position self.ptr+delay into self.buffer.
        % Inputs:
        %   value:  1 x nStateVars array of state variables
        %   delay:  value is added at self.ptr + delay
        % Optional inputs:
        %   List/array of neuron indices for which state variables
        %   shall be updated. If omitted, state variables for all
        %   neurons are updated.
            if nargin > 3
                index = [varargin{:}];
            else
                index = ':';
            end
            pos = self.ptr + delay;
            pos(pos > self.dim(3)) = pos(pos > self.dim(3)) - self.dim(3);
            self.buffer(index, :, pos) = value;
        end
    end
end

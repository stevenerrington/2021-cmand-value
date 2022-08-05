function [RT] = LBA_trial_RT(A, b, v, t0, sv, N)
% Run a single trial of the LBA model (Brown & Heathcote, 2008, Cog
% Psychol)
%
% Usage: [choice RT conf] = LBA_trial(A, b, v, t0, sv, N)
%
% Inputs:
%
% A = range of uniform distribution U[0,A] from which starting point k is
% drawn
% b = bound
% v = vector of drift rates
% sv = standard deviation of drift rate
% t0 = non-decision time
% N = number of response options
%
% Outputs:
%
% choice = scalar from 1:N indicating response chosen by model
% RT = reaction time in ms
% confidence = confidence computed using balance of evidence rule (Vickers,
% 1979)
%
% SF 2012

trialOK = false;

while ~trialOK
    for i = 1:N
        
        % Get starting point
        k(i) = rand.*A(i);
        
        % Get drift rate
        d(i) = normrnd(v(i), sv(i));
        
        % Get time to threshold
        t(i) = (b(i)-k(i))./d(i);
        
        % Add on non-decision time
        RT(i) = t0(i) + t(i);
    end
    
    trialOK = true;

end
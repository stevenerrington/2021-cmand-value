function [v, A, b, sv, t0] = LBA_parse_update(model, params, Ncond)
% Parse parameter vector for fitting LBA
%
% SE 2022

varStrInd = find(cellfun(@ischar,params));

for iv = 1:length(varStrInd)
    switch params{varStrInd(iv)}
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Drift rate
        case {'v'}
            % If fixed:
            if model.v == 1
                v = repmat(params{varStrInd(iv)+1}, Ncond, 1);
                
                % If variable
            elseif  model.v == Ncond
                for condition_i = 1:Ncond
                    v(condition_i,:) = params{varStrInd(iv)+1}{condition_i};
                end
                
                % If neither, then there is an issue.
            else
                err = 1;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Start point
        case {'A'}
            % If fixed:
            if model.A == 1
                A = repmat(params{varStrInd(iv)+1}, Ncond, 1);
                
                % If variable
            elseif  model.A == Ncond
                for condition_i = 1:Ncond
                    A(condition_i,:) = params{varStrInd(iv)+1}{condition_i};
                end
                
                % If neither, then there is an issue.
            else
                err = 1;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Threshold
        case {'b'}
            % If fixed:
            if model.b == 1
                b = repmat(params{varStrInd(iv)+1}, Ncond, 1);
                
                % If variable
            elseif  model.b == Ncond
                for condition_i = 1:Ncond
                    b(condition_i,:) = params{varStrInd(iv)+1}{condition_i};
                end
                
                % If neither, then there is an issue.
            else
                err = 1;
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Start point
        case {'sv'}
            % If fixed:
            if model.sv == 1
                sv = repmat(params{varStrInd(iv)+1}, Ncond, 1);
                
                % If variable
            elseif  model.sv == Ncond
                for condition_i = 1:Ncond
                    sv(condition_i,:) = params{varStrInd(iv)+1}{condition_i};
                end
                
                % If neither, then there is an issue.
            else
                err = 1;
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Onset
        case {'t0'}
            % If fixed:
            if model.t0 == 1
                t0 = repmat(params{varStrInd(iv)+1}, Ncond, 1);
                
                % If variable
            elseif  model.t0 == Ncond
                for condition_i = 1:Ncond
                    t0(condition_i,:) = params{varStrInd(iv)+1}{condition_i};
                end
                
                % If neither, then there is an issue.
            else
                err = 1;
            end
            
            
    end
end

end


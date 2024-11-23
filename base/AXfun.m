%%  
%  Author: Hantao Nie (nht@pku.edu.cn)
%  Date: 2023-09-08 14:40:39
%  LastEditors: Hantao Nie (nht@pku.edu.cn)
%  LastEditTime: 2023-10-11 21:03:49
%  Description: 
%  
%  Copyright (c) 2023, Hantao Nie, Peking University. 
%   
%%
%  Author: Hantao Nie (nht@pku.edu.cn)
%  Date: 2023-09-08 14:40:39
%  LastEditors: Hantao Nie (nht@pku.edu.cn)
%  LastEditTime: 2023-09-22 19:31:06
%  Description:
%
%  Copyright (c) 2023, Hantao Nie, Peking University.
%
%%
%  Author: Hantao Nie (nht@pku.edu.cn)
%  Date: 2023-09-08 14:40:39
%  LastEditors: Hantao Nie (nht@pku.edu.cn)
%  LastEditTime: 2023-09-13 16:26:41
%  Description:
%
%  Copyright (c) 2023, Hantao Nie, Peking University.
%
%% compute AX = A * X

%% A * X
function AX = AXfun(K, At, X)
if iscell(At) 
    m = size(At{1}, 2);
    AX = zeros(m, 1);
%     x = [];
%     AXtt = [];
    for p = 1:length(K)
        cone = K{p};
        if isempty(At{p})
            continue;
        end
        Xp = X{p};
        if strcmp(cone.type, 's')
            % if isa(X{p}, "Var_sdp")  % X{p} is Var_sdp object
            %    x = mysvec(X{p});
            %    AX = AX + (x'*At{p})';
            % else % X{p} is one single matrix or vector.
            if length(cone.size) > 1
                Xp = sparse(Xp);
            end
            
            if size(X{p}, 1) == sum(cone.size .* (cone.size + 1) / 2) % X{p} is in vector form
                AX = AX + (Xp' * At{p})';
            elseif size(X{p}, 1) == sum(cone.size) % X{p} is in matrix form
%                 x = mysvec(cone, Xp);
                x = mexsvec({cone.type, cone.size}, Xp);
%                 AXtt = [AXtt;At{p} ];
                AX = AX + (x' * At{p})';
            else
                error('AXfun: dimension mismatch for block %i', p);
            end
        else
            AX = AX + (X{p}' * At{p})';
        end
    end
%     AX = AXtt'*x;
else % At is a single matrix
    cone = K;
    if strcmp(cone.type, 's')

        if (isempty(At))
            AX = [];
        elseif (length(cone.size) == 1)
            AX = (mexsvec_sdpnal({cone.type, cone.size}, X)' * At)';
        else
            AX = (mexsvec_sdpnal({cone.type, cone.size}, sparse(X))' * At)';
        end
    else
        if (isempty(At))
            AX = [];
        else
            AX = (X' * At)';
        end

    end
    
end

end

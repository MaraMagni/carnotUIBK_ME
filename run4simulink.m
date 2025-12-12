%% run4simulink.m
% ***********************************************************************
% This file is part of the uibkCARNOT Blockset.
% 
% Copyright (c) 2016-2019, University of Innsbruck, Unit for Energy 
% Efficient Building.
%   Dietmar Siegele     dietmar.siegele@uibk.ac.at
%   Eleonora Leonardi   eleonora.leonardi@uibk.ac.at
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% 4. For this specific file all changes or trying to copy and/or modifiy it 
%    are strictly forbidden. There is no further use of this file allowed
%    in any kind of different use than in carnotUIBK.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% **********************************************************************
% 
%% carnotUIBK version 2.0
% Copyright (c) 2016-2019, University of Innsbruck, Unit for Energy 
% Efficient Building.
% 
% Author    Date         Description
% DS,EL     2017-03-12   initial revision
% DS,EL	    2019-01-24   updates for GUI v2.0

%%
check_building

%% variant control condition matrices
conditions_zone = (-1)*ones(NUMBEROFZONES,1);
conditions_intersection = zeros(NUMBEROFZONES,NUMBEROFZONES);
conditions_zone_wall = (-1)*ones(NUMBEROFWALLSINZONES,4,NUMBEROFZONES);
conditions_zone_window = (-1)*ones(NUMBEROFWINDOWSINZONES,4,NUMBEROFZONES);
conditions_intersection_wall = (-1)*ones(NUMBEROFWALLSININTERSECTIONS,4,NUMBEROFZONES,NUMBEROFZONES);
conditions_zone_gains = (-1)*ones(NUMBEROFGAINSINZONES,4,NUMBEROFZONES);

%% VARIANTS for SIMULINK
% zones
for jj = 1:length(conditions_zone)
    % 0 and -1 are switched off! 0 has an intersection!
    eval(['V_z' num2str(jj) '_m1 = Simulink.Variant(''conditions_zone(' num2str(jj) ') == 1'');']);  % ideal
    eval(['V_z' num2str(jj) '_m2 = Simulink.Variant(''conditions_zone(' num2str(jj) ') == 2'');']);  % 1-node
    eval(['V_z' num2str(jj) '_m3 = Simulink.Variant(''conditions_zone(' num2str(jj) ') == 3'');']);  % 2-node
    eval(['V_z' num2str(jj) '_m4 = Simulink.Variant(''conditions_zone(' num2str(jj) ') == 4'');']);  % 1-node wo mass
end

% walls
for jj = 1:size(conditions_zone_wall,3)         % zones
    for jk = 1:size(conditions_zone_wall,1)     % walls
        % -1 is switched off!!
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_m0 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',1,' num2str(jj) ') == 0) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % UA
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_m1 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',1,' num2str(jj) ') == 1) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % RC
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_m2 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',1,' num2str(jj) ') == 2) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % hygrothermal
        
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_hti0 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',3,' num2str(jj) ') == 0)'');']);  % horizontal
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_hti1 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',3,' num2str(jj) ') == 1)'');']);  % up
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_hti2 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',3,' num2str(jj) ') == 2)'');']);  % down
        
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_hte0 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',4,' num2str(jj) ') == 0)'');']);  % AMBIENT
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_hte1 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',4,' num2str(jj) ') == 1)'');']);  % GROUND
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_hte2 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',4,' num2str(jj) ') == 2)'');']);  % INTERNAL
        eval(['V_z' num2str(jj) '_w' num2str(jk) '_hte3 = Simulink.Variant(''(conditions_zone_wall(' num2str(jk) ',4,' num2str(jj) ') == 3)'');']);  % NEIGHBOUR
    end
end

% windows and infiltration
for jj = 1:size(conditions_zone_window,3)         % zones
    for jk = 1:size(conditions_zone_window,1)     % windows
        % -1 is switched off!!
        eval(['V_z' num2str(jj) '_wi' num2str(jk) '_m0 = Simulink.Variant(''(conditions_zone_window(' num2str(jk) ',1,' num2str(jj) ') == 0) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % TF
        eval(['V_z' num2str(jj) '_wi' num2str(jk) '_m1 = Simulink.Variant(''(conditions_zone_window(' num2str(jk) ',1,' num2str(jj) ') == 1) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % RC
        eval(['V_z' num2str(jj) '_wi' num2str(jk) '_m2 = Simulink.Variant(''(conditions_zone_window(' num2str(jk) ',1,' num2str(jj) ') == 2) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % TF with shading
        eval(['V_z' num2str(jj) '_wi' num2str(jk) '_m3 = Simulink.Variant(''(conditions_zone_window(' num2str(jk) ',1,' num2str(jj) ') == 3) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % RC and WINDOW
        
        eval(['V_z' num2str(jj) '_inf' num2str(jk) '_m0 = Simulink.Variant(''(conditions_zone_window(' num2str(jk) ',2,' num2str(jj) ') == 0) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % constant volume flow
        eval(['V_z' num2str(jj) '_inf' num2str(jk) '_m1 = Simulink.Variant(''(conditions_zone_window(' num2str(jk) ',2,' num2str(jj) ') == 1) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % pressure difference
    end
end

% gains
for jj = 1:size(conditions_zone_gains,3)         % zones
    for jk = 1:size(conditions_zone_gains,1)     % gains
        % -1 is switched off!!
        eval(['V_z' num2str(jj) '_i' num2str(jk) '_m0 = Simulink.Variant(''(conditions_zone_gains(' num2str(jk) ',1,' num2str(jj) ') == 0) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % people
        eval(['V_z' num2str(jj) '_i' num2str(jk) '_m1 = Simulink.Variant(''(conditions_zone_gains(' num2str(jk) ',1,' num2str(jj) ') == 1) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % light
        eval(['V_z' num2str(jj) '_i' num2str(jk) '_m2 = Simulink.Variant(''(conditions_zone_gains(' num2str(jk) ',1,' num2str(jj) ') == 2) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % electricity
        eval(['V_z' num2str(jj) '_i' num2str(jk) '_m3 = Simulink.Variant(''(conditions_zone_gains(' num2str(jk) ',1,' num2str(jj) ') == 3) && (conditions_zone(' num2str(jj) ') > 0)'');']);  % moisture
    end
end

% walls intersection
for jj = 1:size(conditions_zone,1)         % intersection 1
    for jk = (jj+1):size(conditions_zone,1)    % intersection 2
        for jkk = 1:size(conditions_intersection_wall,1)     % walls
            % -1 is switched off!!
            eval(['V_i_' num2str(jj) '_' num2str(jk) '_w' num2str(jkk) '_m0 = Simulink.Variant(''(conditions_intersection_wall(' num2str(jkk) ',1,' num2str(jj) ',' num2str(jk) ') == 0) && (conditions_intersection(' num2str(jj) ',' num2str(jk) ') > 0)'');']);  % UA
            eval(['V_i_' num2str(jj) '_' num2str(jk) '_w' num2str(jkk) '_m1 = Simulink.Variant(''(conditions_intersection_wall(' num2str(jkk) ',1,' num2str(jj) ',' num2str(jk) ') == 1) && (conditions_intersection(' num2str(jj) ',' num2str(jk) ') > 0)'');']);  % RC
            eval(['V_i_' num2str(jj) '_' num2str(jk) '_w' num2str(jkk) '_m2 = Simulink.Variant(''(conditions_intersection_wall(' num2str(jkk) ',1,' num2str(jj) ',' num2str(jk) ') == 2) && (conditions_intersection(' num2str(jj) ',' num2str(jk) ') > 0)'');']);  % hygrothermal
            
            eval(['V_i_' num2str(jj) '_' num2str(jk) '_w' num2str(jkk) '_hti0 = Simulink.Variant(''(conditions_intersection_wall(' num2str(jkk) ',3,' num2str(jj) ',' num2str(jk) ') == 0) && (conditions_intersection(' num2str(jj) ',' num2str(jk) ') > 0)'');']);  % horizontal
            eval(['V_i_' num2str(jj) '_' num2str(jk) '_w' num2str(jkk) '_hti1 = Simulink.Variant(''(conditions_intersection_wall(' num2str(jkk) ',3,' num2str(jj) ',' num2str(jk) ') == 1) && (conditions_intersection(' num2str(jj) ',' num2str(jk) ') > 0)'');']);  % up
            eval(['V_i_' num2str(jj) '_' num2str(jk) '_w' num2str(jkk) '_hti2 = Simulink.Variant(''(conditions_intersection_wall(' num2str(jkk) ',3,' num2str(jj) ',' num2str(jk) ') == 2) && (conditions_intersection(' num2str(jj) ',' num2str(jk) ') > 0)'');']);  % down
            
            eval(['V_i_' num2str(jj) '_' num2str(jk) '_inf' num2str(jkk) '_m0 = Simulink.Variant(''(conditions_intersection_wall(' num2str(jkk) ',4,' num2str(jj) ',' num2str(jk) ') == 0) && (conditions_intersection(' num2str(jj) ',' num2str(jk) ') > 0)'');']);  % Gabriel
            eval(['V_i_' num2str(jj) '_' num2str(jk) '_inf' num2str(jkk) '_m1 = Simulink.Variant(''(conditions_intersection_wall(' num2str(jkk) ',4,' num2str(jj) ',' num2str(jk) ') == 1) && (conditions_intersection(' num2str(jj) ',' num2str(jk) ') > 0)'');']);  % Eli
        end
    end
end

%% condition matrices
for jj = 1:size(conditions_zone_wall,3)
    % zones
    conditions_zone(jj) = building.get_building().thermalzone.zone(jj).model;
    
    % walls
    for jk = 1:size(building.get_building().thermalzone.zone(jj).matrix_wd,1)
        conditions_zone_wall(jk,1,jj) = building.get_building().thermalzone.zone(jj).matrix_wd{jk,7};  % model of wall
        conditions_zone_wall(jk,2,jj) = building.get_building().thermalzone.zone(jj).matrix_wd{jk,8};  % model of heat transfer
        if (building.get_building().thermalzone.zone(jj).matrix_wd{jk,4} < 45)
            conditions_zone_wall(jk,3,jj) = 1;  % up
        elseif (building.get_building().thermalzone.zone(jj).matrix_wd{jk,4} > 135)
            conditions_zone_wall(jk,3,jj) = 2;  % down
        else
            conditions_zone_wall(jk,3,jj) = 0;  % horizontal
        end
        switch building.get_building().thermalzone.zone(jj).matrix_wd{jk,3}
            case 'AMBIENT'
                conditions_zone_wall(jk,4,jj) = 0;
            case 'GROUND'
                conditions_zone_wall(jk,4,jj) = 1;
            case 'INTERNAL'
                conditions_zone_wall(jk,4,jj) = 2;
            case 'NEIGHBOUR'
                conditions_zone_wall(jk,4,jj) = 3;
            otherwise
                conditions_zone_wall(jk,1,jj) = -1;
        end
    end
    
    % windows
    for jk = 1:size(building.get_building().thermalzone.zone(jj).matrix_wi,1)
        conditions_zone_window(jk,1,jj) = building.get_building().thermalzone.zone(jj).matrix_wi{jk,8};  % model of window
    end
    
    % infiltration
    for jk = 1:size(building.get_building().thermalzone.zone(jj).matrix_wi,1)
        conditions_zone_window(jk,2,jj) = building.get_building().thermalzone.zone(jj).matrix_wi{jk,19};  % model of infiltration
    end
    if conditions_zone_window(1,2,jj) < 0
        conditions_zone_window(1,2,jj) = 0;
    end
    
    % int gains
    for jk = 1:size(building.get_building().thermalzone.zone(jj).matrix_gains,1)
        conditions_zone_gains(jk,1,jj) = building.get_building().thermalzone.zone(jj).matrix_gains{jk,2};  % model of gains
    end
end

for jj = 1:size(conditions_zone,1)         % intersection 1
    for jk = (jj+1):size(conditions_zone,1)    % intersection 2
        % intersection
        if (conditions_zone(jj) >= 0) && (conditions_zone(jk) >= 0)
            conditions_intersection(jj,jk) = 1;
        end
        
        % walls
        for jkk = 1:size(building.get_building().thermalzone.intersection{jj,jk}.matrix_wd,1)
            conditions_intersection_wall(jkk,1,jj,jk) = building.get_building().thermalzone.intersection{jj,jk}.matrix_wd{jkk,7};  % model of wall
            conditions_intersection_wall(jkk,2,jj,jk) = building.get_building().thermalzone.intersection{jj,jk}.matrix_wd{jkk,8};  % model of heat transfer
            if (building.get_building().thermalzone.intersection{jj,jk}.matrix_wd{jkk,4} < 45)
                conditions_intersection_wall(jkk,3,jj,jk) = 1;  % up
            elseif (building.get_building().thermalzone.intersection{jj,jk}.matrix_wd{jkk,4} > 135)
                conditions_intersection_wall(jkk,3,jj,jk) = 2;  % down
            else
                conditions_intersection_wall(jkk,3,jj,jk) = 0;  % horizontal
            end
            % air exchange
            % conditions_intersection_wall(jkk,4,jj,jk) = building.get_building().thermalzone.intersection{jj,jk}.matrix_wd{jkk,13};  % model of infiltration
        end
    end
end

clear jj jk jkk

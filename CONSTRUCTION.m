
%% CONSTRUCTION.m
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
% DS,EL     2017-03-12   initial revision v1.0
% DS        2017-03-16   v1.1: fixed several bugs for empty cells reading
%                        PHPP file
% EL        2018-04-12   v1.3: new functions "construction_from_EXCEL" and
%                        "construction_windows_from_EXCEL" and some other
%                        correlated private functions
%                        doors and thermal bridges implemented in the PHPP
%                        reading
% DS,EL	    2019-01-29   updates for GUI v2.0

%%
classdef CONSTRUCTION
    % CONSTRUCTION
    
    properties
        name = 'new construction';
        structure = [];
    end
    
    methods
        function obj = CONSTRUCTION()
            
        end
        
        function obj = add_structure(obj, name, parameter, emission_1, emission_2, absorption_2)
            % to add a new structure
            % 1 ... name
            % 2 ... parameter file or parameter variable
            % 3 ... emission inside
            % 4 ... emission outside
            % 5 ... absorption outside
            if (nargin < 3) || (nargin > 6)
                error('Not a valid STRUCTURE!')
            end
            
            ind = [];
            for jj = 1:length(obj.structure)
                if strcmp(obj.structure(jj).name,name)
                    ind = strcmp(obj.structure(jj).name,name);
                    break
                end
            end
            
            if ind
                error(['structure ' name ' already existing!'])
            else
                if nargin == 3
                    obj.structure = [obj.structure STRUCTURE(name, parameter)];
                else
                    obj.structure = [obj.structure STRUCTURE(name, parameter, emission_1, emission_2, absorption_2)];
                end
            end
            
        end
        
        function structure = get_structure(obj, name)
            % to get a structure
            % 1 ... name of the structure
            ind = [];
            for jj = 1:length(obj.structure)
                if strcmp(obj.structure(jj).name,name)
                    ind = jj;
                    break
                end
            end
            
            
            if ind
                structure = obj.structure(ind);
            else
                structure = [];
%                 error(['structure ' name ' not existing!'])
            end
        end
        
        function obj = construction_from_PHPP(obj, name_xls_PHPP, language, version, model_cons_wall)
            % to add the construction of the walls that are in the PHPP
            % 1 ... name of the file xls of the PHPP
            % 2 ... language: 1:german, 0:english
            % 3 ... version of PHPP used
            % 4 ... model of the construction of the wall 'UA' or 'RC'
            
            filename = name_xls_PHPP;
            
            % if the user wants a RC model have to insert in excel 2
            % columns after the value of lambda with rho and C
            if strcmp(model_cons_wall,'UA')
                extra_column = 2;
            elseif strcmp(model_cons_wall,'RC')
                extra_column = 2;
            end
            
            switch version
                case '9.1'
                    if language
                        sheet = 'U-Werte';
                    else
                        sheet = 'U-Values';
                    end
                    range = 'L11:U425';
                    [~, ~, data]  = xlsread(filename, sheet, range);
                    interval = 21;
                    index_raw_name = 1;
                    index_column_name = 1:2;
                    index_raw_namelay = 7:14;
                    index_column_namelay = 1;
                    index_raw_lambdalay = 7:14;
                    index_column_lambdalay = 2;
                    index_raw_d = 7:14;
                    index_column_d = 8 + extra_column;
                    if strcmp(model_cons_wall,'RC')
                        index_column_rholay = 3;
                        index_column_clay = 4;
                    end
                    index_raw_Rsi = 3;
                    index_column_Rsi = 4;
                    index_raw_Rse = 4;
                    index_column_Rse = 4;
                    check_NaN = [];
                    check_NaN = (cellfun(@(V) any(isnan(V)),data));
                    for ii = index_raw_name(1):interval:size(data,1)
                        if check_NaN(ii,index_column_name(2))
                            last_str = ii;
                            break
                        end
                    end
                    
                case '10.2'
                    if language
                        sheet = 'U-Werte';
                    else
                        sheet = 'U-Values';
                    end
                    range = 'L8:T425';
                    [~, ~, data] = xlsread(filename, sheet, range);
                    interval = 21;
                    index_raw_name = 1;
                    index_column_name = [8,1];
                    index_raw_namelay = 6:13;
                    index_column_namelay = 1;
                    index_raw_lambdalay = 6:13;
                    index_column_lambdalay = 2;
                    index_raw_d = 6:13;
                    index_column_d = 7 + extra_column;
                    if strcmp(model_cons_wall,'RC')
                        index_column_rholay = 3;
                        index_column_clay = 4;
                    end
                    index_raw_Rsi = 17;
                    index_column_Rsi = 2;
                    index_raw_Rse = 18;
                    index_column_Rse = 2;
                    check_NaN = [];
                    check_NaN = (cellfun(@(V) any(isnan(V)),data));
                    for ii = index_raw_name(1):interval:size(data,1)
                        if check_NaN(ii,index_column_name(2))
                            last_str = ii;
                            break
                        end
                    end
                    
                    data(last_str:end,:) = [];
            end
            
            for ii = index_raw_name:interval:size(data,1)
                savename = [data{ii,index_column_name(1)} '-' data{ii,index_column_name(2)}];
                type = 0; % type of the structure: 0 ... wall, 1 ... window, 2 ... thermal bridge
                matr = data((index_raw_namelay(1)+ii-1:index_raw_namelay(end)+ii-1),index_column_namelay:index_column_d);
                check_NaN = [];
                check_NaN = (cellfun(@(V) any(isnan(V)),matr));
                d_layer = [];
                N_layer = [];
                lambda_layer = [];
                c_layer = [];
                rho_layer = [];
                colors = [];
                names = [];
                for ll = 1:index_raw_namelay(end)-index_raw_namelay(1)
                    if check_NaN(ll,index_column_namelay)
                        break
                    else
                        d_layer(ll) = data{index_raw_namelay(1)+ll-1+ii-1,index_column_d}*0.001;
                        lambda_layer(ll) = data{index_raw_namelay(1)+ll-1+ii-1,index_column_lambdalay};
                        if strcmp(model_cons_wall,'RC')
                            c_layer(ll) = data{index_raw_namelay(1)+ll-1+ii-1,index_column_clay};
                            rho_layer(ll) = data{index_raw_namelay(1)+ll-1+ii-1,index_column_rholay};
                        elseif strcmp(model_cons_wall,'UA')
                            c_layer(ll) = 1000;
                            rho_layer(ll) = 50;
                        end 
                        if d_layer(ll) < 0.015 % it is not possible to define a node if a layer has a thickness below 0.015m
                            N_layer(ll) = 0;
                        else
                            N_layer(ll) = 1;
                        end
                        
                        %delete layers with thickness = 0
                        pos=find(d_layer>0);
                        d_layer = d_layer(pos);
                        c_layer = c_layer(pos);
                        rho_layer = rho_layer(pos);
                        N_layer = N_layer(pos);
                        lambda_layer = lambda_layer(pos);
                        
                        colors(ll,:) = [0.85 0.85 0.85] * ((1-0.3)*rand(1)+0.3);
                        names{ll} = data{index_raw_namelay(1)+ll-1+ii-1,index_column_namelay};
                    end
                end
                
                
                if  sum(d_layer) 
                    R_si = 0.0;
                    R_se = 0.0;
                    T_dactive = -1;
                    Phi_active = -1;
                    [general.beuken.d general.beuken.lambda general.beuken.rho general.beuken.c general.beuken.tau_all general.beuken.D general.beuken.R general.beuken.U general.beuken.C general.beuken.tau] = wall_node_optim_(obj, d_layer, lambda_layer, rho_layer, c_layer, N_layer, T_dactive, R_si, R_se, 0); 
                    general.beuken.d_active = -1;
                    d = d_layer;
                    U = general.beuken.U;
                    layers_names = names;
                    layers_colors = colors;
                    xmesh_beu = general.beuken.d;
                    lambda = general.beuken.lambda;
                    rho = general.beuken.rho;
                    cp = general.beuken.c;
                    d_active = general.beuken.d_active;
                    tau = general.beuken.tau;
                    T_ini_beuken = 20;
                    if strcmp(model_cons_wall,'UA')
                        model = 0;
                        parameter.model = model;
                        parameter.type = type;
                        parameter.U = U;
                        parameter.Rsi = 0.0;
                        parameter.Rse = 0.0;
%                         parameter.N_layer = d; %not needed
%                         parameter.xmesh_beu = xmesh_beu; %d %not needed
%                         parameter.lambda = lambda; %not needed
%                         parameter.rho = rho; %not needed
%                         parameter.cp = cp; %not needed
%                         parameter.tau = tau; %not needed
                        parameter.T_ini_beuken = T_ini_beuken;
                        parameter.d_active = d_active;
                        parameter.T_dactive = T_dactive;
                        parameter.Phi_dactive = Phi_active;
%                         parameter.layers_N_layer = N_layer; %not needed
                        parameter.layers_names = layers_names;
                        parameter.layers_colors = layers_colors;
                        parameter.layers_lambda = lambda_layer;
%                         parameter.layers_rho = rho_layer; %not needed
%                         parameter.layers_cp = c_layer; %not needed
                        parameter.layers_d = d;
                        
                    elseif strcmp(model_cons_wall,'RC')
                        model = 1;
                        parameter.model = model;
                        parameter.type = type;
                        parameter.U = U; %calc by wall node optim
                        parameter.Rsi = 0.0;
                        parameter.Rse = 0.0;
                        %  parameter.N_layer = xmesh_beu; %not needed

                        parameter.xmesh_beu = xmesh_beu; %calc by wall node optim -> used for sim
                        parameter.lambda = lambda; %calc by wall node optim -> used for sim
                        parameter.rho = rho; %calc by wall node optim -> used for sim
                        parameter.cp = cp; %calc by wall node optim -> used for sim
                        parameter.tau = tau; %calc by wall node optim -> used for sim
                        parameter.T_ini_beuken = T_ini_beuken; %20 (PHPP does not have this info)
                        parameter.d_active = d_active; %-1 (PHPP does not have this info)  -> used for sim
                        parameter.T_dactive = T_dactive; %-1 (PHPP does not have this info) 
                        parameter.Phi_dactive = Phi_active; %-1 (PHPP does not have this info)
                        parameter.layers_N_layer = N_layer; %from PHPP

                        parameter.layers_names = layers_names;
                        parameter.layers_colors = layers_colors;
                        parameter.layers_lambda = lambda_layer; %from PHPP
                        parameter.layers_rho = rho_layer; %from PHPP
                        parameter.layers_cp = c_layer; %from PHPP
                        parameter.layers_d = d; %from PHPP
                    end
                    
                    
                    emission_1 = 0.94; % to be improved PHPP has this info  -> used for sim
                    emission_2 = 0.94; % to be improved PHPP has this info -> used for sim
                    absorption_2 = 0.65; % to be improved PHPP has this info -> used for sim
                    
                    obj = obj.add_structure(savename, parameter, emission_1, emission_2, absorption_2);
                end
            end
            
            clearvars parameter
            
            switch version
                case '9.1'
                    if language
                        sheet = 'Flächen';
                    else
                        sheet = 'Areas';
                    end
                    range = 'N40:AE40';
                    [~, ~, data_door] = xlsread(filename, sheet, range);
                    if data_door{3} == 0 || isnan(data_door{3})
                        warning('no door')
                    else
                        savename = data_door{1};
                        model = 0;
                        type = 0;
                        U = 1/(1/data_door{end}-0.13-0.04);
                        d = 0.10;
                        layers_names = {'Wood'};
                        layers_colors = [1 1 1] * ((1-0.3)*rand(1)+0.3);
                        parameter.model = model;
                        parameter.type = type;
                        parameter.U = U;
                        parameter.layers_d = d;
                        parameter.N_layer = 1;
                        parameter.xmesh_beu = d;
                        parameter.lambda = U * d;
                        parameter.rho = 650;
                        parameter.cp = 1700;
                        parameter.tau = parameter.rho*parameter.cp/2;
                        parameter.layers_names = layers_names;
                        parameter.layers_colors = layers_colors;
                        parameter.layers_lambda = U * d;
                        parameter.layers_rho = 650;
                        parameter.layers_cp = 1700;
                        parameter.layers_N_layer = 1;
                        parameter.T_ini_beuken = 20;
                        parameter.d_active = -1;
                        parameter.T_dactive = -1;
                        parameter.Phi_dactive = -1;
                        emission_1 = 0.94;
                        emission_2 = 0.94;
                        
                        obj = obj.add_structure(savename, parameter, emission_1, emission_2, 0);
                    end
                    
                     case '10.2'
                    if language
                        sheet = 'Flächen';
                    else
                        sheet = 'Areas';
                    end
                    range = 'L40:AC40';
                    [~, ~, data_door] = xlsread(filename, sheet, range);
                    if data_door{3} == 0 || isnan(data_door{3})
                        warning('no door')
                    else
                        savename = data_door{1};
                        model = 0;
                        type = 0;
                        U = 1/(1/data_door{end}-0.13-0.04);
                        d = 0.10;
                        layers_names = {'Wood'};
                        layers_colors = [1 1 1] * ((1-0.3)*rand(1)+0.3);
                        parameter.model = model;
                        parameter.type = type;
                        parameter.U = U;
                        parameter.layers_d = d;
                        parameter.N_layer = 1;
                        parameter.xmesh_beu = d;
                        parameter.lambda = U * d;
                        parameter.rho = 650;
                        parameter.cp = 1700;
                        parameter.tau = parameter.rho*parameter.cp/2;
                        parameter.layers_names = layers_names;
                        parameter.layers_colors = layers_colors;
                        parameter.layers_lambda = U * d;
                        parameter.layers_rho = 650;
                        parameter.layers_cp = 1700;
                        parameter.layers_N_layer = 1;
                        parameter.T_ini_beuken = 20;
                        parameter.d_active = -1;
                        parameter.T_dactive = -1;
                        parameter.Phi_dactive = -1;
                        emission_1 = 0.94;
                        emission_2 = 0.94;
                        
                        obj = obj.add_structure(savename, parameter, emission_1, emission_2, 0);
                    end
                    
            end
            clearvars parameter
            
        end
        
        function obj = constructiontbUA_from_PHPP(obj, name_xls_PHPP, language, version)
            % to add the construction of the thermal bridges that are in the PHPP
            % 1 ... name of the file xls of the PHPP
            % 2 ... language: 1:german, 0:english
            % 3 ... version of PHPP used
            
            filename = name_xls_PHPP;
            
            switch version
                case '9.1'
                    if language
                        sheet = 'Flächen';
                    else
                        sheet = 'Areas';
                    end
                    
                    range = 'K8:BA27';
                    [~, ~, data3] = xlsread(filename, sheet, range);
                    index_raw_tb = 16:18;
                    index_column_tbarea = 4;
                    index_column_tbname = 2;
                    index_column_tbbo = 1;
                    index_column_lpsi = 39;
                    
                case '10.2'
                    if language
                        sheet = 'Flächen';
                    else
                        sheet = 'Areas';
                    end
                    
                    range = 'K8:AZ29';
                    [~, ~, data3] = xlsread(filename, sheet, range);
                    index_raw_tb = 16:18;
                    index_column_tbarea = 2;
                    index_column_tbname = 3;
                    index_column_tbbo = 1;
                    index_column_lpsi = 37;
            end
            
            if ~data3{index_raw_tb(1),index_column_tbarea} == 0
                savename = 'Ambient_thermal_bridge'; 
                model = 0;
                type = 0;
                d = 1;
                U = 1/(1/(data3{index_raw_tb(1),index_column_lpsi}/data3{index_raw_tb(1),index_column_tbarea})-0.13-0.04);
                layers_names = {savename};
                layers_colors = [1.0 1.0 1.0] * ((1-0.3)*rand(1)+0.3);
                parameter.model = model;
                parameter.type = type;
                parameter.U = U;
                emission_1 = 0.94;
                emission_2 = 0.94;
%                 parameter.N_layer = d; %not needed
                parameter.xmesh_beu = d;
                parameter.d = d;
                parameter.lambda = U;
                parameter.rho = 50;
                parameter.cp = 1000;
                parameter.tau = parameter.rho*parameter.cp/2;                
                parameter.T_ini_beuken = 20;
                parameter.d_active = -1;
                parameter.T_dactive = -1;
                parameter.Phi_dactive = -1;
                parameter.layers_lambda = parameter.lambda;
                parameter.layers_rho = parameter.rho;
                parameter.layers_cp = parameter.cp;
                parameter.layers_N_layer = 1;
                parameter.layers_d = d;
                parameter.layers_names = layers_names;
                parameter.layers_colors = layers_colors;
                
                obj = obj.add_structure(savename, parameter, emission_1, emission_2, 0);
            end
            
            clearvars parameter
            
            if ~data3{index_raw_tb(2),index_column_tbarea} == 0
                savename = 'Perimeter_thermal_bridge'; 
                model = 0;
                type = 0;
                d = 1;
                U = 1/((1/(data3{index_raw_tb(2),index_column_lpsi}/data3{index_raw_tb(2),index_column_tbarea}))-0.13-0.04);
                layers_names = {savename};
                layers_colors = [1.0 1.0 1.0] * ((1-0.3)*rand(1)+0.3);
                parameter.model = model;
                parameter.type = type;
                parameter.U = U;

                emission_1 = 0.94;
                emission_2 = 0.94;
                
%                 parameter.N_layer = d;
                parameter.xmesh_beu = d;
                parameter.d = d;
                parameter.lambda = U;
                parameter.rho = 50;
                parameter.cp = 1000;
                parameter.tau = parameter.rho*parameter.cp/2;                
                parameter.T_ini_beuken = 20;
                parameter.d_active = -1;
                parameter.T_dactive = -1;
                parameter.Phi_dactive = -1;
                parameter.layers_lambda = parameter.lambda;
                parameter.layers_rho = parameter.rho;
                parameter.layers_cp = parameter.cp;
                parameter.layers_N_layer = 1;
                parameter.layers_d = d;
                parameter.layers_names = layers_names;
                parameter.layers_colors = layers_colors;
                
                obj = obj.add_structure(savename, parameter, emission_1, emission_2, 0);
            end
            
            clearvars parameter
            
            if ~data3{index_raw_tb(3),index_column_tbarea} == 0
                savename = 'Ground_thermal_bridge'; 
                model = 0;
                type = 0;
                d = 1;
                U = 1/((1/(data3{index_raw_tb(3),index_column_lpsi}/data3{index_raw_tb(3),index_column_tbarea}))-0.17-0.00);
                layers_names = {savename};
                layers_colors = [1.0 1.0 1.0] * ((1-0.3)*rand(1)+0.3);
                parameter.model = model;
                parameter.type = type;
                parameter.U = U;
                emission_1 = 0.94;
                emission_2 = 0.94;              
%                 parameter.N_layer = d;
                parameter.xmesh_beu = d;
                parameter.d = d;
                parameter.lambda = U;
                parameter.rho = 50;
                parameter.cp = 1000;
                parameter.tau = parameter.rho*parameter.cp/2;                
                parameter.T_ini_beuken = 20;
                parameter.d_active = -1;
                parameter.T_dactive = -1;
                parameter.Phi_dactive = -1;
                parameter.layers_lambda = parameter.lambda;
                parameter.layers_rho = parameter.rho;
                parameter.layers_cp = parameter.cp;
                parameter.layers_N_layer = 1;
                parameter.layers_d = d; 
                parameter.layers_names = layers_names;
                parameter.layers_colors = layers_colors;
                
                obj = obj.add_structure(savename, parameter, emission_1, emission_2, 0);
            end
            
            clearvars parameter
            
        end
        
        function obj = constructionwindow_from_PHPP(obj, name_xls_PHPP, language, version)
            % to add the construction of the windows that are in the PHPP
            % 1 ... name of the file xls of the PHPP
            % 2 ... language: 1:german, 0:english
            % 3 ... version of PHPP used
            
            filename = name_xls_PHPP;
            
            switch version
                case '10.2'
                    if language
                        sheet = 'Fenster';
                    else
                        sheet = 'Windows';
                    end
                    range = 'L23:BQ585';
                    [~, ~, data1] = xlsread(filename, sheet, range);
                    index_name_wi = 3;
                    index_constr1_wi = 10; % constr Glass
                    index_constr2_wi = 11; % constr Frame
                    index_Ug = 35;
                    index_Uf = 33;
                    index_psige = 36;
                    index_gw = 34;
                    for ii = 1:size(data1,1)
                        if strcmp(data1(ii,index_name_wi),'-') || sum(isnan(data1{ii,index_name_wi})) || isempty(data1{ii,index_name_wi})
                            last_win = ii;
                            break
                        end
                    end
                    data1(last_win:end,:) = [];
                    count_name = [];
                    for ii = 1:size(data1,1)
                        check =[];
                        check = strcmp([data1{ii,index_constr1_wi} ' ' data1{ii,index_constr2_wi}],(count_name));
                        if sum(check) == 0
                            savename = [data1{ii,index_constr1_wi}(1:end) '_' data1{ii,index_constr2_wi}(1:end)];
                            type = 1;
							
                            U_g = data1{ii,index_Ug};
                            U_f = data1{ii,index_Uf};
                            psi_ge = data1{ii,index_psige};

                            g_w =  data1{ii,index_gw};
                            tau_g_w = g_w;
							
                            n_pane = 3;                                 % number of panels

                            d_w = [0.004 0.004 0.004];                  % / [m]
                            c_w = [.21 .21 .21]*3600;                   % / [J/(kg K)] capacity
                            rho_w = [2500 2500 2500];                   % / [kg/m^3]
                            lambda_w = [0.76 0.76 0.76];                % / [W/(m.K)]
    
                            model = 0;
                            
                            parameter.model = model;
                            parameter.type = type;
                            parameter.U_g = U_g;
                            parameter.U_f = U_f;
                            parameter.psi_ge = psi_ge;
                            parameter.g_w = g_w;
                            parameter.tau_g_w = tau_g_w;
                            parameter.n_pane = n_pane;
                            parameter.d_w = d_w;
                            parameter.c_w = c_w;
                            parameter.rho_w = rho_w;
                            parameter.lambda_w = lambda_w;
                            emission_1 = 0.94;
                            emission_2 = 0.60;
                            absorption_2 = 0.65;
    
                            count_name{ii,1} = [data1{ii,index_constr1_wi} ' ' data1{ii,index_constr2_wi}];
                            obj = obj.add_structure(savename, parameter, emission_1, emission_2, absorption_2);
                        end
                    end
                    
                    case '9.1'
                    if language
                        sheet = 'Fenster';
                    else
                        sheet = 'Windows';
                    end
                    range = 'L24:BQ585';
                    [~, ~, data1] = xlsread(filename, sheet, range);
                    index_name_wi = 2;
                    index_constr1_wi = 9; % constr Glass
                    index_constr2_wi = 10; % constr Frame
                    index_Ug = 13;
                    index_Uf = 14;
                    index_psige = 15;
                    index_gw = 12;
                    for ii = 1:size(data1,1)
                        if strcmp(data1(ii,index_name_wi),'-') || sum(isnan(data1{ii,index_name_wi})) || isempty(data1{ii,index_name_wi})
                            last_win = ii;
                            break
                        end
                    end
                    data1(last_win:end,:) = [];
                    count_name = [];
                    for ii = 1:size(data1,1)
                        check =[];
                        check = strcmp([data1{ii,index_constr1_wi} ' ' data1{ii,index_constr2_wi}],(count_name));
                        if sum(check) == 0
                            savename = [data1{ii,index_constr1_wi}(1:end) '_' data1{ii,index_constr2_wi}(1:end)];
                            type = 1;
							
                            U_g = data1{ii,index_Ug};
                            U_f = data1{ii,index_Uf};
                            psi_ge = data1{ii,index_psige};

                            g_w =  data1{ii,index_gw};
                            tau_g_w = g_w;
							
                            n_pane = 3;                                 % number of panels

                            d_w = [0.004 0.004 0.004];                  % / [m]
                            c_w = [.21 .21 .21]*3600;                   % / [J/(kg K)] capacity
                            rho_w = [2500 2500 2500];                   % / [kg/m^3]
                            lambda_w = [0.76 0.76 0.76];                % / [W/(m.K)]
    
                            model = 0;
                            
                            parameter.model = model;
                            parameter.type = type;
                            parameter.U_g = U_g;
                            parameter.U_f = U_f;
                            parameter.psi_ge = psi_ge;
                            parameter.g_w = g_w;
                            parameter.tau_g_w = tau_g_w;
                            parameter.n_pane = n_pane;
                            parameter.d_w = d_w;
                            parameter.c_w = c_w;
                            parameter.rho_w = rho_w;
                            parameter.lambda_w = lambda_w;
                            emission_1 = 0.94;
                            emission_2 = 0.60;
                            absorption_2 = 0.65;
    
                            count_name{ii,1} = [data1{ii,index_constr1_wi} ' ' data1{ii,index_constr2_wi}];
                            obj = obj.add_structure(savename, parameter, emission_1, emission_2, absorption_2);
                        end
                    end
                    
                    clearvars parameter
            end
        end
        
        function obj = construction_from_EXCEL(obj, name_xls_EXCEL)
            % to add a construction from the Excel file
            [~, ~, raw_structure] = xlsread(name_xls_EXCEL, 'Structures');
            raw_walls = raw_structure(3:381,2:11);
            
            % to add the structures of walls that are in the excel
            for ii = 1:19:size(raw_walls,1)
                UA = 0;
                hygro = 0;
                RC = 0;
                
                qui = 0;
                raw_name_layer = [];
                raw_path_layer = [];
                raw_d_layer = [];
                raw_n_layer_hygrothermal_layer = [];
                raw_n_layer_beuken_layer = [];
                raw_lambda_layer = [];
                raw_rho_layer = [];
                raw_cp_layer = [];
                raw_T_ini= [];
                raw_phi_ini= [];
                parameter = [];
                
                if isnan(raw_walls{ii,2})
                    qui = 1;
                end
                
                if qui == 0
                    raw_name_structure=raw_walls{ii,2};
                    raw_T_ini(1)=(raw_walls{ii+1,9});
                    raw_phi_ini(1)=(raw_walls{ii+1,10})/100;
                    for jj=1:10
                        if isnan(raw_walls{ii+1+jj,3})
                            break
                        else
                            raw_name_layer{jj}=raw_walls{ii+1+jj,1};
                            raw_path_layer{jj}=raw_walls{ii+1+jj,2};
                            raw_d_layer(jj)=raw_walls{ii+1+jj,3};  
                            raw_d_active=raw_walls{ii+12,2};
                            raw_T_active=raw_walls{ii+13,2};
                            raw_Phi_active=raw_walls{ii+14,2};

                            if ~isnan(raw_walls{ii+1+jj,2})
                                hygro = 1;
                                parameter.model = 2;
                                raw_n_layer_hygrothermal_layer(jj)=raw_walls{ii+1+jj,8};
                                raw_n_layer_beuken_layer(jj)=raw_walls{ii+1+jj,7};
                                raw_T_ini(jj+1)=(raw_walls{1+ii+jj,9});
                                raw_phi_ini(jj+1)=(raw_walls{1+ii+jj,10})/100;
                            elseif isnan(raw_walls{ii+1+jj,5})
                                UA = 1;
                                parameter.model = 0;
                                raw_lambda_layer(jj)=raw_walls{ii+1+jj,4};
                            else
                                RC = 1;
                                parameter.model = 1;
                                raw_lambda_layer(jj)=raw_walls{ii+1+jj,4};
                                raw_rho_layer(jj)=raw_walls{ii+1+jj,5};
                                raw_cp_layer(jj)=raw_walls{ii+1+jj,6};
                                raw_n_layer_beuken_layer(jj)=raw_walls{ii+1+jj,7};
                            end
                        end
                    end
                    if RC
                        parameter = create_parameter_structure_RC(obj, raw_name_structure, parameter.model, jj-1, raw_d_layer, raw_lambda_layer, raw_rho_layer, raw_cp_layer, raw_name_layer, raw_n_layer_beuken_layer);
                    elseif hygro
                        T_source = zeros(sum(raw_n_layer_hygrothermal_layer),1);
                        Phi_source = zeros(sum(raw_n_layer_hygrothermal_layer),1);
                        parameter = create_parameter_structure_hygrothermal(obj, raw_name_structure, parameter.model, jj-1, raw_d_layer, raw_n_layer_beuken_layer, raw_n_layer_hygrothermal_layer, raw_path_layer, raw_name_layer, raw_T_ini, raw_phi_ini, T_source, Phi_source);
                        % parameter.layers_d = raw_d_layer;  %& controlla

                    else    % UA
%                         
                        Rsi = 0; %0.13;
                        R_tot = 0;
                        for jk = 1:length(raw_d_layer)
                            if ~isempty(raw_d_layer(jk))
                                R_tot = R_tot + raw_d_layer(jk) / raw_lambda_layer(jk);
                            end
                        end
                        Rse = 0; %0.04;
                        parameter.U = 1/(Rsi+R_tot+Rse);
                        parameter.Rsi = Rsi;
                        parameter.Rse = Rse;
                        parameter.N_layer = 1;
                        parameter.xmesh_beu = raw_d_layer;
                    end
                    
                    parameter.T_ini_beuken = 20; %to be improved, import from excel
                    parameter.d_active = raw_d_active;
                    parameter.Phi_dactive = raw_Phi_active;
                    parameter.T_dactive = raw_T_active;
                    
                    parameter.layers_names = raw_name_layer;
                    parameter.layers_colors = [];
                    for iii=1:(jj-1)
                        parameter.layers_colors(iii,:) = rand*[0.85 0.85 0.85];
                    end
                    parameter.layers_lambda = raw_lambda_layer;
                    parameter.layers_d = raw_d_layer; % check
                    
                    raw_emission_1 = raw_walls{ii+15,2};
                    raw_emission_2 = raw_walls{ii+16,2};
                    raw_absorption_2 = raw_walls{ii+17,2};
                    
                  parameter.type = 0;  
          
                    obj = add_structure(obj, raw_name_structure, parameter, raw_emission_1, raw_emission_2, raw_absorption_2);
                end
            end
        end
        
        function obj = construction_to_excel(obj, name_xls, building, variant_construction)
            try
                vollpfad = [pwd '\' name_xls];
                
                if exist(vollpfad, 'file')
                    warning('Existing Excel file used.')
                else
                    rootpath = fileparts(which('carnotUIBK'));
                    copyfile([rootpath '\building_TEMPLATE.xlsx'], vollpfad);
                    warning('New Excel file generated.')
                end
                
                % modify excel for write weather
                Excel = actxserver('Excel.Application');
                Excel.Workbooks.Open(vollpfad);
                warning('Excel file opened for writing! Do not interrupt this script!')

                % to delete the raws of the excel
                for ii=1:19:400
                    xlswrite1(name_xls,{''},'Structures',['B' num2str(ii+2) 'K' num2str(ii+19)])
                    xlswrite1(name_xls,{''},'Structures',['M' num2str(ii+2) 'P' num2str(ii+19)])
                end

                count_win = 0;
                
                jjk = 0;
                for jj = 1:size(building.construction(variant_construction).structure,2)
                    if building.construction(variant_construction).structure(jj).type == 0
                        jjk = jjk + 1;
                        if building.construction(variant_construction).structure(jj).model == 0
                            % UA
                            for ll = 1:size(building.construction(variant_construction).structure(jj).parameter.layers_names,2)
                                layers_names(ll) = building.construction(variant_construction).structure(jj).parameter.layers_names(ll);
                                try %was inserted because of problems
%                                 with names of previous version of
%                                 carnotUIBK
                                aaaaa=building.construction(variant_construction).structure(jj).parameter.layers_d(ll);
                                end
                                if exist('aaaaa','var')==1;
                                layers_d(ll) = building.construction(variant_construction).structure(jj).parameter.layers_d(ll); 
                                clear aaaaa
                                else
                                layers_d(ll) = building.construction(variant_construction).structure(jj).parameter.d(ll);
                                end
                                % layers_d(ll) = building.construction(variant_construction).structure(jj).parameter.layers_d(ll);
                                layers_lambda(ll) = building.construction(variant_construction).structure(jj).parameter.layers_lambda(ll);
                                layers_N_layer(ll) = 1;
                                layers_T_ini(ll) = nan;
                                layers_phi_ini(ll) = nan;
                            end
                            
                            for kk = (size(building.construction(variant_construction).structure(jj).parameter.layers_names,2)+1):10
                                layers_names{kk} = '';
                                layers_d(kk) = nan;
                                layers_lambda(kk) = nan;
                                layers_N_layer(kk) = nan;
                                layers_T_ini(kk) = nan;
                                layers_phi_ini(kk) = nan;
                            end

                            matrix_to_write_constr = [{'NAME'} {building.construction(variant_construction).structure(jj).name} {''} {''} {''} {''} {''} {''} {'T_ini'} {'phi_ini'}
                                {'name'} {'path'} {'d'} {'lambda'} {'rho'} {'cp'} {'n_layer_beuken'} {'n_layer_hygrothermal'} {''} {''} 
                                {layers_names{1}} {''} {layers_d(1)} {layers_lambda(1)} {''} {''} {layers_N_layer(1)} {''} {layers_T_ini(1)} {layers_phi_ini(1)}
                                {layers_names{2}} {''} {layers_d(2)} {layers_lambda(2)} {''} {''} {layers_N_layer(2)} {''} {layers_T_ini(2)} {layers_phi_ini(2)}
                                {layers_names{3}} {''} {layers_d(3)} {layers_lambda(3)} {''} {''} {layers_N_layer(3)} {''} {layers_T_ini(3)} {layers_phi_ini(3)}
                                {layers_names{4}} {''} {layers_d(4)} {layers_lambda(4)} {''} {''} {layers_N_layer(4)} {''} {layers_T_ini(4)} {layers_phi_ini(4)}
                                {layers_names{5}} {''} {layers_d(5)} {layers_lambda(5)} {''} {''} {layers_N_layer(5)} {''} {layers_T_ini(5)} {layers_phi_ini(5)}
                                {layers_names{6}} {''} {layers_d(6)} {layers_lambda(6)} {''} {''} {layers_N_layer(6)} {''} {layers_T_ini(6)} {layers_phi_ini(6)}
                                {layers_names{7}} {''} {layers_d(7)} {layers_lambda(7)} {''} {''} {layers_N_layer(7)} {''} {layers_T_ini(7)} {layers_phi_ini(7)}
                                {layers_names{8}} {''} {layers_d(8)} {layers_lambda(8)} {''} {''} {layers_N_layer(8)} {''} {layers_T_ini(8)} {layers_phi_ini(8)}
                                {layers_names{9}} {''} {layers_d(9)} {layers_lambda(9)} {''} {''} {layers_N_layer(9)} {''} {layers_T_ini(9)} {layers_phi_ini(9)}
                                {layers_names{10}} {''} {layers_d(10)} {layers_lambda(10)} {''} {''} {layers_N_layer(10)} {''} {layers_T_ini(10)} {layers_phi_ini(10)}
                                {'d_active'} {-1} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'T_active'} {-1} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'Phi_active'} {-1} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'emission 1'} {building.construction(variant_construction).structure(jj).emission_1} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'emission 2'} {building.construction(variant_construction).structure(jj).emission_2} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'absorption 2'} {building.construction(variant_construction).structure(jj).absorption_2} {''} {''} {''} {''} {''} {''} {''} {''}
                                ];

                            xlswrite1(name_xls,matrix_to_write_constr,'Structures',['B' num2str(3+(jjk-1)*19) ':K' num2str(20+(jjk-1)*19)])

                        elseif building.construction(variant_construction).structure(jj).model == 2
                            % hygrothermal
                            n_layer_progressive = 0;
                            for ll = 1:size(building.construction(variant_construction).structure(jj).parameter.layers_names,2)
                                layers_names(ll) = building.construction(variant_construction).structure(jj).parameter.layers_names(ll);
                                if isfield(building.construction(variant_construction).structure(jj).parameter,'path')
                                    layers_path(ll) = building.construction(variant_construction).structure(jj).parameter.path(ll);
                                else
                                    layers_path{ll} = 'not defined';
                                end
                                layers_d(ll) = building.construction(variant_construction).structure(jj).parameter.layers_d(ll);
                                %layers_lambda(ll) = building.construction(variant_construction).structure(jj).parameter.layers_names(ll);
                                %layers_rho(ll) = building.construction(variant_construction).structure(jj).parameter.layers_names(ll);
                                %layers_cp(ll) = building.construction(variant_construction).structure(jj).parameter.layers_names(ll);
                                layers_N_layer(ll) = building.construction(variant_construction).structure(jj).parameter.layers_N_layer(ll);
                                if isfield(building.construction(variant_construction).structure(jj).parameter, 'n_layer_hygrothermal_layer')
                                    layers_n_layer_hygrothermal(ll) = building.construction(variant_construction).structure(jj).parameter.n_layer_hygrothermal_layer(ll);
                                    n_layer_progressive = n_layer_progressive + building.construction(variant_construction).structure(jj).parameter.n_layer_hygrothermal_layer(ll);
                                    layers_T_ini(ll) = building.construction(variant_construction).structure(jj).parameter.T_ini_hygro(n_layer_progressive+1)-273.15;
                                    layers_phi_ini(ll) = building.construction(variant_construction).structure(jj).parameter.Phi_ini_hygro(n_layer_progressive+1)*100;
                                else
                                    layers_n_layer_hygrothermal(ll) = nan;
                                    layers_T_ini(ll) = nan;
                                    layers_phi_ini(ll) = nan;
                                end

                            end

                            for kk = size(building.construction(variant_construction).structure(jj).parameter.layers_names,2)+1: 10
                                layers_names{kk} = '';
                                layers_path{kk} = '';
                                layers_d(kk) = nan;
                                %layers_lambda(kk) ='';
                                %layers_rho(kk) ='';
                                %layers_cp(kk) ='';
                                layers_N_layer(kk) = nan;
                                layers_n_layer_hygrothermal(kk) = nan;
                                layers_T_ini(kk) = nan;
                                layers_phi_ini(kk) = nan;
                            end

                            matrix_to_write_constr = [{'NAME'} {building.construction(variant_construction).structure(jj).name} {''} {''} {''} {''} {''} {''} {'T_ini'} {'phi_ini'}
                            {'name'} {'path'} {'d'} {'lambda'} {'rho'} {'cp'} {'n_layer_beuken'} {'n_layer_hygrothermal'} {building.construction(variant_construction).structure(jj).parameter.T_ini_hygro(1)-273.15} {building.construction(variant_construction).structure(jj).parameter.Phi_ini_hygro(1)*100} 
                            {layers_names{1}} {layers_path{1}} {layers_d(1)} {''} {''} {''} {layers_N_layer(1)} {layers_n_layer_hygrothermal(1)} {layers_T_ini(1)} {layers_phi_ini(1)}
                            {layers_names{2}} {layers_path{2}} {layers_d(2)} {''} {''} {''} {layers_N_layer(2)} {layers_n_layer_hygrothermal(2)} {layers_T_ini(2)} {layers_phi_ini(2)}
                            {layers_names{3}} {layers_path{3}} {layers_d(3)} {''} {''} {''} {layers_N_layer(3)} {layers_n_layer_hygrothermal(3)} {layers_T_ini(3)} {layers_phi_ini(3)}
                            {layers_names{4}} {layers_path{4}} {layers_d(4)} {''} {''} {''} {layers_N_layer(4)} {layers_n_layer_hygrothermal(4)} {layers_T_ini(4)} {layers_phi_ini(4)}
                            {layers_names{5}} {layers_path{5}} {layers_d(5)} {''} {''} {''} {layers_N_layer(5)} {layers_n_layer_hygrothermal(5)} {layers_T_ini(5)} {layers_phi_ini(5)}
                            {layers_names{6}} {layers_path{6}} {layers_d(6)} {''} {''} {''} {layers_N_layer(6)} {layers_n_layer_hygrothermal(6)} {layers_T_ini(6)} {layers_phi_ini(6)}
                            {layers_names{7}} {layers_path{7}} {layers_d(7)} {''} {''} {''} {layers_N_layer(7)} {layers_n_layer_hygrothermal(7)} {layers_T_ini(7)} {layers_phi_ini(7)}
                            {layers_names{8}} {layers_path{8}} {layers_d(8)} {''} {''} {''} {layers_N_layer(8)} {layers_n_layer_hygrothermal(8)} {layers_T_ini(8)} {layers_phi_ini(8)}
                            {layers_names{9}} {layers_path{9}} {layers_d(9)} {''} {''} {''} {layers_N_layer(9)} {layers_n_layer_hygrothermal(9)} {layers_T_ini(9)} {layers_phi_ini(9)}
                            {layers_names{10}} {layers_path{10}} {layers_d(10)} {''} {''} {''} {layers_N_layer(10)} {layers_n_layer_hygrothermal(10)} {layers_T_ini(10)} {layers_phi_ini(10)}
                            {'d_active'} {building.construction(variant_construction).structure(jj).parameter.d_active} {''} {''} {''} {''} {''} {''} {''} {''}
                            {'T_active'} {building.construction(variant_construction).structure(jj).parameter.T_dactive} {''} {''} {''} {''} {''} {''} {''} {''}
                            {'Phi_active'} {building.construction(variant_construction).structure(jj).parameter.Phi_dactive} {''} {''} {''} {''} {''} {''} {''} {''}
                            {'emission 1'} {building.construction(variant_construction).structure(jj).emission_1} {''} {''} {''} {''} {''} {''} {''} {''}
                            {'emission 2'} {building.construction(variant_construction).structure(jj).emission_2} {''} {''} {''} {''} {''} {''} {''} {''}
                            {'absorption 2'} {building.construction(variant_construction).structure(jj).absorption_2} {''} {''} {''} {''} {''} {''} {''} {''}
                            ];

                            xlswrite1(name_xls,matrix_to_write_constr,'Structures',['B' num2str(3+(jjk-1)*19) ':K' num2str(20+(jjk-1)*19)])
                        else
                           % RC
                           for ll = 1: size(building.construction(variant_construction).structure(jj).parameter.layers_names,2)
                                layers_names(ll) = building.construction(variant_construction).structure(jj).parameter.layers_names(ll);
                                %layers_path(ll) = building.construction(variant_construction).structure(jj).parameter.layers_names(ll); %path
                                % layers_d(ll) = building.construction(variant_construction).structure(jj).parameter.layers_d(ll);
                                layers_lambda(ll) = building.construction(variant_construction).structure(jj).parameter.layers_lambda(ll);
                                layers_rho(ll) = building.construction(variant_construction).structure(jj).parameter.layers_rho(ll);
                                
                                try %was inserted because of problems
%                                 with names of previous version of
%                                 carnotUIBK
                                aaaaa=building.construction(variant_construction).structure(jj).parameter.layers_d(ll);
                                end
                                if exist('aaaaa','var')==1;
                                layers_d(ll) = building.construction(variant_construction).structure(jj).parameter.layers_d(ll); 
                                clear aaaaa
                                else
                                layers_d(ll) = building.construction(variant_construction).structure(jj).parameter.d(ll);
                                end


%                                 try %was inserted because of problems
%                                 with names of previous version of
%                                 carnotUIBK
%                                 aaaaa=building.construction(variant_construction).structure(jj).parameter.rho_layer(ll);
%                                 end
%                                 if exist('aaaaa','var')==1;
%                                 layers_rho(ll) = building.construction(variant_construction).structure(jj).parameter.rho_layer(ll); %rho_layer
%                                 else
%                                 layers_rho(ll) = building.construction(variant_construction).structure(jj).parameter.layers_rho(ll); %rho_layer
%                                 end
%                                 try
%                                 cp=building.construction(variant_construction).structure(jj).parameter.c_layer(ll);
%                                 end
%                                 if exist('cp','var')==1;
%                                 layers_cp(ll) = building.construction(variant_construction).structure(jj).parameter.c_layer(ll); %rho_layer
%                                 else
                                layers_cp(ll) = building.construction(variant_construction).structure(jj).parameter.layers_cp(ll);
%                                 end
% %                                 layers_cp(ll) = building.construction(variant_construction).structure(jj).parameter.layers_cp(ll);
%                                 try
%                                 nl=building.construction(variant_construction).structure(jj).parameter.layers_N_layer(ll);
%                                 end
%                                 if exist('nl','var')==1;
                                layers_N_layer(ll) = building.construction(variant_construction).structure(jj).parameter.layers_N_layer(ll);
%                                 else
%                                 layers_n_layer_beuken(ll) = building.construction(variant_construction).structure(jj).parameter.N_layer(ll);
%                                 end
                                layers_T_ini(ll) = nan;
                                layers_phi_ini(ll) = nan;
%                                 clear aaaaa cp
                            end

                            for kk = size(building.construction(variant_construction).structure(jj).parameter.layers_names,2)+1: 10
                                layers_names{kk} = '';
                                %layers_path(kk) =' ';
                                layers_d(kk) = nan;
                                layers_lambda(kk) =nan;
                                layers_rho(kk) =nan;
                                layers_cp(kk) =nan;
                                layers_N_layer(kk) = nan;
                                %layers_n_layer_hygrothermal(kk) = nan;
                                layers_T_ini(kk) = nan;
                                layers_phi_ini(kk) = nan;
                            end

                            matrix_to_write_constr = [{'NAME'} {building.construction(variant_construction).structure(jj).name} {''} {''} {''} {''} {''} {''} {'T_ini'} {'phi_ini'}
                                {'name'} {'path'} {'d'} {'lambda'} {'rho'} {'cp'} {'n_layer_beuken'} {'n_layer_hygrothermal'} {''} {''} 
                                {layers_names{1}} {''} {layers_d(1)} {layers_lambda(1)} {layers_rho(1)} {layers_cp(1)} {layers_N_layer(1)} {''} {layers_T_ini(1)} {layers_phi_ini(1)}
                                {layers_names{2}} {''} {layers_d(2)} {layers_lambda(2)} {layers_rho(2)} {layers_cp(2)} {layers_N_layer(2)} {''} {layers_T_ini(2)} {layers_phi_ini(2)}
                                {layers_names{3}} {''} {layers_d(3)} {layers_lambda(3)} {layers_rho(3)} {layers_cp(3)} {layers_N_layer(3)} {''} {layers_T_ini(3)} {layers_phi_ini(3)}
                                {layers_names{4}} {''} {layers_d(4)} {layers_lambda(4)} {layers_rho(4)} {layers_cp(4)} {layers_N_layer(4)} {''} {layers_T_ini(4)} {layers_phi_ini(4)}
                                {layers_names{5}} {''} {layers_d(5)} {layers_lambda(5)} {layers_rho(5)} {layers_cp(5)} {layers_N_layer(5)} {''} {layers_T_ini(5)} {layers_phi_ini(5)}
                                {layers_names{6}} {''} {layers_d(6)} {layers_lambda(6)} {layers_rho(6)} {layers_cp(6)} {layers_N_layer(6)} {''} {layers_T_ini(6)} {layers_phi_ini(6)}
                                {layers_names{7}} {''} {layers_d(7)} {layers_lambda(7)} {layers_rho(7)} {layers_cp(7)} {layers_N_layer(7)} {''} {layers_T_ini(7)} {layers_phi_ini(7)}
                                {layers_names{8}} {''} {layers_d(8)} {layers_lambda(8)} {layers_rho(8)} {layers_cp(8)} {layers_N_layer(8)} {''} {layers_T_ini(8)} {layers_phi_ini(8)}
                                {layers_names{9}} {''} {layers_d(9)} {layers_lambda(9)} {layers_rho(9)} {layers_cp(9)} {layers_N_layer(9)} {''} {layers_T_ini(9)} {layers_phi_ini(9)}
                                {layers_names{10}} {''} {layers_d(10)} {layers_lambda(10)} {layers_rho(10)} {layers_cp(10)} {layers_N_layer(10)} {''} {layers_T_ini(10)} {layers_phi_ini(10)}
                                {'d_active'} {building.construction(variant_construction).structure(jj).parameter.d_active} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'T_active'} {building.construction(variant_construction).structure(jj).parameter.T_dactive} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'Phi_active'} {building.construction(variant_construction).structure(jj).parameter.Phi_dactive} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'emission 1'} {building.construction(variant_construction).structure(jj).emission_1} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'emission 2'} {building.construction(variant_construction).structure(jj).emission_2} {''} {''} {''} {''} {''} {''} {''} {''}
                                {'absorption 2'} {building.construction(variant_construction).structure(jj).absorption_2} {''} {''} {''} {''} {''} {''} {''} {''}
                                ];
                            
                             xlswrite1(name_xls,matrix_to_write_constr,'Structures',['B' num2str(3+(jjk-1)*19) ':K' num2str(20+(jjk-1)*19)]) 
                        end
                    else
                        count_win = count_win + 1;
                        for ll = 1: size(building.construction(variant_construction).structure(jj).parameter.c_w,2)
                            d_w(ll) = building.construction(variant_construction).structure(jj).parameter.d_w(ll);
                            c_w(ll) = building.construction(variant_construction).structure(jj).parameter.c_w(ll);
                            rho_w(ll) = building.construction(variant_construction).structure(jj).parameter.rho_w(ll);
                            lambda_w(ll) = building.construction(variant_construction).structure(jj).parameter.lambda_w(ll);
                        end
                        
                        for ll = size(building.construction(variant_construction).structure(jj).parameter.c_w,2)+1:8
                            d_w(ll) = nan;
                            c_w(ll) = nan;
                            rho_w(ll) = nan;
                            lambda_w(ll) = nan;
                        end
                        
                        matrix_to_write_constr = [{'NAME'} {building.construction(variant_construction).structure(jj).name} {''} {''}
                            {'d_w'} {'c_w'} {'rho_w'} {'lambda_w'}
                            {d_w(1)} {c_w(1)} {rho_w(1)} {lambda_w(1)}
                            {d_w(2)} {c_w(2)} {rho_w(2)} {lambda_w(2)}
                            {d_w(3)} {c_w(3)} {rho_w(3)} {lambda_w(3)}
                            {d_w(4)} {c_w(4)} {rho_w(4)} {lambda_w(4)}
                            {d_w(5)} {c_w(5)} {rho_w(5)} {lambda_w(5)}
                            {d_w(6)} {c_w(6)} {rho_w(6)} {lambda_w(6)}
                            {d_w(7)} {c_w(7)} {rho_w(7)} {lambda_w(7)}
                            {d_w(8)} {c_w(8)} {rho_w(8)} {lambda_w(8)} 
                            {'U_g'} {building.construction(variant_construction).structure(jj).parameter.U_g} {''} {''}
                            {'U_f'} {building.construction(variant_construction).structure(jj).parameter.U_f} {''} {''}
                            {'psi_ge'} {building.construction(variant_construction).structure(jj).parameter.psi_ge} {''} {''}
                            {'g_w'} {building.construction(variant_construction).structure(jj).parameter.g_w} {''} {''}
                            {'tau_g_w'} {building.construction(variant_construction).structure(jj).parameter.tau_g_w} {''} {''}
                            {'emission 1'} {building.construction(variant_construction).structure(jj).emission_1} {''} {''}
                            {'emission 2'} {building.construction(variant_construction).structure(jj).emission_2} {''} {''}
                            {'absorption 2'} {building.construction(variant_construction).structure(jj).absorption_2} {''} {''}
                            ];
                        xlswrite1(name_xls,matrix_to_write_constr,'Structures',['M' num2str(3+(count_win-1)*19) ':P' num2str(20+(count_win-1)*19)]) 
                    end
                end
                
                Excel.ActiveWorkbook.Save
                Excel.Quit
                Excel.delete
                clear Excel
                warning('Excel file closed!')
                
            catch ME
                ME
                
                Excel.ActiveWorkbook.Save
                Excel.Quit
                Excel.delete
                clear Excel
                warning('Excel file closed!')
            end
        end
        
        function obj = construction_windows_from_EXCEL(obj, name_xls_EXCEL) %24/01/2017
            % to add a construction from the Excel file
            [~, ~, raw_structure] = xlsread(name_xls_EXCEL, 'Structures');
            raw_windows = raw_structure(3:381,13:16);
            
            % to add the structures of windows that are in the excel
            for ii=1:19:size(raw_windows,1)
                qui = 0;
                raw_dw = [];
                raw_c_w = [];
                raw_rho_w = [];
                raw_lambda_w = [];
                
                if isnan(raw_windows{ii,2})
                    qui =1;
                end
               
                if qui == 0
                    for jj=1:10
                        if isnan(raw_windows{ii+1+jj,1})
                            break
                        else
                            raw_d_w(jj)=raw_windows{ii+1+jj,1};
                            raw_c_w(jj) = raw_windows{ii+1+jj,2};
                            raw_rho_w(jj) = raw_windows{ii+1+jj,3};
                            if isnan(raw_windows{ii+1+jj,4})
                                parameter.model=0;
                            else
                                parameter.model=2;
                                raw_lambda_w(jj) = raw_windows{ii+1+jj,4};
                            end
                        end
                    end
                    parameter.c_w = raw_c_w;
                    parameter.d_w = raw_d_w;
                    parameter.rho_w = raw_rho_w;
                    if parameter.model >= 1
                        parameter.lambda_w = raw_lambda_w;
                    end
                    parameter.n_pane = length(raw_c_w);
                    raw_name_structure = raw_windows{ii,2};
                    parameter.U_g = raw_windows{ii+10,2};
                    parameter.U_f = raw_windows{ii+11,2};
                    parameter.psi_ge = raw_windows{ii+12,2};
                    parameter.g_w = raw_windows{ii+13,2};
                    parameter.tau_g_w = raw_windows{ii+14,2};
                    raw_emission_1=raw_windows{ii+15,2};
                    raw_emission_2=raw_windows{ii+16,2};
                    raw_absorption_2=raw_windows{ii+17,2};
                    parameter.type = 1;
                    
                    obj = add_structure(obj, raw_name_structure, parameter, raw_emission_1, raw_emission_2, raw_absorption_2);
                end
            end
        end
    end
    
    methods (Access = public)
        function parameter = create_parameter_structure_RC(obj, name, model, number_layer, d, lambda, rho, cp, names, n_layer_beuken)
            parameter.name = name;
            parameter.model = model;
            
            for ii=1:number_layer
                parameter.colors(ii,:) = rand*[0.8 0.8 0.8];
            end
            parameter.names = names;
            parameter.layers_d = d; %%
%             parameter.d = d;
            parameter.layers_N_layer = n_layer_beuken; 
            parameter.layers_lambda = lambda; 
            parameter.layers_cp = cp; 
            parameter.layers_rho = rho;
            parameter.R_si = 0.0; 
            parameter.R_se = 0.0;
%             parameter.T_active = 0;
            T_active =0;
            
            
            [parameter.xmesh_beu parameter.lambda parameter.rho parameter.cp ...
            parameter.tau_all parameter.D parameter.R parameter.U ...
            parameter.C parameter.tau] = wall_node_optim_(obj, parameter.layers_d, parameter.layers_lambda, ...
            parameter.layers_rho, parameter.layers_cp, parameter.layers_N_layer, ...
            T_active, parameter.R_si,...
            parameter.R_se, 0);
            
            parameter.d = parameter.xmesh_beu;
            parameter.d_active = -1;
        end
       
        function parameter = create_parameter_structure_hygrothermal(obj, name, model, number_layer, d, n_layer_beuken, anzx, pfad, names, T_ini, Phi_ini, T_source, Phi_source)
            % parameters for the hygrothermal model
            general.hygrothermal = create_strct_hum(obj,name, d,anzx,pfad,T_ini,Phi_ini);
            
            parameter.xmesh_hygro = general.hygrothermal.xmesh;
            parameter.X = general.hygrothermal.X;
            parameter.xmesh_hygro = general.hygrothermal.xmesh;
            parameter.K_kl = general.hygrothermal.K_kl;
            parameter.K_length = general.hygrothermal.K_length;
            parameter.lambda_hygro = general.hygrothermal.lambda;
            parameter.rho_hygro = general.hygrothermal.rho;
            parameter.cp_hygro = general.hygrothermal.cp;
            parameter.mu = general.hygrothermal.mu;
            parameter.ufs = general.hygrothermal.ufs;
            parameter.FSF_u = general.hygrothermal.FSF_u;
            parameter.FSF_phi = general.hygrothermal.FSF_phi;
            parameter.FSF_dudphi = general.hygrothermal.FSF_dudphi;
            parameter.FSF_k = general.hygrothermal.FSF_k;
            parameter.K_kleff = general.hygrothermal.K_kleff;
            parameter.K_u = general.hygrothermal.K_u;
            parameter.FSF_length = general.hygrothermal.FSF_length;
            parameter.T_ini_hygro = general.hygrothermal.T_ini;
            parameter.Phi_ini_hygro = general.hygrothermal.Phi_ini;
            parameter.T_source = T_source;      %general.hygrothermal.T_source;
            parameter.Phi_source = Phi_source;      %general.hygrothermal.Phi_source;
            parameter.n_layer_hygrothermal_layer = anzx;
            parameter.path = pfad;
          
            parameter.T_dactive = -1;
            parameter.Phi_dactive = -1;
            parameter.d_active = -1;
            
            % UA and RC
            parameter.name = name;
            parameter.model = model;
            parameter.layers_d = d;
            parameter.layers_names = names;
            for ii=1:number_layer
                parameter.layers_colors(ii,:)=rand*[0.8 0.8 0.8];
            end
            parameter.layers_N_layer = n_layer_beuken; 
%             parameter.d_layer = parameter.d;
%             parameter.lambda = parameter.lambda;
%             parameter.c_layer = parameter.cp;
%             parameter.rho_layer = parameter.rho;
            parameter.R_si = 0.0;
            parameter.R_se = 0.0;
            
            % parameters for the RC model model
            [parameter.xmesh_beu parameter.lambda parameter.rho parameter.cp parameter.tau_all parameter.D parameter.R parameter.U parameter.C parameter.tau] = wall_node_optim_(obj, parameter.layers_d, parameter.lambda_hygro, parameter.rho_hygro, parameter.cp_hygro, parameter.layers_N_layer, parameter.T_dactive, parameter.R_si, parameter.R_se, 0); 
            
        end
        
        function strct = create_strct_hum(obj, name, d, anzx, pfad, T_ini, Phi_ini)
            zufallnr = floor(10000*rand);
            
            mindx = 0.0005;

            % disp('------------------------------------------------------------')
            % ini
            rho = 1;
            cp = 1;
            lambda = 1;
            mu = 1;
            ufs = 1;
            FSF.u = 1;
            FSF.phi = 1;
            FSF.dudphi = 1;
            FSF.k(1) = 1;
            FSF.k(2) = 1;
            K.kleff = 0; 
            K.u = 0; 
            K.kl = 0;

            ind = ones(length(anzx)+1,1);
            for jj = 1:length(anzx)
                ind(jj+1) = ind(jj)+anzx(jj)+1;
            end

            % constants
            D_v = 2.662e-5;
            R_v = 462;      %J/kgK
            h_v = 2.445e6;  %J/kg

            cp_w = 4180;    %J/(kg*K)
            rho_w = 1000;
            cp_v = 2050;    %J/(kg*K)
            T = 293.15;
            phi = 0.5;

            for nr = 1:length(d)
                % figure(zufallnr+nr); hold on;
                prop = read_delphin_material_final(obj,[pfad{nr}],0);
            %     ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
            %     text(0.5, 1,pfad{nr},'HorizontalAlignment' ,'center','VerticalAlignment', 'top')
                hold off;
                lambda(nr) = prop.lambda;
                cp(nr) = prop.cp;
                rho(nr) = prop.rho;
                mu(nr) = prop.mu;
                ufs(nr) = prop.ufs;

                FSF(nr).u = zeros(1,500);
                FSF(nr).phi = zeros(1,500);
                FSF(nr).dudphi = zeros(1,500);

                for jj=1:length(prop.FSF.u)
                    FSF(nr).u(jj) = prop.FSF.u(jj);
                    FSF(nr).phi(jj) = prop.FSF.phi(jj);
                end
                for jj=1:length(prop.FSF.dudphi)
                    FSF(nr).dudphi(jj) = prop.FSF.dudphi(jj);
                end
            %     FSF(nr).dudphi = [FSF(nr).dudphi FSF(nr).dudphi(end)];

                FSF(nr).length = length(prop.FSF.u);

                FSF(nr).k(1) = prop.FSF.k(1);
                FSF(nr).k(2) = prop.FSF.k(2);

                K(nr).u = zeros(1,500);
                K(nr).kl = zeros(1,500);

                K(nr).kleff = prop.K.kleff;
                for jj=1:length(prop.K.u)
                    K(nr).u(jj) = prop.K.u(jj);
                    K(nr).kl(jj) = prop.K.kl(jj);
                end

                K(nr).length = length(prop.K.u);

                strct.d(nr) = d(nr);
                strct.lambda(nr) = lambda(nr);
                strct.cp(nr) = cp(nr);
                strct.rho(nr) = rho(nr);
                strct.mu(nr) = mu(nr);
                strct.ufs(nr) = ufs(nr);
                strct.FSF(nr) = FSF(nr);
                strct.K(nr) = K(nr);

%                 disp(['d = ' num2str(d(nr)) ' m'])
%                 disp(['rho = ' num2str(rho(nr)) ' W/(m K)'])
%                 disp(['lambda = ' num2str(lambda(nr)) ' W/(m K)'])
%                 disp(['mu = ' num2str(mu(nr)) ' -'])
%                 disp(['cp = ' num2str(cp(nr)) ' J/(kg K)'])
%                 disp(['ufs = ' num2str(ufs(nr)) ' kg/m^3'])
%                 disp(['w80 = ' num2str(mean(FSF(nr).u(find(abs(FSF(nr).phi-0.8)<0.01)))*ufs(nr)) ' kg/m^3'])
%                 disp(['w98 = ' num2str(mean(FSF(nr).u(find(abs(FSF(nr).phi-0.98)<0.01)))*ufs(nr)) ' kg/m^3'])

            %     for jj = 1:length(d)
            %         u_phi_D(jj)=interp1(FSF(jj).phi,FSF(jj).u,phi);
            %         u_phi_H(jj)=ufs(jj)./(1+(-rho_w*R_v*T.*log(phi)./FSF(jj).k(1)).^FSF(jj).k(2));%kg/m^3
            %     end

            %     u_phi_D(nr) = interp1(FSF(nr).phi,FSF(nr).u,phi);
            %     u_phi_H(nr) = ufs(nr)./(1+(-rho_w*R_v*T.*log(phi)./FSF(nr).k(1)).^FSF(nr).k(2));%kg/m^3
            %     
            %     u_D_tot = sum(u_phi_D(nr).*d(nr).*ufs(nr));
            %     u_H_tot = sum(u_phi_H(nr).*d(nr));
            %     disp(['D: ' num2str(u_D_tot) ' H: ' num2str(u_H_tot)])
            %     
            %     figure(nr); clf;
            %     subplot(2,1,1); hold on;
            %     plot(FSF(nr).phi,FSF(nr).u*ufs(nr))
            %     plot(phi,u_phi_D(nr)*ufs(nr),'d')
            %     plot(phi,u_phi_H(nr),'s')
            %     grid on;
            %     legend('Database','interp','approx')
            %     subplot(2,1,2)
            %     plot(K(nr).u,K(nr).kl)
            %     grid on;
            %     disp('------------------------------------------------------------')
            end

            % mesh
            % TODO!!!
            gitter = 'log'; % log|lin

            x0 = 0;
            X = zeros(length(d)+1,1);
            for jj = 1:length(d)
                X(jj+1) = sum(d(1:jj));
            end

            if length(anzx) ~= length(d), disp('error');return; end;

            switch lower(gitter)
                case{'log'}
                    x = x0;
                    kk = 1;
                    for jj = 1:length(d)
                        dx = logspace(log10(mindx),log10(d(jj)/2),round(anzx(jj)/2));
                        dx = dx * d(jj)/2/sum(dx);
                        % disp(['jj = ' int2str(jj) ': d = ' num2str(d(jj)) ' dx = ' num2str(dx) ' sum(dx) = ' num2str(2*sum(dx))])
                        for ii = 1:length(dx)
                            kk = kk+1; x(kk)= x(kk-1)+dx(ii);
                        end
                        dxf = fliplr(dx);
                        for ii = 1:length(dxf)
                            kk = kk+1; x(kk)= x(kk-1)+dxf(ii);
                        end
                    end
                case{'lin'}
                    x = x0;
                    for jj = 1:length(d)
                        dx = d(jj)/anzx(jj);
                        for ii = 1:anzx(jj)
                            x = [x x(end)+dx];
                        end
                    end
                otherwise        
                    % disp('no grid')
            end

            %disp(['size(x) = ' num2str(size(x)) ' x(1) = ' num2str(x(1)) ' x(end) = ' num2str(x(end))])
            %disp(['x0 = ' num2str(x(1)) ' x1 = ' num2str(x(end)) ' X = ' num2str(X')])


            FSF_u = [];
            FSF_phi = [];
            FSF_dudphi = [];
            FSF_k = [];
            K_kleff = [];
            K_u = [];
            K_kl = [];
            FSF_length = [];
            K_length = [];

            for nr = 1:length(d)
                FSF_u = [FSF_u; strct.FSF(nr).u];
                FSF_phi = [FSF_phi; strct.FSF(nr).phi];
                FSF_dudphi = [FSF_dudphi; strct.FSF(nr).dudphi];
                FSF_k = [FSF_k; strct.FSF(nr).k];
                K_kleff = [K_kleff; strct.K(nr).kleff];
                K_u = [K_u; strct.K(nr).u];
                K_kl = [K_kl; strct.K(nr).kl];
                FSF_length = [FSF_length; strct.FSF(nr).length];
                K_length = [K_length; strct.K(nr).length];
            end

            strct.X = X(:)';
            strct.xmesh = x;
            xmesh = x;

            FSF_u_ = [];
            FSF_phi_ = [];
            FSF_dudphi_ = [];

            for jj=1:size(FSF_u,1)
                FSF_u_ = [FSF_u_ FSF_u(jj,:)];
                FSF_phi_ = [FSF_phi_ FSF_phi(jj,:)];
                FSF_dudphi_ = [FSF_dudphi_ FSF_dudphi(jj,:)];
            end
            strct.FSF_u = FSF_u_;
            strct.FSF_phi = FSF_phi_;
            strct.FSF_dudphi = FSF_dudphi_;

            K_u_ = [];
            K_kl_ = [];

            for jj=1:size(K_u,1)
                K_u_ = [K_u_ K_u(jj,:)];
                K_kl_ = [K_kl_ K_kl(jj,:)];
            end
            strct.K_u = K_u_;
            strct.K_kl = K_kl_;

            strct.FSF_k = FSF_k(:)';
            strct.K_kleff = K_kleff(:)';

            strct.FSF_length = FSF_length(:)';
            strct.K_length = K_length(:)';

            % strct.T_ini = ones(length(strct.xmesh),1)*294.80-(21.1-2.3)*([0:1/(length(strct.xmesh)-1):1]');
            % strct.T_ini = ones(length(strct.xmesh),1)*294.80-(21.1-12)*([0:1/(length(strct.xmesh)-1):1]');
            % strct.Phi_ini = ones(length(strct.xmesh),1)*0.33+0.40*([0:1/(length(strct.xmesh)-1):1]');
            %qui quo qua
            T_ini_ = T_ini+273.15;
            T_ini__ = zeros(10,100);
            T_ini___ = zeros(10,100);
            for ik = 1:length(T_ini_)-1
                if T_ini_(ik)>=T_ini_(ik+1)
                    T_ini__(ik+1,1:(anzx(ik)+1)) = [T_ini_(ik+1):((T_ini_(ik)-T_ini_(ik+1))/anzx(ik)):T_ini_(ik)];
                    T_ini___(ik+1,1:(anzx(ik))) = T_ini__(ik+1,1:(anzx(ik)))';
                    T_ini___(ik+1,1:(anzx(ik)))= fliplr(T_ini___(ik+1,1:(anzx(ik))));
                else
                    T_ini__(ik+1,1:(anzx(ik)+1)) = [T_ini_(ik):((T_ini_(ik+1)-T_ini_(ik))/anzx(ik)):T_ini_(ik+1)];
                    T_ini___(ik+1,1:(anzx(ik))) = T_ini__(ik+1,2:(anzx(ik)+1))';
                end
                
            end
            T_ini___(1,1)=T_ini_(1);
            T_ini___ =T_ini___';
            T_ini___ = T_ini___(:);
%             T_ini___ = (sort(T_ini___));
%             T_ini___ = flipud(T_ini___);
            T_ini___(T_ini___==0) = [];
            
            Phi_ini_ = Phi_ini;
            Phi_ini__ = zeros(10,100);
            Phi_ini___ = zeros(10,100);
            for ik = 1:length(Phi_ini_)-1
                if Phi_ini_(ik)>=Phi_ini_(ik+1)
                    Phi_ini__(ik+1,1:(anzx(ik)+1)) = [Phi_ini_(ik+1):((Phi_ini_(ik)-Phi_ini_(ik+1))/anzx(ik)):Phi_ini_(ik)];
                    Phi_ini___(ik+1,1:(anzx(ik))) = Phi_ini__(ik+1,1:(anzx(ik)))';
                    Phi_ini___(ik+1,1:(anzx(ik)))= fliplr(Phi_ini___(ik+1,1:(anzx(ik))));
                else
                    Phi_ini__(ik+1,1:(anzx(ik)+1)) = [Phi_ini_(ik):((Phi_ini_(ik+1)-Phi_ini_(ik))/anzx(ik)):Phi_ini_(ik+1)];
                    Phi_ini___(ik+1,1:(anzx(ik))) = Phi_ini__(ik+1,2:(anzx(ik)+1))';
                end
                
            end
            Phi_ini___(1,1)=Phi_ini_(1);
            Phi_ini___ =Phi_ini___';
            Phi_ini___ = Phi_ini___(:);
%             Phi_ini___ = (sort(Phi_ini___));
%             Phi_ini___ = flipud(Phi_ini___);
            Phi_ini___(Phi_ini___==0) = [];
            
            % strct.T_ini = [(ones(1,23)*(273.15+19)-(2)*([0:1/(23-1):1])) (ones(1,5)*(273.15+19-3)-(16)*([0:1/(5-1):1]))]';
            % strct.Phi_ini = [(ones(1,23)*(0.4)+(0.15)*([0:1/(23-1):1])) (ones(1,5)*(0.55)+(0.3)*([0:1/(5-1):1]))]';
%             if length(T_ini)~=length(strct.xmesh)
%                error(['T_ini has to be so long as the mesh of the structure " ' name ' " plus 1 value (' num2str(length(strct.xmesh)) ' values)'])
%             end
%             if length(Phi_ini)~=length(strct.xmesh)
%                error(['Phi_ini has to be so long as the mesh of the structure " ' name ' " plus 1 value (' num2str(length(strct.xmesh)) ' values)'])
%             end
            strct.T_ini = T_ini___;%[(ones(1,20)*(273.15+19)-(2)*([0:1/(20-1):1])) (ones(1,5)*(273.15+19-3)-(16)*([0:1/(5-1):1]))]';
            strct.Phi_ini = Phi_ini___;%[(ones(1,20)*(0.4)+(0.15)*([0:1/(20-1):1])) (ones(1,5)*(0.55)+(0.3)*([0:1/(5-1):1]))]';
            strct.T_source = zeros(length(strct.xmesh),1);
            strct.Phi_source = zeros(length(strct.xmesh),1);
        end
        
        function [d lambda rho cp tau D_tot R_tot U_tot C_tot TAU_tot] = wall_node_optim_(obj ,d_0, lambda_0, rho_0, cp_0, N_layer, d_active, Rsi, Rse, debug)
            name = '';

            pos0 = find(d_0 == 0);
            d_0(pos0) = [];
            lambda_0(pos0) = [];
            rho_0(pos0) = [];
            cp_0(pos0) = [];
            N_layer(pos0) = [];

            d_o = d_0;
            lambda_o = lambda_0;
            rho_o = rho_0;
            cp_o = cp_0;

            d_1 = d_0;
            lambda_1 = lambda_0;
            rho_1 = rho_0;
            cp_1 = cp_0;
            % 
            % display(d_0)

            jj = 1;
            while jj <= length(d_0)
                % jj
                % d_0
                if jj <= length(d_1)
        %             disp([num2str(jj) ': ' num2str(N_layer(jj))])
        %             pause
        
                    if N_layer(jj) == 0 && jj > 1 && jj < length(d_0)
                        d_1(jj-1) = d_0(jj-1)+d_0(jj)/2;
                        d_1(jj+1) = d_0(jj+1)+d_0(jj)/2;
                        R0 = d_0(jj)/lambda_0(jj);
                        Rleft = d_0(jj-1)/lambda_0(jj-1)+R0/2;
                        Rright = d_0(jj+1)/lambda_0(jj+1)+R0/2;
                        lambda_1(jj-1) = d_1(jj-1)/Rleft;
                        lambda_1(jj+1) = d_1(jj+1)/Rright;
                        rho_1(jj-1) = (rho_0(jj-1) * d_0(jj-1) + rho_0(jj) * d_0(jj)/2)/(d_0(jj-1)+d_0(jj)/2);
                        rho_1(jj+1) = (rho_0(jj+1) * d_0(jj+1) + rho_0(jj) * d_0(jj)/2)/(d_0(jj+1)+d_0(jj)/2);
                        cp_1(jj-1) = (cp_0(jj-1)*rho_0(jj-1) * d_0(jj-1) + cp_0(jj)*rho_0(jj) * d_0(jj)/2)/(d_0(jj-1)+d_0(jj)/2)/rho_1(jj-1);
                        cp_1(jj+1) = (cp_0(jj+1)*rho_0(jj+1) * d_0(jj+1) + cp_0(jj)*rho_0(jj) * d_0(jj)/2)/(d_0(jj+1)+d_0(jj)/2)/rho_1(jj+1);
        %                 disp(['(' num2str(rho_0(jj-1)) '*' num2str(d_0(jj-1)) '+' num2str(rho_0(jj)) '*' num2str(d_0(jj)) '/2)/(' num2str(d_0(jj-1)) '+' num2str(d_0(jj)/2) ')'])
        %                 disp(['(' num2str(cp_0(jj-1)) '*' num2str(d_0(jj-1)) '+' num2str(cp_0(jj)) '*' num2str(d_0(jj)) '/2)/(' num2str(d_0(jj-1)) '+' num2str(d_0(jj)/2) ')'])

                        N_layer(jj) = [];
                        d_1(jj) = [];
                        lambda_1(jj) = [];
                        rho_1(jj) = [];
                        cp_1(jj) = [];

                        d_0 = d_1;
                        lambda_0 = lambda_1;
                        rho_0 = rho_1;
                        cp_0 = cp_1;

                    elseif N_layer(jj) == 0 && jj == 1
                        d_1(jj+1) = d_0(jj+1)+d_0(jj);
                        R0 = d_0(jj)/lambda_0(jj);
                        Rright = d_0(jj+1)/lambda_0(jj+1)+R0;
                        lambda_1(jj+1) = d_1(jj+1)/Rright;
                        rho_1(jj+1) = (rho_0(jj+1) * d_0(jj+1) + rho_0(jj) * d_0(jj))/(d_0(jj+1)+d_0(jj));
                        cp_1(jj+1) = (cp_0(jj+1)*rho_0(jj+1) * d_0(jj+1) + cp_0(jj)*rho_0(jj) * d_0(jj))/(d_0(jj+1)+d_0(jj))/rho_1(jj+1);
                %         disp([num2str(rho_1(jj+1)) '=' '(' num2str(rho_0(jj+1)) '*' num2str(d_0(jj+1)) '+' num2str(rho_0(jj)) '*' num2str(d_0(jj)) ')/(' num2str(d_0(jj+1)) '+' num2str(d_0(jj)) ')'])
                %         disp([num2str(cp_1(jj+1)) '=' '(' num2str(cp_0(jj+1)) '*' num2str(d_0(jj+1)) '+' num2str(cp_0(jj)) '*' num2str(d_0(jj)) ')/(' num2str(d_0(jj+1)) '+' num2str(d_0(jj)) ')'])

                        N_layer(jj) = [];
                        d_1(jj) = [];
                        lambda_1(jj) = [];
                        rho_1(jj) = [];
                        cp_1(jj) = [];

                        d_0 = d_1;
                        lambda_0 = lambda_1;
                        rho_0 = rho_1;
                        cp_0 = cp_1;

                    elseif N_layer(jj) == 0 && jj == length(d_0)
                        d_1(jj-1) = d_0(jj-1)+d_0(jj);
                        R0 = d_0(jj)/lambda_0(jj);
                        Rleft = d_0(jj-1)/lambda_0(jj-1)+R0;
                        lambda_1(jj-1) = d_1(jj-1)/Rleft;
                        rho_1(jj-1) = (rho_0(jj-1) * d_0(jj-1) + rho_0(jj) * d_0(jj))/(d_0(jj-1)+d_0(jj));
                        cp_1(jj-1) = (cp_0(jj-1)*rho_0(jj-1) * d_0(jj-1) + cp_0(jj)*rho_0(jj) * d_0(jj))/(d_0(jj-1)+d_0(jj))/rho_1(jj-1);
                %         disp([num2str(rho_1(jj-1)) '=' '(' num2str(rho_0(jj-1)) '*' num2str(d_0(jj-1)) '+' num2str(rho_0(jj)) '*' num2str(d_0(jj)) ')/(' num2str(d_0(jj-1)) '+' num2str(d_0(jj)) ')'])
                %         disp([num2str(cp_1(jj-1)) '=' '(' num2str(cp_0(jj-1)) '*' num2str(d_0(jj-1)) '+' num2str(cp_0(jj)) '*' num2str(d_0(jj)) ')/(' num2str(d_0(jj-1)) '+' num2str(d_0(jj)) ')'])

                        N_layer(jj) = [];
                        d_1(jj) = [];
                        lambda_1(jj) = [];
                        rho_1(jj) = [];
                        cp_1(jj) = [];

                        d_0 = d_1;
                        lambda_0 = lambda_1;
                        rho_0 = rho_1;
                        cp_0 = cp_1;

                    else
                        jj = jj+1;
                    end
                end
            end

            d = [];
            lambda = [];
            cp = [];
            rho = [];
            for jj = 1:length(d_1)
                if N_layer(jj) ~= 0
                    d = [d d_1(jj)/N_layer(jj) * ones(1,N_layer(jj))];
                    lambda = [lambda lambda_1(jj) * ones(1,N_layer(jj))];
                    cp = [cp cp_1(jj) * ones(1,N_layer(jj))];
                    rho = [rho rho_1(jj) * ones(1,N_layer(jj))];
                end
            end

            
            C = zeros(1,length(d)+1);
            D_tot = sum(d);
            R_tot = sum(d./lambda);
            for jj = 1:length(d)+1
                if jj == 1
                    C(jj) = rho(jj)*cp(jj)*d(jj)/2;
                    tau(jj) = 1/(1/Rsi+lambda(jj)/(d(jj)/2))*C(jj);
                elseif jj == length(d)+1
                    C(jj) = rho(jj-1)*cp(jj-1)*d(jj-1)/2;
                    tau(jj) = 1/(lambda(jj-1)/(d(jj-1)/2)+1/Rse)*C(jj-1);
                else
                    C(jj) = (rho(jj-1)*cp(jj-1)*d(jj-1)+rho(jj)*cp(jj)*d(jj))/2;
                    tau(jj) = 1/(lambda(jj-1)/(d(jj-1)/2)+lambda(jj)/(d(jj)/2))*C(jj);
                end
            end
            C_tot = sum(C);
            U_tot = 1/(Rsi+R_tot+Rse);
            TAU_tot = sum(R_tot.* C_tot.*d)/2;

            if debug
                disp(['tau = ' num2str(tau/3600) ' h'])
                disp(['min(tau) = ' num2str(min(tau)/60) ' min.' ' max(tau) = ' num2str(max(tau)/60) ' min.'])

    %         % ------------------------------
    %         disp(' #############################################')
    %         disp(['rho/[kg/m^3] = ' num2str([sum(rho_0.*d_0)/sum(d_0),sum(rho_ref.*d_ref)/sum(d_ref),sum(rho.*d)/sum(d)])])
    %         disp(['cp/[kg/m^3] = ' num2str([sum(cp_0.*d_0)/sum(d_0),sum(cp_ref.*d_ref)/sum(d_ref),sum(cp.*d)/sum(d)])])
    %         disp(['rho*cp/[kg/m^3] = ' num2str([sum(rho_0.*cp_0.*d_0)/sum(d_0),sum(rho_ref.*cp_ref.*d_ref)/sum(d_ref),sum(rho.*cp.*d)/sum(d)])])
    %         disp(['D/[m] = ' num2str([D_0_tot,D_ref_tot,D_tot])])
    %         disp(['R/[(m^2) K/W] = ' num2str([R_0_tot,R_ref_tot,R_tot])])
    %         disp(['C/[J/(K m^2)] = ' num2str([C_0_tot,C_ref_tot,C_tot])])
    %         disp(['t/[h] = ' num2str([sum(tau_0/3600),sum(tau_ref/3600),sum(tau/3600)])])

                % for plot
                % lambda = cp; lambda_0 = cp_0;
                % lambda = rho; lambda_0 = rho_0;

                D(1) = 0;
                for j=2:length(d)+1
                    D(j) = sum(d(1:j-1));
                end

                for j=1:length(d)
                    Dplot(j) = (D(j)+D(j+1))/2;
                end

                if name
                    name = strrep(name,'_','\_');
                    namepl = [name ': '];
                else
                    namepl = [''];
                end

    %             scrsz = get(0,'ScreenSize');
    %             f1=figure('Position',[scrsz(3)*1/2-scrsz(3)*.2 scrsz(4)*1/2 scrsz(3)*.4 scrsz(4)*.4]);clf; hold on;
    %             title([num2str(namepl) ' U = ' num2str(1/(R_tot+Rsi+Rse),'%3.3f') ' W/(m^2 K),' ' R_T = ' num2str(R_tot+Rsi+Rse,'%3.3f') ' (m^2 K)/W,' ' R = ' num2str(R_tot,'%3.3f') ' (m^2 K)/W' ' R_{si}+R_{se} = ' num2str(Rsi+Rse,'%3.3f') ' (m^2 K)/W'])
    %             plot(Dplot,lambda,'*k');
    %             plot([0,0],[0,max(lambda_o)*2],'b')
    %             plot([D(end),D(end)],[0,max(lambda_o)*2],'b')
    %             set(gca,'Ylim',[0,max(lambda_o)*1.2])
    %             set(gca,'Xlim',[0-D(end)/10,D(end)*1.1])
    %             for j = 1:sum(N_layer)
    %                 plot([sum(d(1:j)),sum(d(1:j))],[0,max(lambda_o)*1.2],'k--')
    %             end
    %             for j = 2:length(D)-1
    %                 plot([D(j),D(j)],[0,max(lambda_o)*2],'b:')
    %             end
    %             plot([d_active,d_active],[0,max(lambda_o)*2],'r')
    % 
    %             xlabel('d / [m]','FontWeight','bold')
    %             ylabel('lambda / [W/(m K)]','FontWeight','bold')
    % 
    %             D(1) = 0;
    %             for j=2:length(d_o)+1
    %                 D(j) = sum(d_o(1:j-1));
    %             end
    %             Dplot = [];
    %             for j=1:length(d_o)
    %                 Dplot(j) = (D(j)+D(j+1))/2;
    %             end
    %             for ii = 1:length(d_o)
    %                 plot([sum(d_o(1:ii)),sum(d_o(1:ii))],[0,max(lambda_o)*1.2],'m:')
    %             end
    %             plot(Dplot,lambda_o,'om');
    %             ylim([0,max(lambda_o)*1.2]) 

            end
        end
    
        function prop = read_delphin_material_final(obj, materialdatei, plotten)
            global nr_GLOBAL
            nr_GLOBAL  = 0;
            
            vollpfad = [pwd '\' materialdatei];
            
            fid = fopen(vollpfad);    
            
            % Konstanten
            rho_w = 1000;
            R_v = 462;
            T = 293.15;

            rho = 0;
            cp = 0;
            lambda = 0;
            psi_op = 0;
            psi_eff = 0;
            mu = 0;
            aw = 0;
            Kl = 0;
            Dl = 0;
            psi_cap = 0;
            psi_80 = 0;

            pC = 0;
            Ol = 0;
            Olinv = 0;
            pCinv = 0;
            rOl = 0;
            lgKl = 0;

            while 1
                line = fgets(fid);
                k = strfind(line, '[GENERAL]');
                if ~isempty(k), break; end;
                if feof(fid), break; end;
            end

            line = fgets(fid);
            [token, remain] = strtok(line,'=');
            name = strrep(remain,'=',' ');
            name = strtrim(name);
            %disp(name)

            while 1
                line = fgets(fid);
                k = strfind(line, '[MRC]');
                if ~isempty(k), break; end;
                if feof(fid), break; end;
                [token, remain] = strtok(line,'=');
            %     disp(['token = ' token ', ' 'remain = ' remain])
                property = strtrim(token);
                valueunit = strrep(remain,'=',' ');
                [value, unit] = strtok(valueunit,' ');
            %     disp([value ' in ' unit]),pause 
                switch property
                    case 'RHO'
                        rho = str2num(value);
                    case 'CE'
                         cp = str2num(value);
                     case 'LAMBDA'
                        lambda = str2num(value);             
                    case 'OPOR'
                         psi_op = str2num(value);
                    case 'OEFF'
                        psi_eff = str2num(value);
                     case 'MEW'
                        mu = str2num(value);
                     case 'AW'
                        aw = str2num(value);
                     case 'KLEFF'
                        Kl = str2num(value);
                     case 'DLEFF'
                        Dl = str2num(value);
                     case 'OCAP'
                        psi_cap = str2num(value);
                     case 'O80'
                        psi_80 = str2num(value);
                end
            end

            while 1
                line = fgets(fid);
                k = strfind(line, '[MOISTTRANS]');
                if ~isempty(k), break; end;
                if feof(fid), break; end;

                [token, remain] = strtok(line,'=');
            %     disp(['token = ' token ', ' 'remain = ' remain])

                functype = strrep(remain,'=',' ');
                functype = strtrim(functype);
                    switch functype
                    case 'Ol(pC)'
                        pC = str2num(fgets(fid));
                        Ol = str2num(fgets(fid));
                    case 'pC(Ol)'
                        Olinv =  str2num(fgets(fid));
                        pCinv =  str2num(fgets(fid));
                    end
            end


            while 1
                line = fgets(fid);
                k = strfind(line, '[HEATTRANS]');
                if ~isempty(k), break; end;
                if feof(fid), break; end;

                [token, remain] = strtok(line,'=');
            %     disp(['token = ' token ', ' 'remain = ' remain])

                functype = strrep(remain,'=',' ');
                functype = strtrim(functype);
                    switch functype
                    case 'lgKl(Ol)'
                        rOl = str2num(fgets(fid));
                        lgKl = str2num(fgets(fid));
                    end
            end

            fclose(fid);

            %umrechnung auf der sorptionsisothermen auf phi - wassergehalt
            phi = exp(-10.^pC./(rho_w*R_v*T));
            u = Ol*psi_eff * rho_w;

            % ind0 = length(u)-40; ind1 = length(u); % fit eines Bereichs der S-Iso 
            ind0 = 1; ind1 = length(u);

            h1 = 0;
            plotten = 0;
            if plotten
                disp(['rho = ' num2str(rho) ' kg/m^3'])
                disp(['cp = ' num2str(cp) ' J/(kg K)'])
                disp(['lambda = ' num2str(lambda) ' W/(m K)'])
                disp(['psi_op = ' num2str(psi_op) ' m^3/m^3'])
                disp(['psi_eff = ' num2str(psi_eff) ' m^3/m^3'])
                disp(['mu = ' num2str(mu) ' -'])
                disp(['aw = ' num2str(aw) ' kg/m2s05'])
                disp(['Kl = ' num2str(Kl) ' s'])
                disp(['Dl = ' num2str(Dl) ' m^2/s'])
                disp(['lambda = ' num2str(lambda) ' W/(m K)'])
                disp(['psi_cap = ' num2str(psi_cap) ' m^3/m^3'])
                disp(['psi_80 = ' num2str(psi_80) ' m^3/m^3'])

                figure(1); clf; hold on;
                plot(pC,Ol,'d-b')
                plot(pCinv,Olinv,'s--r')
                ylabel('u/u_{fs} / [-]','FontWeight','bold');
                xlabel('log10(rKl/[Pa])','FontWeight','bold');
                grid on;

                figure(2); clf; hold on;
                plot(phi,Ol,'d-b')
                ylabel('u/u_{fs} / [-]','FontWeight','bold');
                xlabel('\phi / [-]','FontWeight','bold');
                grid on;

                figure(3); clf; hold on;
                plot(phi,u,'db')
                h1 = plot(phi(ind0:ind1),u(ind0:ind1),'-k','LineWidth',1.5);
                ylabel('u / [kg/m^3]','FontWeight','bold');
                xlabel('\phi / [-]','FontWeight','bold');
                grid on;
                set(gca,'YScale','log')

                figure(4); clf; hold on;
                plot(rOl,lgKl,'d-b')
                ylabel('log10(rKl/[-])','FontWeight','bold');
                xlabel('u/u_{fs} / [-]','FontWeight','bold');
                grid on;
            end

            prop.rho = rho;
            prop.cp = cp;
            prop.lambda = lambda;
            prop.mu = mu;
            prop.ufs = psi_eff * rho_w;
            prop.FSF.u = u/rho_w/psi_eff;
            prop.FSF.phi = phi;
            prop.FSF.dudphi = diff(u/rho_w/psi_eff)./diff(phi);
            prop.FSF.k(1) = 1;
            prop.FSF.k(2) = 1;
            prop.K.kleff = Kl;
            prop.K.u = rOl;
            prop.K.kl = 10.^lgKl;

            % length(prop.FSF.phi)
            % length(prop.FSF.u)
            % length(prop.FSF.dudphi)

%             subplot(2,1,1);
%             plot(prop.FSF.phi,prop.FSF.u)
%             subplot(2,1,2);
%             plot(prop.FSF.phi,[prop.FSF.dudphi,0],'r-')


            if plotten
                figure(3); 
            end
            
            coeff = fminsearch(@(coeff) costfun(obj, rho_w,R_v,prop,phi(ind0:ind1),u(ind0:ind1),h1,coeff,plotten),[1,1]);
            prop.FSF.k(1) = coeff(1)*prop.FSF.k(1);
            prop.FSF.k(2) = coeff(2)*prop.FSF.k(2);

            if plotten
                figure(3)
                phi = [0:.00001:.95,.95+00001:.00001:1];
                for jj = 1:length(phi)
                    u(1) = phi(jj);
                    u(2) = 10+273.15;
                    if u(1) > 0 && u(1) < 1
                        u_phi(jj)=u_phi_calc(prop.ufs,rho_w,R_v,prop.FSF.k(1),prop.FSF.k(2),u(2),u(1));%kg/m^3
                    elseif u(1) >= 1
                        u_phi(jj) = prop.ufs;
                    elseif u(1) <= 0
                        u_phi(jj) = 0;
                    end
                end
            %     set(h1,'YData',u_phi);
                plot(phi,u_phi,'k--','LineWidth',1.5);
                title(['nr = ' int2str(nr_GLOBAL) ': k1/k2 = ' num2str(prop.FSF.k(1)) '/' num2str(prop.FSF.k(2))]) 
            end

            % S = strtrim(str)
            % odifiedStr = strrep(origStr, oldSubstr, newSubstr)

                %disp([num2str(prop.FSF.k(1)) ' ' num2str(prop.FSF.k(2))])
        end
        
        function err = costfun(obj, rho_w,R_v,prop,phi,u_phi1,h1,coeff,plotten)
            global nr_GLOBAL

            nr_GLOBAL = nr_GLOBAL+1;

            for jj = 1:length(phi)
                u(1) = phi(jj);
                u(2) = 10+273.15;
                if u(1) > 0 && u(1) < 1
                    u_phi(jj)=u_phi_calc(obj, prop.ufs,rho_w,R_v,prop.FSF.k(1)*coeff(1),prop.FSF.k(2)*coeff(2),u(2),u(1));%kg/m^3
                elseif u(1) >= 1
                    u_phi(jj) = prop.ufs;
                elseif u(1) <= 0
                    u_phi(jj) = 0;
                end
            end
        %     disp(num2str(phi))
        %     disp(num2str(u_phi))

            err = norm(u_phi-u_phi1);
        %     disp(['nr = ' int2str(nr_GLOBAL) ': ' num2str(err) ' c1/c2 = ' num2str(coeff(1)) '/' num2str(coeff(2)) ' k1/k2 = ' num2str(prop.FSF.k(1)*coeff(1)) '/' num2str(prop.FSF.k(2)*coeff(2))]) 
            if plotten
                set(h1,'YData',u_phi);
                title(['nr = ' int2str(nr_GLOBAL) ': ' num2str(err) ' k1 / k2 = ' num2str(prop.FSF.k(1)*coeff(1)) ' / ' num2str(prop.FSF.k(2)*coeff(2))]) 
                drawnow; 
                pause(.05);
            end
        end
        
        function u_phi=u_phi_calc(obj, u_f,rho_w,R_v,k1,k2,T,phi) 
            u_phi=u_f./(1+(-rho_w*R_v*T.*log(phi)./k1).^k2);%kg/m^3
        end
        
    end
end

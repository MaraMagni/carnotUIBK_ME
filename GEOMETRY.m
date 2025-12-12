%% GEOMETRY.m
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
% EL        2018-05-25   v1.3: in "geometry_from_PHPP" doors and thermal
%                        bridges implemented in the reading from PHPP
% DS,EL	    2019-01-29   updates for GUI v2.0

%%
classdef GEOMETRY
    % GEOMETRY
    
    properties
        name = 'new geometry';
        room = [];
    end
    
    methods
        function obj = GEOMETRY()
            
        end
        
        function obj = add_room(obj, name, area, height, wall, n50, wind_e_room)
            % to add a new room in the geometry
            % 1 ... name of the room
            % 2 ... heated area of the room
            % 3 ... height of the room
            % 4 ... list of the names of the walls that are part of the room
            % 5 ... n50 value
            % 6 ... wind protection coefficent e
            
            ind = [];
            
            for jj = 1:length(obj.room)
                if strcmp(obj.room(jj).name,name)
                    ind = strcmp(obj.room(jj).name,name);
                    break
                end
            end
            % check if room si already existing
            if ind
                error(['room ' name ' already existing!'])
            else
                new_ROOM = ROOM(name, area, height, wall, n50);
                if nargin > 6
                    new_ROOM.wind_e = wind_e_room;
                end
                
                obj.room = [obj.room new_ROOM];
            end
        end
        
        function obj = geometry_from_excel(obj, name_xls, building)
            % to take the geometry from the excel
            % 1 ... name of the excel file
            
            vollpfad = [pwd '\' name_xls];
            
            if exist(vollpfad, 'file')
                warning('Existing Excel file used.')
            else
                rootpath = fileparts(which('carnotUIBK'));
                copyfile([rootpath '\building_TEMPLATE.xlsx'], vollpfad);
                warning('New Excel file generated.')
            end
            
            try
                % modify excel for write weather
                Excel = actxserver('Excel.Application');
                Excel.Workbooks.Open(vollpfad);
                warning('Excel file opened for writing monthly temperatures! Do not interrupt this script!')

                [~, ~, raw_boundary] = xlsread1(name_xls, 'Boundary');

                raw_ground = raw_boundary(4:9,:);
                raw_neighbour = raw_boundary(14:19,:);
                raw_weather = raw_boundary(23,:);
                longitude = raw_weather{1,8};

                if isnan(longitude)
                else
                    name_txt = raw_weather{1,3};
                    weather = load(name_txt);
                    timevec_weather = linspace(-8760*3600, (building.maxruntime+1)*8760*3600, ((building.maxruntime+2)*size(weather,1)-(building.maxruntime+1)))';
                    weather_short = weather(1:(end-1),:);
                    for jj = 1:(building.maxruntime+1)
                        weather = [weather 
                                        weather_short];
                    end
                    weat_mon = [];
                    t_ambient = [timevec_weather weather(:,7)];
                    T_m = 365*24*3600 + ([0 31 (28+31) (31+28+31) (30+31+28+31) (31+30+31+28+31) (30+31+30+31+28+31) (31+30+31+30+31+28+31) (31+31+30+31+30+31+28+31) (30+31+31+30+31+30+31+28+31) (31+30+31+31+30+31+30+31+28+31) (30+31+30+31+31+30+31+30+31+28+31) (31+30+31+30+31+31+30+31+30+31+28+31)]*24*3600);
                    T_m = T_m/(t_ambient(2,1)-t_ambient(1,1));
                    for jj = 1:12
                        weat_mon(jj) = mean(t_ambient((T_m(jj)+1):(T_m(jj+1)),2));
                    end
                    xlswrite1(name_xls,weat_mon,'Ground','D2:O2')
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
            
            try
                Excel = actxserver('Excel.Application');
                Excel.Workbooks.Open(vollpfad);
                warning('Excel file opened! Do not interrupt this script!')

                [~, ~, raw_windoors] = xlsread1(name_xls, 'WinDoors');
                [~, ~, raw_str] = xlsread1(name_xls, 'Walls');
                [~, ~, raw_room] = xlsread1(name_xls, 'Rooms');

                Excel.Quit
                Excel.delete
                clear Excel
                warning('Excel file closed!')
            catch ME
                ME
                Excel.Quit
                Excel.delete
                clear Excel
                warning('Excel file closed!')
            end
            
            try
                raw_str(1:3,:) = [];
                raw_room(1,:) = [];
                raw_windoors(1:3,:) = [];

                for ii=1:size(raw_str,1)
                    if isnan(raw_str{ii,1})
                        break
                    end
                end
                raw_str(ii:end,:) = [];

                for ii=1:size(raw_room,1)
                    if isnan(raw_room{ii,1})
                        break
                    end
                end
                raw_room(ii:end,:) = [];

                for ii=1:size(raw_windoors,1)
                    if isnan(raw_windoors{ii,1})
                        break
                    end
                end
                raw_windoors(ii:end,:) = [];


                count_walls =[];
                count_win = [];
                for ii = 1:size(raw_str,1)
                    name_1 = raw_str{ii,2};
                    walls_list = [];
                    if all(ii ~= count_walls) && (1-strcmp(name_1, 'none'))
                        for jj = 1:size(raw_str,1)
                            name_2 = raw_str{jj,2};
                            if all(jj ~= count_walls) && (1-strcmp(name_2, 'none'))
                                if strcmp(name_1, name_2)
                                    name_room = name_2;
                                    windows_wa = [];
                                    doors_wa = [];
                                    count_walls = [count_walls jj];
                                    name_wa = raw_str{jj,1};
                                    X_wa = raw_str{jj,5};
                                    Y_wa = raw_str{jj,6};
                                    Z_wa = raw_str{jj,7};
                                    width_wa = raw_str{jj,8};
                                    height_wa = raw_str{jj,9};
                                    orientation_slope_wa = raw_str{jj,10};
                                    orientation_azimuth_wa = raw_str{jj,11};
                                    orientation_rotation_wa = raw_str{jj,12};
                                    boundary_wa = raw_str{jj,13};
                                    construction_wa = raw_str{jj,14};
                                    model_cons_wa = raw_str{jj,15};
                                    model_heattrans_wa = raw_str{jj,16};
                                    view_factor_wa = raw_str{jj,17};
                                    amb_factor_wa = raw_str{jj,18};
                                    inside_wa = raw_str{jj,19};
                                    model_inf_wa = raw_str{jj,20};
                                    C_wa(1) = raw_str{jj,21};
                                    C_wa(2) = raw_str{jj,22};
                                    C_wa(3) = raw_str{jj,23};
                                    n_wa(1) = raw_str{jj,24};
                                    n_wa(2) = raw_str{jj,25};
                                    n_wa(3) = raw_str{jj,26};
                                    V_wa(1) = raw_str{jj,27};
                                    V_wa(2) = raw_str{jj,28};
                                    V_wa(3) = raw_str{jj,29};
                                    control_i_wa = raw_str{jj,30};
                                    for ll = 1:size(raw_windoors,1)
    %                                     if strcmp(raw_windoors{ll,2},name_wa) && all(ll ~= count_win) && strcmp(raw_windoors{ll,1}, 'window')
                                        if strcmp(raw_windoors{ll,2},name_wa) && strcmp(raw_windoors{ll,1}, 'window')
                                            name_wi = raw_windoors{ll,2};
                                            model_cons_wi = raw_windoors{ll,10};
                                            X_wi = raw_windoors{ll,4};
                                            Y_wi = raw_windoors{ll,5};
                                            width_wi = raw_windoors{ll,6};
                                            height_wi = raw_windoors{ll,7};
                                            width_glass_wi = raw_windoors{ll,8};
                                            height_glass_wi = raw_windoors{ll,9};
                                            view_factor_wi = raw_windoors{ll,12};
                                            amb_factor_wi = raw_windoors{ll,13};
                                            shadingtop_wi(1) = raw_windoors{ll,14};
                                            shadingtop_wi(2) = raw_windoors{ll,15};
                                            shadingleft_wi(1) = raw_windoors{ll,16};
                                            shadingleft_wi(2) = raw_windoors{ll,17};
                                            shadingright_wi(1) = raw_windoors{ll,18};
                                            shadingright_wi(2) = raw_windoors{ll,19};
                                            shadinghorizont_wi(1) = raw_windoors{ll,20};
                                            shadinghorizont_wi(2) = raw_windoors{ll,21};
                                            % to get the values of fs and obtain always 12 values (1 per month)
                                            time_months = [0 31 59 90 120 151 181 212 243 273 304 334]*24*3600;
                                            seq_factor_ = [];
                                            if raw_windoors{ll,40} == 0
                                                seq_factor_ = ones(1,12) * raw_windoors{ll,41};
                                            elseif raw_windoors{ll,40} == 1
                                                fs_w = raw_windoors{ll,41};
                                                fs_s = raw_windoors{ll,42};
                                                seq_factor_ = [fs_w fs_w fs_w fs_w fs_s fs_s fs_s fs_s fs_s fs_w fs_w fs_w];
                                            elseif raw_windoors{ll,40} == 2
                                                seq_factor_ = [raw_windoors{ll,41} raw_windoors{ll,42} raw_windoors{ll,43} raw_windoors{ll,44} raw_windoors{ll,45} raw_windoors{ll,46} raw_windoors{ll,47} raw_windoors{ll,48} raw_windoors{ll,49} raw_windoors{ll,50} raw_windoors{ll,51} raw_windoors{ll,52}];
                                            end
                                            fstime_wi = [];
                                            fsvalue_wi = [];
                                            fstime_wi = [time_months 365*24*3600];
                                            fsvalue_wi = [seq_factor_ seq_factor_(1)];
%                                             for lll = -1:building.maxruntime
%                                                 if lll == building.maxruntime
%                                                     fstime_wi = [fstime_wi time_months+lll*365*24*3600 365*24*3600*(building.maxruntime+1)];
%                                                     fsvalue_wi = [fsvalue_wi seq_factor_ seq_factor_(1)];
%                                                 else
%                                                     fstime_wi = [fstime_wi time_months+lll*365*24*3600];
%                                                     fsvalue_wi = [fsvalue_wi seq_factor_];
%                                                 end
%                                             end
                                            fd_wi = raw_windoors{ll,22};
                                            psi_i_wi(1,1) = raw_windoors{ll,23};
                                            psi_i_wi(1,2) = raw_windoors{ll,24};
                                            psi_i_wi(2,1) = raw_windoors{ll,25};
                                            psi_i_wi(2,2) = raw_windoors{ll,26};
                                            control_s_wi = raw_windoors{ll,27};
                                            construction_wi = raw_windoors{ll,11};
                                            model_inf_wi = raw_windoors{ll,29};
                                            C_wi(1) = raw_windoors{ll,30};
                                            C_wi(2) = raw_windoors{ll,31};
                                            C_wi(3) = raw_windoors{ll,32};
                                            n_wi(1) = raw_windoors{ll,33};
                                            n_wi(2) = raw_windoors{ll,34};
                                            n_wi(3) = raw_windoors{ll,35};
                                            V_wi(1) = raw_windoors{ll,36};
                                            V_wi(2) = raw_windoors{ll,37};
                                            V_wi(3) = raw_windoors{ll,38};
                                            control_i_wi = raw_windoors{ll,39};
                                            count_win = [count_win ll];
                                            windows_wa = [windows_wa WINDOW(name_wi, model_cons_wi, X_wi, Y_wi, width_wi, height_wi, width_glass_wi, height_glass_wi, view_factor_wi, amb_factor_wi, shadingtop_wi, shadingleft_wi, shadingright_wi, shadinghorizont_wi, fstime_wi, fsvalue_wi, fd_wi, psi_i_wi, control_s_wi, construction_wi, model_inf_wi, C_wi, n_wi, V_wi, control_i_wi)];
    %                                     elseif strcmp(raw_windoors{ll,2},name_wa) && all(ll ~= count_win) && strcmp(raw_windoors{ll,1}, 'door')
                                        elseif strcmp(raw_windoors{ll,2},name_wa) && strcmp(raw_windoors{ll,1}, 'door')
                                            name_do = raw_windoors{ll,2};
                                            X_do = raw_windoors{ll,4};
                                            Y_do = raw_windoors{ll,5};
                                            width_do = raw_windoors{ll,6};
                                            height_do = raw_windoors{ll,7};
                                            construction_do = raw_windoors{ll,11};
                                            model_heattrans_do = raw_windoors{ll,28};
                                            model_cons_do = raw_windoors{ll,10};
                                            view_factor_do = raw_windoors{ll,12};
                                            amb_factor_do = raw_windoors{ll,13};
                                            C_do(1) = raw_windoors{ll,30};
                                            C_do(2) = raw_windoors{ll,31};
                                            C_do(3) = raw_windoors{ll,32};
                                            n_do(1) = raw_windoors{ll,33};
                                            n_do(2) = raw_windoors{ll,34};
                                            n_do(3) = raw_windoors{ll,35};
                                            V_do(1) = raw_windoors{ll,36};
                                            V_do(2) = raw_windoors{ll,37};
                                            V_do(3) = raw_windoors{ll,38};
                                            control_i_do = raw_windoors{ll,39};
                                            model_inf_do = raw_windoors{ll,29};
                                            count_win = [count_win ll];
                                            doors_wa = [doors_wa DOOR(name_do, X_do, Y_do, width_do, height_do, construction_do, model_heattrans_do, model_cons_do, view_factor_do, amb_factor_do, C_do, n_do, V_do, control_i_do, model_inf_do)];
                                        end
                                    end
                                    walls_list = [walls_list WALL(name_wa, boundary_wa, X_wa, Y_wa, Z_wa, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, orientation_rotation_wa, inside_wa, construction_wa, model_cons_wa, model_heattrans_wa, view_factor_wa, amb_factor_wa, model_inf_wa, C_wa, n_wa, V_wa, control_i_wa, windows_wa, doors_wa)];
                                end
                            end
                        end
                        for mm = 1 : size(raw_room,1)
                            name_file = raw_room{mm,1};
                            if strcmp(name_room, name_file)
                                area_room = raw_room{mm,2};
                                heated_volume = raw_room{mm,3};
                                n50_room = raw_room{mm,4};
                                obj = obj.add_room(name_room, area_room, heated_volume/area_room, walls_list, n50_room);
                            end
                        end 
                    end
                end
            catch ME
                ME
            end
        end
        
        function obj = geometry_to_excel(obj, name_xls, building, variant_geometry)
            % to put the geometry data into the excel
            % 1 ... name of the excel file
            
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
            
            try
                % to delete the raws of the excel
                xlswrite1(name_xls,{''},'Walls','A4:AD800')
                xlswrite1(name_xls,{''},'WinDoors','A4:AZ800')
                xlswrite1(name_xls,{''},'Rooms','A7:D800')
                
                wall_names_list = {};
                wall_count = 0;
                windoor_count = 0;
                room_count = 0;
                
                for ii=1:size(building.geometry(variant_geometry).room,2)
                    room_count = room_count +1;
                    matrix_to_write_room(room_count,:) = [{building.geometry(variant_geometry).room(ii).name} {building.geometry(variant_geometry).room(ii).area} {building.geometry(variant_geometry).room(ii).area * building.geometry(variant_geometry).room(ii).height} {building.geometry(variant_geometry).room(ii).n50} ];

                    for jj = 1: size(building.geometry(variant_geometry).room(ii).wall,2)
                        wall_names_list = [wall_names_list, {building.geometry(variant_geometry).room(ii).wall(jj).name}];
                        wall_count = wall_count+1;

                        wall_pfad = building.geometry(variant_geometry).room(ii).wall(jj);

                        %definition wall_orientation
                        if wall_pfad.orientation_slope == 90
                           if (wall_pfad.orientation_azimuth>=-45-360 && wall_pfad.orientation_azimuth<45-360) || (wall_pfad.orientation_azimuth>=-45 && wall_pfad.orientation_azimuth<45) || (wall_pfad.orientation_azimuth>=315 && wall_pfad.orientation_azimuth<=405)
                               wall_orientation{wall_count} = 'S';
                           elseif (wall_pfad.orientation_azimuth>=135 && wall_pfad.orientation_azimuth<225) || (wall_pfad.orientation_azimuth>=-225 && wall_pfad.orientation_azimuth<-135)
                               wall_orientation{wall_count} = 'N';
                           elseif (wall_pfad.orientation_azimuth>=225 && wall_pfad.orientation_azimuth<315) || (wall_pfad.orientation_azimuth>=-135 && wall_pfad.orientation_azimuth<-45)
                               wall_orientation{wall_count} = 'E'; %EV, before: 'W'
                           elseif (wall_pfad.orientation_azimuth>=45 && wall_pfad.orientation_azimuth<135) || (wall_pfad.orientation_azimuth>=45-360 && wall_pfad.orientation_azimuth<135-360)
                               wall_orientation{wall_count} = 'W'; %EV, before: 'E'
                           end
                        elseif wall_pfad.orientation_slope == 180 || wall_pfad.orientation_slope == (-180)
                            wall_orientation{wall_count} = 'floor';%'ceil'; %EV
                        elseif wall_pfad.orientation_slope == 0
                            wall_orientation{wall_count} = 'ceil';%'floor'; %EV
                        else
                            wall_orientation{wall_count} = 'roof';
                        end

                        val = sum(strcmp(wall_orientation,wall_orientation{wall_count}));

                        % definition n_wall
                        n_wall(wall_count) = val;

                        matrix_to_write_wall(wall_count,:) = [{wall_pfad.name} {building.geometry(variant_geometry).room(ii).name} ...
                           {wall_orientation{wall_count}} {n_wall(wall_count)} {wall_pfad.X(1)} {wall_pfad.Y(1)} {wall_pfad.Z(1)} {wall_pfad.width} {wall_pfad.height}...
                           {wall_pfad.orientation_slope} {wall_pfad.orientation_azimuth} {wall_pfad.orientation_rotation} {wall_pfad.boundary}...
                           {wall_pfad.construction} {wall_pfad.model_cons} {wall_pfad.model_heattrans} {wall_pfad.view_factor}...
                           {wall_pfad.amb_factor} {wall_pfad.inside} {wall_pfad.model_inf} {wall_pfad.C(1)} {wall_pfad.C(2)} {wall_pfad.C(3)}...
                           {wall_pfad.n(1)} {wall_pfad.n(2)} {wall_pfad.n(3)} {wall_pfad.V(1)} {wall_pfad.V(2)} {wall_pfad.V(3)} {wall_pfad.control_i}];

                        for kk = 1:size(building.geometry(variant_geometry).room(ii).wall(jj).windows,2)

                            windoor_count = windoor_count+1;

                            window_pfad = building.geometry(variant_geometry).room(ii).wall(jj).windows(kk);

                            matrix_to_write_windoor(windoor_count,:) = [{'window'} {building.geometry(variant_geometry).room(ii).wall(jj).name} {wall_orientation{wall_count}}...
                                {window_pfad.X} {window_pfad.Y} {window_pfad.width} {window_pfad.height} {window_pfad.width_glass} {window_pfad.height_glass}...
                                {window_pfad.model_cons} {window_pfad.construction} {window_pfad.view_factor} {window_pfad.amb_factor}  {window_pfad.shadingtop(1)}...
                                {window_pfad.shadingtop(2)} {window_pfad.shadingleft(1)} {window_pfad.shadingleft(2)} {window_pfad.shadingright(1)} {window_pfad.shadingright(2)}...
                                {window_pfad.shadinghorizont(1)} {window_pfad.shadinghorizont(2)} {window_pfad.fd} {window_pfad.psi_i(1)} {window_pfad.psi_i(3)}...
                                {window_pfad.psi_i(2)} {window_pfad.psi_i(4)} {window_pfad.control_s} {0} {window_pfad.model_inf} {window_pfad.C(1)} {window_pfad.C(2)} {window_pfad.C(3)}...
                                {window_pfad.n(1)} {window_pfad.n(2)} {window_pfad.n(3)} {window_pfad.V(1)} {window_pfad.V(2)} {window_pfad.V(3)} {window_pfad.control_i}...
                                {'2'} {window_pfad.fsvalue(1)} {window_pfad.fsvalue(2)} {window_pfad.fsvalue(3)} {window_pfad.fsvalue(4)} {window_pfad.fsvalue(5)} {window_pfad.fsvalue(6)} {window_pfad.fsvalue(7)} {window_pfad.fsvalue(8)} {window_pfad.fsvalue(9)} {window_pfad.fsvalue(10)} {window_pfad.fsvalue(11)} {window_pfad.fsvalue(12)}...
                                ];
                            % devo ancora capire come fare per fs
                        end

                        for ll = 1:size(building.geometry(variant_geometry).room(ii).wall(jj).doors,2)

                            windoor_count = windoor_count+1;

                            door_pfad = building.geometry(variant_geometry).room(ii).wall(jj).doors(ll);

                            matrix_to_write_windoor(windoor_count,:) = [{'door'} {building.geometry(variant_geometry).room(ii).wall(jj).name} {wall_orientation{wall_count}}...
                                {door_pfad.X} {door_pfad.Y} {door_pfad.width} {door_pfad.height} {' '} {' '}...
                                {door_pfad.model_cons} {door_pfad.construction} {door_pfad.view_factor} {door_pfad.amb_factor} ...
                                {''} {''} {''} {''} {''} {''} {''} {''} {''} {''} {''} {''} {''} {' '} {0} {door_pfad.model_inf} {door_pfad.C(1)} {door_pfad.C(2)} {door_pfad.C(3)}...
                                {door_pfad.n(1)} {door_pfad.n(2)} {door_pfad.n(3)} {door_pfad.V(1)} {door_pfad.V(2)} {door_pfad.V(3)} {door_pfad.control_i}...
                                {''} {''} {''} {''} {''} {''} {''} {''} {''} {''} {''} {''} {''} 
                                ];
                        end
                    end
                end    
                xlswrite1(name_xls,matrix_to_write_room,'Rooms',['A7:D' num2str(room_count+6)]) 
                xlswrite1(name_xls,matrix_to_write_wall,'Walls',['A4:AD' num2str(wall_count+3)])
                xlswrite1(name_xls,matrix_to_write_windoor,'WinDoors',['A4:AZ' num2str(windoor_count+3)])
                Excel.ActiveWorkbook.Save
                Excel.Quit
                Excel.delete
                clear Excel
                warning('Excel file closed!')
            catch ME
                warning('Export to Excel was not possible!')              
                Excel.ActiveWorkbook.Save
                Excel.Quit
                Excel.delete
                clear Excel
                warning('Excel file closed!')
            end
            
        end
        
        function obj = geometry_from_XML_andor_excel(obj, name_XML, building, name_xls, excel_create)
            % function to create the building object (geometry and thermal
            % zone) from a XML file created with sketch up. If it is given
            % also an excel name, A. it creates the excel if it is empty;
            % OR B. it takes  the features that aren't defined in sketch up
            % from the excel file; OR C. modify the geometry in excel if
            % the sketch up file is modified (for example, if rooms are
            % added or modified)
            % 1 ... name of the XML file
            % 2 ... building object
            % 3 ... name of the excel file (optional)
            % 4 ... flag to create excel file (optional)
			
			% bugfixing ongoing
            % excel_create= 'structure';
            
            if nargin < 3
                error('number of input not correct (at least 2)')
            else
                if nargin < 4
                    name_xls = 'temp.xlsx';
                end
                
                vollpfad = [pwd '\' name_xls];
                
                if exist(vollpfad, 'file')
                    warning('Existing Excel file used.')
                else
                    rootpath = fileparts(which('carnotUIBK'));
                    copyfile([rootpath '\building_TEMPLATE.xlsx'], vollpfad);
                    warning('New Excel file generated.')
                end
                
                try
                    % modify excel for write weather
                    Excel = actxserver('Excel.Application');
                    Excel.Workbooks.Open(vollpfad);
                    warning('Excel file opened for writing monthly temperatures! Do not interrupt this script!')

                    [~, ~, raw_boundary] = xlsread1(name_xls, 'Boundary');

                    raw_ground = raw_boundary(4:9,:);
                    raw_neighbour = raw_boundary(14:19,:);
                    raw_weather = raw_boundary(23,:);
                    longitude = raw_weather{1,8};

                    if isnan(longitude)
                        warning('Weather not defined in Excel!')
                    else
                        name_txt = raw_weather{1,3};

                        weather = load(name_txt);
                        timevec_weather = linspace(-8760*3600, (building.maxruntime+1)*8760*3600, ((building.maxruntime+2)*size(weather,1)-(building.maxruntime+1)))';
                        weather_short = weather(1:(end-1),:);
                        for jj = 1:(building.maxruntime+1)
                            weather = [weather 
                                            weather_short];
                        end
                        weat_mon = [];
                        t_ambient = [timevec_weather weather(:,7)];
                        T_m = 365*24*3600 + ([0 31 (28+31) (31+28+31) (30+31+28+31) (31+30+31+28+31) (30+31+30+31+28+31) (31+30+31+30+31+28+31) (31+31+30+31+30+31+28+31) (30+31+31+30+31+30+31+28+31) (31+30+31+31+30+31+30+31+28+31) (30+31+30+31+31+30+31+30+31+28+31) (31+30+31+30+31+31+30+31+30+31+28+31)]*24*3600);
                        T_m = T_m/(t_ambient(2,1)-t_ambient(1,1));
                        for jj = 1:12
                            weat_mon(jj) = mean(t_ambient((T_m(jj)+1):(T_m(jj+1)),2));
                        end
                       xlswrite1(name_xls,weat_mon,'Ground','D2:O2')
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
                
                try
                    Excel = actxserver('Excel.Application');
                    Excel.Workbooks.Open(vollpfad);
                    warning('Excel file opened! Do not interrupt this script!')

                    % load data from the xml file
                    building_xml = xml2struct(name_XML);
                    name_XML = building_xml.gbXML;

                    % load data from the excel file
                    [~, ~, raw_windoors_excel] = xlsread1(name_xls, 'WinDoors');
                    [~, ~, raw_str_excel] = xlsread1(name_xls, 'Walls');
                    [~, ~, raw_room_excel] = xlsread1(name_xls, 'Rooms');
                    raw_str_excel(1:3,:) = [];
                    raw_room_excel(1:6,:) = [];
                    raw_windoors_excel(1:3,:) = [];
                    
                    ProgramInfo = '';
                    try
                        if strcmp(name_XML.DocumentHistory.ProgramInfo.Attributes.id,'openstudio')
                            ProgramInfo = name_XML.DocumentHistory.ProgramInfo.Attributes.id;
                        elseif strcmp(name_XML.DocumentHistory.ProgramInfo.Attributes.id,'aim0004')
                            ProgramInfo = 'revit';
                        else
                            ProgramInfo = '';
                        end
                    catch
                        ProgramInfo = '';
                    end

                    raw_wall = 0;
                    raw_room = 0;
                    raw_windoors = 0;
                    for jk=1:length(name_XML.Campus.Building.Space)
                        walls_list = [];
                        
                        name_XML.Campus.Building.Space;
                        
                        if length(name_XML.Campus.Building.Space) == 1
                            Space = name_XML.Campus.Building.Space;
                        else
                            Space = name_XML.Campus.Building.Space{jk};
                        end
                        
                        name_room = Space.Attributes.id;
                        
                        if strcmp(ProgramInfo,'openstudio')
                            name_room_text = Space.Attributes.id;
                        elseif strcmp(ProgramInfo,'revit')
                            name_room_text = Space.Name.Text;
                        else
                            name_room_text = Space.Attributes.id;
                        end
                        if strcmp(name_room,'') || strcmp(name_room,'Shading_Surface_Group_1')
                            return
                        end
                        area_room = str2double(Space.Area.Text);
                        heated_volume = str2double(Space.Volume.Text);
                        check = 0;
                        for ii = 1:size(raw_room_excel,1)
                            if strcmp(raw_room_excel{ii,1},name_room)
                                n50_room = raw_room_excel{ii,4};
                                check = 1;
                                vector_room = {name_room, area_room, heated_volume};
                                xlRange = ['A' num2str(ii+6) ':C' num2str(ii+6)];
                                xlswrite1(name_xls,vector_room,'Rooms',xlRange)
                                break
                            end
                        end
                        if check == 0 || nargin == 3                    
                            if strcmp(excel_create, 'structure')
%                                 warning(['Room ' name_room ' does not exist in excel file'])
                            end
                            n50_room = 0.6;
                            vector_room = {name_room, area_room, heated_volume, ones(size(heated_volume))*n50_room};
                            xlRange = ['A' num2str(6+1+size(raw_room_excel,1)+raw_room) ':D' num2str(6+size(raw_room_excel,1)+1+raw_room)];
                            xlswrite1(name_xls,vector_room,'Rooms',xlRange)
                            raw_room = raw_room +1;
                        end

                        count_s = 0;
                        count_n = 0;
                        count_e = 0;
                        count_w = 0;
                        count_r = 0;
                        count_f = 0;
                        count_c = 0;

                        for jjk=1:length(name_XML.Campus.Surface)
                            if isfield(name_XML.Campus.Surface{jjk},'AdjacentSpaceId')
                                for jjjk=1:length(name_XML.Campus.Surface{jjk}.AdjacentSpaceId)
                                    if length(name_XML.Campus.Surface{jjk}.AdjacentSpaceId) > 1
                                        check_roomname = strcmp(name_room, name_XML.Campus.Surface{jjk}.AdjacentSpaceId{jjjk}.Attributes.spaceIdRef);
                                    else
                                        check_roomname = strcmp(name_room, name_XML.Campus.Surface{jjk}.AdjacentSpaceId.Attributes.spaceIdRef);
                                    end
                                    if check_roomname
                                        windows_wa = [];
                                        doors_wa = [];
                                        
                                        X_wa_full = [];
                                        Y_wa_full = [];
                                        Z_wa_full = [];
                                        for jjkc = 1:length(name_XML.Campus.Surface{jjk}.PlanarGeometry.PolyLoop.CartesianPoint)
                                            X_wa_full = [X_wa_full str2double(name_XML.Campus.Surface{jjk}.PlanarGeometry.PolyLoop.CartesianPoint{jjkc}.Coordinate{1}.Text)];
                                            Y_wa_full = [Y_wa_full str2double(name_XML.Campus.Surface{jjk}.PlanarGeometry.PolyLoop.CartesianPoint{jjkc}.Coordinate{2}.Text)];
                                            Z_wa_full = [Z_wa_full str2double(name_XML.Campus.Surface{jjk}.PlanarGeometry.PolyLoop.CartesianPoint{jjkc}.Coordinate{3}.Text)];
                                        end
                                        X_wa = str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.CartesianPoint.Coordinate{1}.Text);
                                        Y_wa = str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.CartesianPoint.Coordinate{2}.Text);
                                        Z_wa = str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.CartesianPoint.Coordinate{3}.Text);
                                        width_wa = str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.Width.Text);
                                        height_wa = str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.Height.Text);
                                        
                                        if (str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.Azimuth.Text))== 0 %EV: east and west were wrong. Before: orientation_azimuth_wa = (str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.Azimuth.Text)-180)*(-1);
                                            orientation_azimuth_wa = 180;
                                        else
                                            orientation_azimuth_wa = (str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.Azimuth.Text)-180);
                                        end
                                        orientation_slope_wa = str2double(name_XML.Campus.Surface{jjk}.RectangularGeometry.Tilt.Text);
                                        if orientation_azimuth_wa >= 360
                                            orientation_azimuth_wa = orientation_azimuth_wa-360;
                                        end
                                        if orientation_azimuth_wa >= 360
                                            orientation_azimuth_wa = orientation_azimuth_wa-360;
                                        end

                                        if orientation_slope_wa == 90 || orientation_slope_wa == (-90)
                                            if orientation_azimuth_wa<=45 && orientation_azimuth_wa>=(-45)  || orientation_azimuth_wa>=315
                                                if jjjk == 1
                                                    or = 'S';
                                                    count_s = count_s+1;
                                                    n = count_s;
                                                else
                                                    or = 'N';
                                                    count_n = count_n+1;
                                                    n = count_n;
                                                    orientation_azimuth_wa=orientation_azimuth_wa+180; %EV
                                                end
                                            elseif orientation_azimuth_wa<(-45) && orientation_azimuth_wa>(-135) || orientation_azimuth_wa>225 && orientation_azimuth_wa<315
                                                if jjjk == 1
                                                    or = 'E';
                                                    count_e = count_e+1;
                                                    n = count_e;
                                                else
                                                    or = 'W';
                                                    count_w = count_w+1;
                                                    n = count_w;
                                                    orientation_azimuth_wa=orientation_azimuth_wa+180; %EV
                                                end
                                            elseif orientation_azimuth_wa<135 && orientation_azimuth_wa>45
                                                if jjjk == 1
                                                    or = 'W';
                                                    count_w = count_w+1;
                                                    n = count_w;
                                                else
                                                    or = 'E';
                                                    count_e = count_e+1;
                                                    n = count_e;
                                                    orientation_azimuth_wa=orientation_azimuth_wa-180; %EV
                                                end
                                            elseif orientation_azimuth_wa<=225 && orientation_azimuth_wa>=135 || orientation_azimuth_wa<=(-135) && orientation_azimuth_wa>=(-225)
                                                if jjjk == 1
                                                    or = 'N';
                                                    count_n = count_n+1;
                                                    n = count_n;
                                                else
                                                    or = 'S';
                                                    count_s = count_s+1;
                                                    n = count_s;
                                                    orientation_azimuth_wa=orientation_azimuth_wa-180; %EV
                                                end
                                            end
                                            name_wa = [name_room '_wall_' or num2str(n)];
                                        elseif orientation_slope_wa == 180 || orientation_slope_wa == -180
                                            if jjjk == 1
                                                or = 'floor';
                                                count_f = count_f+1;
                                                n = count_f;
                                            else
                                                or = 'ceil';
                                                count_c = count_c+1;
                                                n = count_c;
                                                orientation_slope_wa = 0; %EV
                                            end
                                            name_wa = [name_room '_' or num2str(n)];
                                        elseif orientation_slope_wa == 0
                                            if jjjk == 1
                                                or = 'ceil';
                                                count_c = count_c+1;
                                                n = count_c;
                                            else
                                                or = 'floor';
                                                count_f = count_f+1;
                                                n = count_f;
                                                orientation_slope_wa =180; %EV
                                            end
                                            name_wa = [name_room '_' or num2str(n)];
                                        else
                                            or ='roof';
                                            count_r = count_r+1;
                                            n = count_r;
                                            name_wa = [name_room '_' or num2str(n)];
                                        end

                                        if orientation_slope_wa == 0 || orientation_slope_wa == 180 || orientation_slope_wa == -180 || orientation_slope_wa == 360
                                            try
                                                if strcmp(ProgramInfo,'openstudio')
                                                    orientation_azimuth_wa = orientation_azimuth_wa + 90;
                                                end
                                            catch
                                            end
                                        end
                                        orientation_rotation_wa = 0;
                                        boundary_wa_ = name_XML.Campus.Surface{jjk}.Attributes.surfaceType;
                                        switch boundary_wa_
                                            case 'ExteriorWall'
                                                boundary_wa = 'AMBIENT';
                                            case 'Roof'
                                                boundary_wa = 'AMBIENT';
                                            case 'Ceiling'
                                                if length(name_XML.Campus.Surface{jjk}.AdjacentSpaceId) > 1
                                                    if jjjk == 1
                                                        boundary_wa = name_XML.Campus.Surface{jjk}.AdjacentSpaceId{2}.Attributes.spaceIdRef;
                                                    else
                                                        boundary_wa = name_XML.Campus.Surface{jjk}.AdjacentSpaceId{1}.Attributes.spaceIdRef;
                                                    end
                                                else
                                                    boundary_wa = 'INTERNAL';
                                                end
                                            case 'RaisedFloor'
                                                boundary_wa = 'AMBIENT';  
                                            case 'SlabOnGrade'
                                                boundary_wa = 'GROUND';
                                            case 'UndergroundWall'
                                                boundary_wa = 'GROUND';
                                            case 'UndergroundSlab'
                                                boundary_wa = 'GROUND';
                                            case 'InteriorWall'
                                                if length(name_XML.Campus.Surface{jjk}.AdjacentSpaceId) > 1
                                                    if jjjk == 1
                                                        boundary_wa = name_XML.Campus.Surface{jjk}.AdjacentSpaceId{2}.Attributes.spaceIdRef;
                                                    else
                                                        boundary_wa = name_XML.Campus.Surface{jjk}.AdjacentSpaceId{1}.Attributes.spaceIdRef;
                                                    end
                                                else
                                                    boundary_wa = 'INTERNAL';
                                                end
                                            case 'InteriorFloor'
                                                if length(name_XML.Campus.Surface{jjk}.AdjacentSpaceId) > 1
                                                    if jjjk == 1
                                                        boundary_wa = name_XML.Campus.Surface{jjk}.AdjacentSpaceId{2}.Attributes.spaceIdRef;
                                                    else
                                                        boundary_wa = name_XML.Campus.Surface{jjk}.AdjacentSpaceId{1}.Attributes.spaceIdRef;
                                                    end
                                                else
                                                    boundary_wa = 'INTERNAL';
                                                end
                                            otherwise
                                                warning(['The surface ' name_XML.Campus.Surface{jjk}.Attributes.id ' has an unknown boundary type ' boundary_wa_ '!'])
                                                boundary_wa = 'AMBIENT';
                                        end
                                        try
                                            if strcmp(ProgramInfo,'openstudio')
                                                construction_wa = name_XML.Campus.Surface{jjk}.Attributes.constructionIdRef;
                                            elseif strcmp(ProgramInfo,'revit')
                                                construction_wa = name_XML.Campus.Surface{jjk}.CADObjectId.Text;
                                            else
                                                construction_wa = name_XML.Campus.Surface{jjk}.Attributes.constructionIdRef;
                                            end
                                        catch
                                            warning(['No construction definied for surface ' name_XML.Campus.Surface{jjk}.Attributes.id])
                                            construction_wa = '';
                                        end
                                        if strcmp(boundary_wa, 'AMBIENT') && orientation_slope_wa == 0
                                            view_factor_wa = 1.0;
                                            amb_factor_wa = 0.0; %EV
%                                         elseif strcmp(boundary_wa, 'AMBIENT') && orientation_slope_wa == 0 %EV
%                                             view_factor_wa = 1.0;
%                                             amb_factor_wa = 0.0;
                                        elseif strcmp(boundary_wa, 'AMBIENT')
                                            view_factor_wa = 1.0;
                                            amb_factor_wa = 0.5;
                                        else
                                            view_factor_wa = 1.0;
                                            amb_factor_wa = 1.0;
                                        end

                                        if nargin == 5
                                            check = 0;
                                            for ii = 1:size(raw_str_excel,1)
                                                if strcmp(raw_str_excel{ii,1},name_wa)
                                                    check = 1;
                                                    model_cons_wa = raw_str_excel{ii,15};
                                                    model_heattrans_wa = raw_str_excel{ii,16};
                                                    view_factor_wa = raw_str_excel{ii,17};
                                                    inside_wa = raw_str_excel{ii,19};
                                                    model_inf_wa = raw_str_excel{ii,20};
                                                    C_wa(1) = raw_str_excel{ii,21};
                                                    C_wa(2) = raw_str_excel{ii,22};
                                                    C_wa(3) = raw_str_excel{ii,23};
                                                    n_wa(1) = raw_str_excel{ii,24};
                                                    n_wa(2) = raw_str_excel{ii,25};
                                                    n_wa(3) = raw_str_excel{ii,26};
                                                    V_wa(1) = raw_str_excel{ii,27};
                                                    V_wa(2) = raw_str_excel{ii,28};
                                                    V_wa(3) = raw_str_excel{ii,29};
                                                    control_i_wa = raw_str_excel{ii,30};
                                                    vector_wall = {name_wa, name_room, or, 1, X_wa, Y_wa, Z_wa, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, 0, boundary_wa, construction_wa, model_cons_wa, model_heattrans_wa, view_factor_wa, amb_factor_wa};
                                                    xlRange = ['A' num2str(ii+3) ':R' num2str(ii+3)];
                                                    xlswrite1(name_xls,vector_wall,'Walls',xlRange)
                                                    break
                                                end
                                            end
                                        end
                                        if check == 0 || nargin == 3
                                            if strcmp(excel_create, 'structure')
%                                                 warning(['Wall ' name_wa ' not defined in excel file'])
                                            end
                                            vector_wall_1 = {name_wa, name_room, or, n, X_wa, Y_wa, Z_wa, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, 0, boundary_wa, construction_wa};
                                            xlRange = ['A' num2str(3+size(raw_str_excel,1)+1+raw_wall) ':N' num2str(3+size(raw_str_excel,1)+1+raw_wall)];
                                            xlswrite1(name_xls,vector_wall_1,'Walls',xlRange)

                                            vector_wall_2 = {1, 2, view_factor_wa, amb_factor_wa, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};
                                            xlRange = ['O' num2str(3+size(raw_str_excel,1)+1+raw_wall) ':AD' num2str(3+size(raw_str_excel,1)+1+raw_wall)];
                                            xlswrite1(name_xls,vector_wall_2,'Walls',xlRange)

                                            raw_wall = raw_wall+1;
                                            model_cons_wa = 1;
                                            model_heattrans_wa = 2;
                                            inside_wa = 1;
                                            model_inf_wa = 0;
                                            C_wa(1) = 0;
                                            C_wa(2) = 0;
                                            C_wa(3) = 0;
                                            n_wa(1) = 0;
                                            n_wa(2) = 0;
                                            n_wa(3) = 0;
                                            V_wa(1) = 0;
                                            V_wa(2) = 0;
                                            V_wa(3) = 0;
                                            control_i_wa = 1;
                                        end

                                        if isfield(name_XML.Campus.Surface{jjk},'Opening')
                                            for jjjk = 1:length(name_XML.Campus.Surface{jjk}.Opening)
                                                if length(name_XML.Campus.Surface{jjk}.Opening) > 1
                                                    openingType = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.openingType;
                                                else
                                                    openingType = name_XML.Campus.Surface{jjk}.Opening.Attributes.openingType;
                                                end
                                                switch openingType
                                                    case {'FixedWindow','OperableWindow'}
                                                        if length(name_XML.Campus.Surface{jjk}.Opening) > 1
                                                            name_wi = ['window_' name_wa ];
                                                            try
                                                                if strcmp(ProgramInfo,'openstudio')
                                                                    try     %EV, before: construction_wi = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                        construction_wi = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.windowTypeIdRef; 
                                                                    end
                                                                    try
                                                                        construction_wi = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                    end
                                                                elseif strcmp(ProgramInfo,'revit')
                                                                    construction_wi = name_XML.Campus.Surface{jjk}.Opening{jjjk}.CADObjectId.Text;
                                                                else
                                                                    construction_wi = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                end
                                                            catch
                                                                warning(['No construction definied for opening ' name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.id])
                                                                construction_wi = '';
                                                            end
                                                            width_wi = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.Width.Text);
                                                            height_wi = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.Height.Text);
                                                            if orientation_slope_wa == 90
                                                                if (strcmp(ProgramInfo,'openstudio') || strcmp(ProgramInfo,'revit'))
                                                                    Xs = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{1}.Text) - X_wa;
                                                                    Ys = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{2}.Text) - Y_wa;
                                                                    X_wi = sqrt(Xs^2+Ys^2);
                                                                    Y_wi = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{3}.Text) - Z_wa;
                                                                else
                                                                    X_wi = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{1}.Text);
                                                                    Y_wi = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{2}.Text);
                                                                end
                                                            else
                                                                X_wi = 0.0;
                                                                Y_wi = 0.0;
                                                            end
                                                        else
                                                            name_wi = ['window_' name_wa ];
                                                            try
                                                                if strcmp(ProgramInfo,'openstudio')
                                                                    try     %EV, before: construction_wi = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                        construction_wi = name_XML.Campus.Surface{jjk}.Opening.Attributes.windowTypeIdRef; 
                                                                    end
                                                                    try
                                                                        construction_wi = name_XML.Campus.Surface{jjk}.Opening.Attributes.constructionIdRef; 
                                                                    end    
                                                                elseif strcmp(ProgramInfo,'revit')
                                                                    construction_wi = name_XML.Campus.Surface{jjk}.Opening{jjjk}.CADObjectId.Text;
                                                                else
                                                                    construction_wi = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                end
                                                            catch
                                                                warning(['No construction definied for opening ' name_XML.Campus.Surface{jjk}.Opening.Attributes.id])
                                                                construction_wi = '';
                                                            end
                                                            width_wi = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.Width.Text);
                                                            height_wi = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.Height.Text);
                                                            if orientation_slope_wa == 90
                                                                if (strcmp(ProgramInfo,'openstudio') || strcmp(ProgramInfo,'revit'))
                                                                    Xs = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{1}.Text) - X_wa;
                                                                    Ys = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{2}.Text) - Y_wa;
                                                                    X_wi = sqrt(Xs^2+Ys^2);
                                                                    Y_wi = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{3}.Text) - Z_wa;
                                                                else
                                                                    X_wi = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{1}.Text);
                                                                    Y_wi = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{2}.Text);
                                                                end
                                                            else
                                                                X_wi = 0.0;
                                                                Y_wi = 0.0;
                                                            end
                                                        end
                                                        width_glass_wi = width_wi - 2*0.11; %width_wi - 2*0.12; %EV: to be modified
                                                        height_glass_wi = height_wi - 2*0.11; %height_wi - 2*0.12; %EV: to be modified
                                                        amb_factor_wi = amb_factor_wa;

                                                        if nargin == 5
                                                            check = 0;
                                                            for ii = 1:size(raw_windoors_excel,1)
                                                                try %%%% Mara 21 07 2025
                                                                if strcmp(raw_windoors_excel{ii,53},name_wi)
                                                                    check = 1;
                                                                    model_cons_wi = raw_windoors_excel{ii,10};
                                                                    view_factor_wi = raw_windoors_excel{ii,12};
                                                                    shadingtop_wi(1) = raw_windoors_excel{ii,14};
                                                                    shadingtop_wi(2) = raw_windoors_excel{ii,15};
                                                                    shadingleft_wi(1) = raw_windoors_excel{ii,16};
                                                                    shadingleft_wi(2) = raw_windoors_excel{ii,17};
                                                                    shadingright_wi(1) = raw_windoors_excel{ii,18};
                                                                    shadingright_wi(2) = raw_windoors_excel{ii,19};
                                                                    shadinghorizont_wi(1) = raw_windoors_excel{ii,20};
                                                                    shadinghorizont_wi(2) = raw_windoors_excel{ii,21};
                                                                    fd_wi = raw_windoors_excel{ii,22};
                                                                    % to get the values of fs and obtain always 12 values (1 per month)
                                                                    time_months = [0 31 59 90 120 151 181 212 243 273 304 334]*24*3600;
                                                                    seq_factor_ = [];
                                                                    if raw_windoors_excel{ii,40} == 0
                                                                        seq_factor_ = ones(1,12) * raw_windoors_excel{ii,41};
                                                                    elseif raw_windoors_excel{ii,40} == 1
                                                                        fs_w = raw_windoors_excel{ii,41};
                                                                        fs_s = raw_windoors_excel{ii,42};
                                                                        seq_factor_ = [fs_w fs_w fs_w fs_w fs_s fs_s fs_s fs_s fs_s fs_w fs_w fs_w];
                                                                    elseif raw_windoors_excel{ii,40} == 2
                                                                        seq_factor_ = [raw_windoors_excel{ii,41} raw_windoors_excel{ii,42} raw_windoors_excel{ii,43} raw_windoors_excel{ii,44} raw_windoors_excel{ii,45} raw_windoors_excel{ii,46} raw_windoors_excel{ii,47} raw_windoors_excel{ii,48} raw_windoors_excel{ii,49} raw_windoors_excel{ii,50} raw_windoors_excel{ii,51} raw_windoors_excel{ii,52}];
                                                                    else
                                                                        seq_factor_ = ones(1,12);
                                                                    end
                                                                    fstime_wi = [time_months 365*24*3600];
                                                                    fsvalue_wi = [seq_factor_ seq_factor_(1)];
%                                                                     for ll = -1:building.maxruntime
%                                                                         if ll == building.maxruntime
%                                                                             fstime_wi = [fstime_wi time_months+ll*365*24*3600 365*24*3600*(building.maxruntime+1)];
%                                                                             fsvalue_wi = [fsvalue_wi seq_factor_ seq_factor_(1)];
%                                                                         else
%                                                                             fstime_wi = [fstime_wi time_months+ll*365*24*3600];
%                                                                             fsvalue_wi = [fsvalue_wi seq_factor_];
%                                                                         end
%                                                                     end
                                                                    psi_i_wi(1,1) = raw_windoors_excel{ii,23};
                                                                    psi_i_wi(1,2) = raw_windoors_excel{ii,24};
                                                                    psi_i_wi(2,1) = raw_windoors_excel{ii,25};
                                                                    psi_i_wi(2,2) = raw_windoors_excel{ii,26};
                                                                    control_s_wi = raw_windoors_excel{ii,27};
                                                                    model_heattrans_wi = raw_windoors_excel{ii,28};
                                                                    model_inf_wi = raw_windoors_excel{ii,29};
                                                                    C_wi(1) = raw_windoors_excel{ii,30};
                                                                    C_wi(2) = raw_windoors_excel{ii,31};
                                                                    C_wi(3) = raw_windoors_excel{ii,32};
                                                                    n_wi(1) = raw_windoors_excel{ii,33};
                                                                    n_wi(2) = raw_windoors_excel{ii,34};
                                                                    n_wi(3) = raw_windoors_excel{ii,35};
                                                                    V_wi(1) = raw_windoors_excel{ii,36};
                                                                    V_wi(2) = raw_windoors_excel{ii,37};
                                                                    V_wi(3) = raw_windoors_excel{ii,38};
                                                                    control_i_wi = raw_windoors_excel{ii,39};
                                                                    fs_w = raw_windoors_excel{ii,41};
                                                                    fs_s = raw_windoors_excel{ii,42};
                                                                    vector_window = {'window', name_wa, or, X_wi, Y_wi, width_wi, height_wi, width_glass_wi, height_glass_wi, model_cons_wi, construction_wi, view_factor_wi, amb_factor_wi, shadingtop_wi(1), shadingtop_wi(2), shadingleft_wi(1), shadingleft_wi(2), shadingright_wi(1), shadingright_wi(2), shadinghorizont_wi(1), shadinghorizont_wi(2), fd_wi, psi_i_wi(1,1), psi_i_wi(1,2), psi_i_wi(2,1), psi_i_wi(2,2), control_s_wi, model_heattrans_wi, model_inf_wi, C_wi(1), C_wi(2), C_wi(3), n_wi(1), n_wi(2), n_wi(3), V_wi(1), V_wi(2), V_wi(3), control_i_wi, 1, fs_w, fs_s, '', '', '', '', '', '', '', '', '', '', name_wi};
                                                                    xlRange = ['A' num2str(ii+3) ':BA' num2str(ii+3)];
                                                                    xlswrite1(name_xls,vector_window,'WinDoors',xlRange)
                                                                    break
                                                                end
                                                                end
                                                            end
                                                        end
                                                        if check == 0 || nargin == 3
                                                            if strcmp(excel_create, 'structure')
%                                                                 warning(['Window ' name_wi ' does not exist in excel file'])
                                                            end
                                                            model_cons_wi = 0;
                                                            width_glass_wi = width_wi - 2*0.11; %width_wi - 2*0.12; %EV: to be modified
                                                            height_glass_wi = height_wi - 2*0.11; %height_wi - 2*0.12; %EV: to be modified
                                                            view_factor_wi = 1.0;
                                                            amb_factor_wi = amb_factor_wa;
                                                            shadingtop_wi(1) = 0.0;
                                                            shadingtop_wi(2) = 0.0;
                                                            shadingleft_wi(1) = 0.0;
                                                            shadingleft_wi(2) = 0.0;
                                                            shadingright_wi(1) = 0.0;
                                                            shadingright_wi(2) = 0.0;
                                                            shadinghorizont_wi(1) = 0.0;
                                                            shadinghorizont_wi(2) = 0.0;
                                                            time_months = [0 31 59 90 120 151 181 212 243 273 304 334]*24*3600;
                                                            seq_factor_ = ones(1,12); % the fs is consider 1 always becaase in sketch up it cannot be defined
                                                            time_factor = [];
                                                            seq_factor = [];
                                                            fstime_wi = [time_months 365*24*3600];
                                                            fsvalue_wi = [seq_factor_ seq_factor_(1)];
%                                                             for ll = -1:building.maxruntime
%                                                                 if ll == building.maxruntime
%                                                                     fstime_wi = [time_factor time_months+ll*365*24*3600 365*24*3600*(building.maxruntime+1)];
%                                                                     fsvalue_wi = [seq_factor seq_factor_ seq_factor_(1)];
%                                                                 else
%                                                                     fstime_wi = [time_factor time_months+ll*365*24*3600];
%                                                                     fsvalue_wi = [seq_factor seq_factor_];
%                                                                 end
%                                                             end
                                                            fd_wi = 0.95;
                                                            psi_i_wi(1,1) = 0.0;
                                                            psi_i_wi(1,2) = 0.0;
                                                            psi_i_wi(2,1) = 0.0;
                                                            psi_i_wi(2,2) = 0.0;
                                                            control_s_wi = 1;
                                                            model_inf_wi = 0;
                                                            C_wi(1) = 0.0;
                                                            C_wi(2) = 0.0;
                                                            C_wi(3) = 0.0;
                                                            n_wi(1) = 0.0;
                                                            n_wi(2) = 0.0;
                                                            n_wi(3) = 0.0;
                                                            V_wi(1) = 0.0;
                                                            V_wi(2) = 0.0;
                                                            V_wi(3) = 0.0;
                                                            control_i_wi = 1;
                                                            vector_window = {'window', name_wa, or, X_wi, Y_wi, width_wi, height_wi, width_glass_wi, height_glass_wi, 0, construction_wi, 1.0, amb_factor_wi, 0, 0, 0, 0, 0, 0, 0, 0, 0.9, 0.04, 0.04, 0.04, 0.04, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, name_wi};
                                                            xlRange = ['A' num2str(3+size(raw_windoors_excel,1)+1+raw_windoors) ':BA' num2str(3+size(raw_windoors_excel,1)+1+raw_windoors)];
                                                            raw_windoors = raw_windoors+1;
                                                            xlswrite1(name_xls,vector_window,'WinDoors',xlRange)
                                                        end
                                                        windows_wa = [windows_wa WINDOW(name_wi, model_cons_wi, X_wi, Y_wi, width_wi, height_wi, width_glass_wi, height_glass_wi, view_factor_wi, amb_factor_wi, shadingtop_wi, shadingleft_wi, shadingright_wi, shadinghorizont_wi, fstime_wi, fsvalue_wi, fd_wi, psi_i_wi, control_s_wi, construction_wi, model_inf_wi, C_wi, n_wi, V_wi, control_i_wi)];

                                                    case {'NonSlidingDoor','Door'}
                                                        if length(name_XML.Campus.Surface{jjk}.Opening) > 1
                                                            name_do = ['door_' name_wa ];
                                                            try
                                                                if strcmp(ProgramInfo,'openstudio')
                                                                    construction_do = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                elseif strcmp(ProgramInfo,'revit')
                                                                    construction_do = name_XML.Campus.Surface{jjk}.Opening{jjjk}.CADObjectId.Text;
                                                                else
                                                                    construction_do = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                end
                                                            catch
                                                                warning(['No construction definied for opening ' name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.id])
                                                                construction_do = '';
                                                            end
                                                            width_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.Width.Text);
                                                            height_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.Height.Text);
                                                            if (strcmp(ProgramInfo,'openstudio') || strcmp(ProgramInfo,'revit'))
                                                                Xs = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{1}.Text) - X_wa;
                                                                Ys = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{2}.Text) - Y_wa;
                                                                X_do = sqrt(Xs^2+Ys^2);
                                                                Y_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{3}.Text) - Z_wa;
                                                            else
                                                                X_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{1}.Text);
                                                                Y_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{2}.Text);
                                                            end
                                                            amb_factor_do = amb_factor_wa;
                                                        else
                                                            name_do = ['door_' name_wa ];
                                                            try
                                                                if strcmp(ProgramInfo,'openstudio')
                                                                    construction_do = name_XML.Campus.Surface{jjk}.Opening.Attributes.constructionIdRef; %EV, before: construction_do = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                elseif strcmp(ProgramInfo,'revit')
                                                                    construction_do = name_XML.Campus.Surface{jjk}.Opening{jjjk}.CADObjectId.Text;
                                                                else
                                                                    construction_do = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                                end
                                                            catch
                                                                warning(['No construction definied for opening ' name_XML.Campus.Surface{jjk}.Opening.Attributes.id])
                                                                construction_do = '';
                                                            end
                                                            width_do = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.Width.Text);
                                                            height_do = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.Height.Text);
                                                            if (strcmp(ProgramInfo,'openstudio') || strcmp(ProgramInfo,'revit'))
                                                                Xs = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{1}.Text) - X_wa;
                                                                Ys = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{2}.Text) - Y_wa;
                                                                X_do = sqrt(Xs^2+Ys^2);
                                                                Y_do = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{3}.Text) - Z_wa;
                                                            else
                                                                X_do = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{1}.Text);
                                                                Y_do = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.CartesianPoint.Coordinate{2}.Text);
                                                            end
                                                        amb_factor_do = amb_factor_wa;
                                                        end
                                                        if nargin == 5
                                                            check = 0;
                                                            for ii = 1:size(raw_windoors_excel,1)
                                                                if strcmp(raw_windoors_excel{ii,53},name_do)
                                                                    check = 1;
                                                                    model_heattrans_do = raw_windoors_excel{ii,28};
                                                                    model_cons_do = raw_windoors_excel{ii,10};
                                                                    view_factor_do = raw_windoors_excel{ii,12};
                                                                    amb_factor_do = raw_windoors_excel{ii,13};
                                                                    C_do(1) = raw_windoors_excel{ii,30};
                                                                    C_do(2) = raw_windoors_excel{ii,31};
                                                                    C_do(3) = raw_windoors_excel{ii,32};
                                                                    n_do(1) = raw_windoors_excel{ii,33};
                                                                    n_do(2) = raw_windoors_excel{ii,34};
                                                                    n_do(3) = raw_windoors_excel{ii,35};
                                                                    V_do(1) = raw_windoors_excel{ii,36};
                                                                    V_do(2) = raw_windoors_excel{ii,37};
                                                                    V_do(3) = raw_windoors_excel{ii,38};
                                                                    control_i_do = raw_windoors_excel{ii,39};
                                                                    model_inf_do = raw_windoors_excel{ii,29};
                                                                    vector_door = {'door', name_wa, or, X_do, Y_do, width_do, height_do, 0, 0, model_cons_do, construction_do, view_factor_do, amb_factor_do,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, model_heattrans_do, model_inf_do, C_do(1), C_do(2), C_do(3), n_do(1), n_do(2), n_do(3), V_do(1), V_do(2), V_do(3), control_i_do, 1, 0, 0, '', '', '', '', '', '', '', '', '', '',  name_do};
                                                                    xlRange = ['A' num2str(ii+3) ':BA' num2str(ii+3)];
                                                                    xlswrite1(name_xls, vector_door, 'WinDoors', xlRange)
                                                                    break
                                                                end
                                                            end
                                                        end
                                                        if check == 0 || nargin == 3
                                                            if strcmp(excel_create, 'structure')
%                                                                 warning(['door ' name_do ' does not exist in excel file'])
                                                            end
                                                            model_heattrans_do = 1;
                                                            model_cons_do = 0;
                                                            view_factor_do = 1.0;
                                                            amb_factor_do = 1.0;
                                                            C_do(1) = 0.0;
                                                            C_do(2) = 0.0;
                                                            C_do(3) = 0.0;
                                                            n_do(1) = 0.0;
                                                            n_do(2) = 0.0;
                                                            n_do(3) = 0.0;
                                                            V_do(1) = 0.0;
                                                            V_do(2) = 0.0;
                                                            V_do(3) = 0.0;
                                                            control_i_do = 2;
                                                            model_inf_do = 0;
                                                            vector_door = {'door', name_wa, or, X_do, Y_do, width_do, height_do, '', '', model_cons_do, construction_do, view_factor_do, amb_factor_do, '', '', '', '', '', '', '', '', '', '', '', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, '', '', '', '', '', '', '', '', '', '', '', '', '', name_do};
                                                            xlRange = ['A' num2str(size(raw_windoors_excel,1)+1+3+raw_windoors) ':BA' num2str(size(raw_windoors_excel,1)+1+3+raw_windoors)];
                                                            raw_windoors = raw_windoors+1;
                                                            xlswrite1(name_xls, vector_door, 'WinDoors', xlRange)
                                                        end
                                                        doors_wa = [doors_wa DOOR(name_do, X_do, Y_do, width_do, height_do, construction_do, model_heattrans_do, model_cons_do, view_factor_do, amb_factor_do, C_do, n_do, V_do, control_i_do, model_inf_do)];
                                                    otherwise
                                                        warning(['opening type: ' openingType])
                                                        if length(name_XML.Campus.Surface{jjk}.Opening) > 1
    %                                                         name_do = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.id;
                                                            name_do = ['door_' name_wa ];
                                                            try
                                                                construction_do = name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.constructionIdRef;
                                                            catch
                                                                warning(['No construction definied for opening ' name_XML.Campus.Surface{jjk}.Opening{jjjk}.Attributes.id])
                                                                construction_do = '';
                                                            end
                                                            width_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.Width.Text);
                                                            height_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.Height.Text);
                                                        else
    %                                                         name_do = name_XML.Campus.Surface{jjk}.Opening.Attributes.id;
                                                            name_do = ['door_' name_wa ];
                                                            try
                                                                construction_do = name_XML.Campus.Surface{jjk}.Opening.Attributes.constructionIdRef;
                                                            catch
                                                                warning(['No construction definied for opening ' name_XML.Campus.Surface{jjk}.Opening.Attributes.id])
                                                                construction_do = '';
                                                            end
                                                            width_do = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.Width.Text);
                                                            height_do = str2double(name_XML.Campus.Surface{jjk}.Opening.RectangularGeometry.Height.Text);
                                                        end
                                                        if (strcmp(ProgramInfo,'openstudio') || strcmp(ProgramInfo,'revit'))
                                                            Xs = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{1}.Text) - X_wa;
                                                            Ys = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{2}.Text) - Y_wa;
                                                            X_do = sqrt(Xs^2+Ys^2);
                                                            Y_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{3}.Text) - Z_wa;
                                                        else
                                                            X_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{1}.Text);
                                                            Y_do = str2double(name_XML.Campus.Surface{jjk}.Opening{jjjk}.RectangularGeometry.CartesianPoint.Coordinate{2}.Text);
                                                        end
                                                        if nargin == 5
                                                            check = 0;
                                                            for ii = 1:size(raw_windoors_excel,1)
                                                                if strcmp(raw_windoors_excel{ii,53},name_do)
                                                                    model_heattrans_do = raw_windoors_excel{ii,28};
                                                                    model_cons_do = raw_windoors_excel{ii,10};
                                                                    view_factor_do = raw_windoors_excel{ii,12};
                                                                    amb_factor_do = raw_windoors_excel{ii,13};
                                                                    C_do(1) = raw_windoors_excel{ii,30};
                                                                    C_do(2) = raw_windoors_excel{ii,31};
                                                                    C_do(3) = raw_windoors_excel{ii,32};
                                                                    n_do(1) = raw_windoors_excel{ii,33};
                                                                    n_do(2) = raw_windoors_excel{ii,34};
                                                                    n_do(3) = raw_windoors_excel{ii,35};
                                                                    V_do(1) = raw_windoors_excel{ii,36};
                                                                    V_do(2) = raw_windoors_excel{ii,37};
                                                                    V_do(3) = raw_windoors_excel{ii,38};
                                                                    control_i_do = raw_windoors_excel{ii,39};
                                                                    model_inf_do = raw_windoors_excel{ii,29};
                                                                    vector_door = {'door', name_wa, or, X_do, Y_do, width_do, height_do, '', '', '', construction_do, '', amb_factor_do, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', name_do};
                                                                    xlRange = ['A' num2str(ii+3) ':BA' num2str(ii+3)];
                                                                    xlswrite1(name_xls, vector_door, 'WinDoors', xlRange)
                                                                    break
                                                                end
                                                            end
                                                        end
                                                        if check == 0 || nargin == 3
                                                            if strcmp(excel_create, 'structure')
%                                                                 warning(['door ' name_do ' does not exist in excel file'])
                                                            end
                                                            model_heattrans_do = 1;
                                                            model_cons_do = 0;
                                                            view_factor_do = 1.0;
                                                            amb_factor_do = 1.0;
                                                            C_do(1) = 0.0;
                                                            C_do(2) = 0.0;
                                                            C_do(3) = 0.0;
                                                            n_do(1) = 0.0;
                                                            n_do(2) = 0.0;
                                                            n_do(3) = 0.0;
                                                            V_do(1) = 0.0;
                                                            V_do(2) = 0.0;
                                                            V_do(3) = 0.0;
                                                            control_i_do = 2;
                                                            model_inf_do = 0;
                                                            vector_door = {'door', name_wa, or, X_do, Y_do, width_do, height_do, '', '', '', construction_do, '', amb_factor_do, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', name_do};
                                                            xlRange = ['A' num2str(size(raw_windoors_excel,1)+1+3+raw_windoors) ':BA' num2str(size(raw_windoors_excel,1)+1+3+raw_windoors)];
                                                            raw_windoors = raw_windoors+1;
                                                            xlswrite1(name_xls, vector_door, 'WinDoors', xlRange)
                                                        end
                                                        doors_wa = [doors_wa DOOR(name_do, X_do, Y_do, width_do, height_do, construction_do, model_heattrans_do, model_cons_do, view_factor_do, amb_factor_do, C_do, n_do, V_do, control_i_do, model_inf_do)];
                                                end
                                            end
                                        end
                                       walls_list = [walls_list WALL(name_wa, boundary_wa, X_wa_full, Y_wa_full, Z_wa_full, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, orientation_rotation_wa, inside_wa, construction_wa, model_cons_wa, model_heattrans_wa, view_factor_wa, amb_factor_wa, model_inf_wa, C_wa, n_wa, V_wa, control_i_wa, windows_wa, doors_wa)];
                                    end
                                end
                            end
                        end
                        obj = obj.add_room(name_room_text, area_room, heated_volume/area_room, walls_list, n50_room);
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
        end
        
        function obj = geometry_from_PHPP(obj, name_xls_PHPP, language, version, model_cons_wall, building)
            % to take the geometry from the PHPP
            % 1 ... name of the file xls of the PHPP
            % 2 ... language: 1:german, 0:english
            % 3 ... version of PHPP used
            % 4 ... model of the construction of the wall 'UA' or 'RC'
            
            filename = name_xls_PHPP;
            
            vollpfad = [pwd '\' name_xls_PHPP];

            if exist(vollpfad, 'file')
                warning('Existing Excel file used.')
            else
                error('Excel file not existing!')
            end
            
            try
                Excel = actxserver('Excel.Application');
                Excel.Workbooks.Open(vollpfad);
                warning('Excel file opened! Do not interrupt this script!')
                
                switch version
                    case '9.1'
                        if language
                            sheet = 'Flächen';
                        else
                            sheet = 'Areas';
                        end
                        
                        % walls
                        range = 'K40:AL1000'; %EV, before: 'K40:AL240';
                        [~, ~, data] = xlsread1(filename, sheet, range);
                        if language
                            sheet = 'Flächen';
                            idx_fl=find(strcmp(data(:,1),{'Wärmebrückeneingabe'}))-3;
                        else
                            sheet = 'Areas';
                            idx_fl=find(strcmp(data(:,1),{'Thermal bridge input'}))-3;
                            if isempty(idx_fl)
                                idx_fl=find(strcmp(data(:,1),{'Thermal bridge inputs'}))-3;
                            end
                        end
                        %reshape the data matrix to avoid to include the
                        %thermal bridges part
                        data=data(1:idx_fl,:);
                        
                        index_namenumb_wa = 1;
                        index_name_wa = 2;
                        index_group_bound = 3;
                        index_number_wa = 6;
                        index_width_wa = 8;
                        index_height_wa = 10;
                        index_addition_wa = 12;
                        index_additionm_wa = 14;
                        index_azimuth_wa = 23;
                        index_sum_wa = 18;
                        index_slope_wa = 24;
                        index_construction_wa = 19;
                        indicator_walls = ones(size(data,1),1);
                        for ii = 1:size(data,1)
%                             ii
                            if data{ii,index_number_wa}==0 || isempty(data{ii,index_number_wa}) || sum(isnan(data{ii,index_number_wa})) 
                                indicator_walls(ii,1)=0;
                            end
                        end

                        % thermal bridges
                        range = 'K8:N27';
                        [~, ~, data3] = xlsread1(filename, sheet, range);
                        index_temp_bo = 1;
                        index_group_bo = 2;
                        index_groupnumb_bo = 3;
                        index_raw_tb = 16:18;
                        index_column_tbarea = 4;
                        index_column_tbname = 2;
                        index_column_tbbo = 1;

                        heated_area = xlsread1(filename, sheet, 'AB34');

                        % ventilation
                        if language
                            sheet = 'Lüftung';
                        else
                            sheet = 'Ventilation';
                        end
                        range = 'N9:P27';
                        [~, ~, data5] = xlsread1(filename, sheet, range);
                        index_raw_volume_1 = 1;
                        index_volume_1 = 1;
                        index_raw_n50 = 19;
                        index_raw_wind_e = 17;
                        index_n50 = 1;
                        index_volume_2 = 3;
                        index_raw_volume_2 = index_raw_n50;


                        % windows
                        if language
                            sheet = 'Fenster';
                        else
                            sheet = 'Windows';
                        end
                        range = 'L24:BQ385'; %EV, before: 'L24:BQ580';
                        [~, ~, data1] = xlsread1(filename, sheet, range);
                        index_wall_wi = 8;
                        index_name_wi = 2;
                        index_number_wi = 1; 
                        index_width_wi = 6;
                        index_height_wi = 7;
                        index_framelinks_wi = 29;
                        index_frameright_wi = 30;
                        index_framebottom_wi = 31; 
                        index_frametop_wi = 32;
                        index_psitop_wi = 55;
                        index_psibottom_wi = 54;
                        index_psileft_wi = 52;
                        index_psiright_wi = 53;
                        index_constr1_wi = 9; % constr Glass
                        index_constr2_wi = 10; % constr Frame
                        indicator_windows = ones(size(data1,1),1);
                        for ii = 1:size(data1,1)
                            if data1{ii,index_number_wi}==0 || isempty(data1{ii,index_number_wi}) || sum(isnan(data1{ii,index_number_wi})) 
                                % strcmp(data1(ii,index_name_wi),'-') || sum(isnan(data1{ii,index_name_wi})) || isempty(data1{ii,index_name_wi})
                                indicator_windows(ii,1) = 0;
                            end
                        end

                        % shading
                        if language
                            sheet = 'Verschattung';
                        else
                            sheet = 'Shading';
                        end
                        range = 'S17:AR570';
                        [~, ~, data2] = xlsread1(filename, sheet, range);
                        index_name_sh = 1;
                        index_shtop1_sh = 12;
                        index_shtop2_sh = 13;
                        index_shside1_sh = 10;
                        index_shside2_sh = 11;
                        index_shhor1_sh = 9;
                        index_shhor2_sh = 8;
                        index_fswint_sh = 21;
                        index_fssum_sh = 25;
                        indicator_shading = ones(size(data1,1),1);                    
                        for ii = 1:size(data2,1)
                            if strcmp(data2(ii,index_name_sh),'-') || sum(isnan(data2{ii,index_name_sh})) || isempty(data2{ii,index_name_sh})
                                indicator_shading(ii) = 0;
                                break
                            end
                        end
                        
                   case '10.2'
                        if language
                            sheet = 'Flächen';
                        else
                            sheet = 'Areas';
                        end
                        
                        % walls
                        range = 'K40:AJ1000'; %EV, before: 'K40:AL240';
                        [~, ~, data] = xlsread1(filename, sheet, range);
                        if language
                            sheet = 'Flächen';
                            idx_fl=find(strcmp(data(:,1),{'Wärmebrückeneingabe'}))-3;
                        else
                            sheet = 'Areas';
                            idx_fl=find(strcmp(data(:,1),{'Thermal bridge input'}))-3;
                        end
                        %reshape the data matrix to avoid to include the
                        %thermal bridges part
                        data=data(1:idx_fl,:);
                        for jj = 1 : length({data{:,2}})
                            if isnan(data{jj,2})
                                idx=jj-1;
                                break
                            end
                        end
                        data=data(1:idx,:);

                        index_namenumb_wa = 1;
                        index_name_wa = 2;
                        index_group_bound = 3;
                        index_number_wa = 4;
                        index_width_wa = 6;
                        index_height_wa = 8;
                        index_addition_wa = 10;
                        index_additionm_wa = 12;
                        index_azimuth_wa = 21;
                        index_sum_wa = 16;
                        index_slope_wa = 22;
                        index_construction_wa = 17;
                        indicator_walls = ones(size(data,1),1);
                        for ii = 1:size(data,1)
%                             ii
                            if data{ii,index_number_wa}==0 || isempty(data{ii,index_number_wa}) || sum(isnan(data{ii,index_number_wa})) 
                                indicator_walls(ii,1)=0;
                            end
                        end
                        
                        for hh= 1:length({data{:,index_group_bound}})
                            GRUPPE=char(data{hh,index_group_bound});
                            GRUPPE=str2num(GRUPPE(1:find(GRUPPE=='-')-1));        
                            data(hh,index_group_bound)=  num2cell(GRUPPE);
                            clear GRUPPE
                        end

                        % thermal bridges
                        range = 'K8:N27';
                        [~, ~, data3] = xlsread1(filename, sheet, range);
                        index_temp_bo = 1;
                        index_group_bo = 3;
                        index_groupnumb_bo =4;
                        index_raw_tb = 16:18;
                        index_column_tbarea = 2;
                        index_column_tbname = 3;
                        index_column_tbbo = 1;

                        heated_area = xlsread1(filename, sheet, 'Z34');

                        % ventilation
                        if language
                            sheet = 'Lüftung';
                        else
                            sheet = 'Ventilation';
                        end
                        range = 'M8:N27';
                        [~, ~, data5] = xlsread1(filename, sheet, range);
                        index_raw_volume_1 = 1;
                        index_volume_1 = 1;
                        index_raw_n50 = 16;
                        index_raw_wind_e = 12;
                        index_n50 = 1;
                        index_volume_2 = 1;
                        index_raw_volume_2 = 15;

                        % windows
                        if language
                            sheet = 'Fenster';
                        else
                            sheet = 'Windows';
                        end
                        range = 'L23:ET1000'; %EV, before: 'L24:BQ580';
                        [~, ~, data1] = xlsread1(filename, sheet, range);
                        index_wall_wi = 9;
                        index_name_wi = 3;
                        index_number_wi = 1; 
                        index_width_wi = 7;
                        index_height_wi = 8;
                        index_framelinks_wi = 44; %Rahmenmaße aus Blatt 'Komponenten' -> Breite links (not sure what this is in 10.2, breite rahmen öffenbar?)
                        index_frameright_wi = 45;
                        index_framebottom_wi = 47; 
                        index_frametop_wi = 46;
                        index_psitop_wi = 125;
                        index_psibottom_wi = 126;
                        index_psileft_wi = 123;
                        index_psiright_wi = 124;
                        index_constr1_wi = 10; % constr Glass
                        index_constr2_wi = 11; % constr Frame
                        
                        %clean the data eliminating the rows where we have
                        %no windows (only at the end of the list not in the
                        %middle)
                        idx_win=min(find(cell2mat(cellfun(@isnan, data1(:,1)', 'UniformOutput', false))))-1;
                        
                        %reshape the data matrix to avoid to include empty
                        %windows
                        data1=data1(1:idx_win,:);
                        indicator_windows = ones(size(data1,1),1);
                        
                        for ii = 1:size(data1,1)
                            if data1{ii,index_number_wi}==0 || isempty(data1{ii,index_number_wi}) || sum(isnan(data1{ii,index_number_wi})) 
                                % strcmp(data1(ii,index_name_wi),'-') || sum(isnan(data1{ii,index_name_wi})) || isempty(data1{ii,index_name_wi})
                                indicator_windows(ii,1) = 0;
                            end
                        end
                        
                        
                        % ispos=find(not(sum(isspace(char(data1{:,2}))')));
                        % nopos=find(sum(isspace(char(data1{:,2}))'));
                        ispos=find(not(isnan([data1{:,2}])'));
                        nopos=find(isnan([data1{:,2}])');
                        
                        if not(isempty(ispos))
                           data1(ispos,3)=cellstr([char(string(data1(ispos,2)))  char(ones(length(data1(ispos,2)),1) * ' ') char(data1{ispos,3})]);
                        end
                        if not(isempty(nopos))
                           data1(nopos,3)=cellstr([char(ones(length(data1(nopos,2)),1) * ' ') char(data1{nopos,3})]);
                        end
                        
                        % shading
                        if language
                            sheet = 'Verschattung';
                        else
                            sheet = 'Shading';
                        end
                        range = 'U23:AT174';
                        [~, ~, data2] = xlsread1(filename, sheet, range);
                        index_name_sh = 1;
                        index_shtop1_sh = 12;
                        index_shtop2_sh = 13;
                        index_shside1_sh = 10;
                        index_shside2_sh = 11;
                        index_shhor1_sh = 9;
                        index_shhor2_sh = 8;
                        index_fswint_sh = 21;
                        index_fssum_sh = 25;
                        indicator_shading = ones(size(data1,1),1);                    
                        for ii = 1:size(data2,1)
                            if strcmp(data2(ii,index_name_sh),'-') || sum(isnan(data2{ii,index_name_sh})) || isempty(data2{ii,index_name_sh})
                                indicator_shading(ii) = 0;
                                break
                            end
                        end

                end

                walls_list = [];
                for ii = 2:size(data,1) 
                    if indicator_walls(ii,1) == 1
                        name_wa = ['W' num2str(data{ii,index_namenumb_wa}) '-' data{ii,index_name_wa}];
                        X_wa = 0;
                        Y_wa = 0;
                        Z_wa = 0;
                        check_NaN = [];
                        check_NaN = (cellfun(@(V) any(isnan(V)),data));
                        if check_NaN(ii,index_width_wa)
                            width_wa = 0;
                        else
                            width_wa = data{ii,index_width_wa}*data{ii,index_number_wa}; %width_wa = data{ii,index_width_wa}; 
                        end
                        if check_NaN(ii,index_height_wa)
                            height_wa = 0;
                        else
                            height_wa = data{ii,index_height_wa};
                        end
                        if ~check_NaN(ii,index_addition_wa)
                            if width_wa == 0
                                width_wa = 1;
                            end
                            height_wa = height_wa + data{ii,index_addition_wa}/width_wa;
                        end
                        if ~check_NaN(ii,index_additionm_wa)
                            if width_wa == 0
                                width_wa = 1;
                            end
                            height_wa = height_wa - data{ii,index_additionm_wa}/width_wa;
                        end
                        orientation_azimuth_wa = (data{ii,index_azimuth_wa}-180); %EV, before: orientation_azimuth_wa = (data{ii,index_azimuth_wa}-180)*(-1);
                        orientation_slope_wa = data{ii,index_slope_wa}; 
                        orientation_rotation_wa = 0;
                        for iik = 1:size(data3,1)
                            if data3{iik,index_groupnumb_bo} == data{ii,index_group_bound}
                                ind_b = iik;
                                break
                            end
                        end
                        if strcmp(data3{ind_b,index_temp_bo}, 'A') || strcmp(data3{ind_b,index_temp_bo}, 'C') 
                            boundary_wa = 'AMBIENT';
                        elseif strcmp(data3{ind_b,index_temp_bo}, 'B')
                            boundary_wa = 'GROUND';
                        elseif strcmp(data3{ind_b,index_temp_bo}, 'I')
                            boundary_wa = 'NEIGHBOUR_1';
                        elseif data3{ind_b,index_groupnumb_bo} == 12
                            boundary_wa = 'NEIGHBOUR_2'; 
                        elseif data3{ind_b,index_groupnumb_bo} == 13
                            boundary_wa = 'NEIGHBOUR_3'; 
                        elseif data3{ind_b,index_groupnumb_bo} == 14
                            boundary_wa = 'NEIGHBOUR_4'; 
                        end
                        construction_wa = data{ii,index_construction_wa}; 
                        if strcmp(model_cons_wall,'UA')
                            model_cons_wa = 0;
                        elseif strcmp(model_cons_wall,'RC')
                            model_cons_wa = 1;
                        end
                        model_heattrans_wa = 2;
                        view_factor_wa = 1;
                        if orientation_slope_wa >= 75
                            amb_factor_wa = 0.5;
                        else
                            amb_factor_wa = 0;
                        end
                        inside_wa = 1;
                        model_inf_wa = 0;
                        C_wa(1) = 0;
                        C_wa(2) = 0;
                        C_wa(3) = 0;
                        n_wa(1) = 0;
                        n_wa(2) = 0;
                        n_wa(3) = 0;
                        V_wa(1) = 0;
                        V_wa(2) = 0;
                        V_wa(3) = 0;
                        control_i_wa = 1;
                        windows_wa = [];

                        for ll = 1:size(data1,1)
                            if indicator_windows(ll) == 1
                                for jj_window = 1:data1{ll,index_number_wi}
                                    name_wall_wi = ['W' data1{ll,index_wall_wi}];
                                    if strcmp(name_wall_wi,name_wa)
                                        if jj_window == data1{ll,index_number_wi}
                                            indicator_windows(ll) = 0;
                                        end
                                        for iij = 1:size(data2,1)
                                            if strcmp(data2{iij,index_name_sh}, data1{ll,index_name_wi})
                                                ind_s = iij;
                                                break
                                            end
                                        end
                                        name_wi = [data1{ll,index_name_wi} '_' num2str(jj_window)]; 
                                        model_cons_wi = 0; % always TF
                                        X_wi = 0;
                                        Y_wi = 0;
                                        width_wi = data1{ll,index_width_wi}; 
                                        height_wi = data1{ll,index_height_wi}; 
                                        width_glass_wi = width_wi-(data1{ll,index_frameright_wi}+data1{ll,index_framelinks_wi}); 
                                        height_glass_wi = height_wi-(data1{ll,index_framebottom_wi}+data1{ll,index_frametop_wi}); 
                                        view_factor_wi = 1;
                                        amb_factor_wi = amb_factor_wa;
                                        shadingtop_wi(1) = data2{ind_s,index_shtop1_sh}; % verschattung sheet
                                        shadingtop_wi(2) = data2{ind_s,index_shtop2_sh}; 
                                        shadingleft_wi(1) = data2{ind_s,index_shside1_sh}; 
                                        shadingleft_wi(2) = data2{ind_s,index_shside2_sh}; 
                                        shadingright_wi(1) = data2{ind_s,index_shside1_sh}; 
                                        shadingright_wi(2) = data2{ind_s,index_shside2_sh}; 
                                        shadinghorizont_wi(1) = data2{ind_s,index_shhor1_sh}; 
                                        shadinghorizont_wi(2) = data2{ind_s,index_shhor2_sh}; 
                                        fs_w = data2{ind_s,index_fswint_sh};
                                        fs_s = data2{ind_s,index_fssum_sh};
                                        time_months = [0 31 59 90 120 151 181 212 243 273 304 334]*24*3600;
                                        seq_factor_ = [fs_w fs_w fs_w fs_w fs_s fs_s fs_s fs_s fs_s fs_w fs_w fs_w];
                                        time_factor = [];
                                        seq_factor = [];
    %                                     for lll = -1:building.maxruntime
    %                                         if lll == building.maxruntime
    %                                             fstime_wi = [time_factor time_months+lll*365*24*3600 365*24*3600*(building.maxruntime+1)];
    %                                             fsvalue_wi = [seq_factor seq_factor_ seq_factor_(1)];
    %                                         else
    %                                             fstime_wi = [time_factor time_months+lll*365*24*3600];
    %                                             fsvalue_wi = [seq_factor seq_factor_];
    %                                         end
    %                                     end
                                        fstime_wi = [time_months 365*24*3600];
                                        fsvalue_wi = [seq_factor_ seq_factor_(1)];
                                        fd_wi = 0.95;
                                        psi_i_wi(1,1) = data1{ll,index_psitop_wi}; % top  
                                        psi_i_wi(1,2) = data1{ll,index_psibottom_wi}; % bottom  
                                        psi_i_wi(2,1) = data1{ll,index_psileft_wi}; % left  
                                        psi_i_wi(2,2) = data1{ll,index_psiright_wi}; % right  
                                        control_s_wi = 1;
                                        construction_wi = [data1{ll,index_constr1_wi}(1:end) '_' data1{ll,index_constr2_wi}(1:end)];
                                        model_inf_wi = 0; % always constant
                                        C_wi(1) = 0;
                                        C_wi(2) = 0;
                                        C_wi(3) = 0;
                                        n_wi(1) = 0;
                                        n_wi(2) = 0;
                                        n_wi(3) = 0;
                                        V_wi(1) = 0;
                                        V_wi(2) = 0;
                                        V_wi(3) = 0;
                                        control_i_wi = 1; % window opening (1: no window opening)
                                        windows_wa = [windows_wa WINDOW(name_wi, model_cons_wi, X_wi, Y_wi, width_wi, height_wi, width_glass_wi, height_glass_wi, view_factor_wi, amb_factor_wi, shadingtop_wi, shadingleft_wi, shadingright_wi, shadinghorizont_wi, fstime_wi, fsvalue_wi, fd_wi, psi_i_wi, control_s_wi, construction_wi, model_inf_wi, C_wi, n_wi, V_wi, control_i_wi)];
                                    end
                                end
                            end
                        end
                        if height_wa == 0

                        else
                            walls_list = [walls_list WALL(name_wa, boundary_wa, X_wa, Y_wa, Z_wa, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, orientation_rotation_wa, inside_wa, construction_wa, model_cons_wa, model_heattrans_wa, view_factor_wa, amb_factor_wa, model_inf_wa, C_wa, n_wa, V_wa, control_i_wa, windows_wa, [])];
                        end
                    end
                end
                if sum(indicator_windows) == 0
                else
                    warning('One or more windows do not belong to existing walls, please check the PHPP!')
                end

                % door % updated 25/05/2018
                if indicator_walls(1,1) == 1
                    name_wa = data{1,index_name_wa};
                    X_wa = 0;
                    Y_wa = 0;
                    Z_wa = 0;
                    width_wa = data{1,index_number_wa}*data{1,index_sum_wa};
                    height_wa = 1;
                    orientation_azimuth_wa = 0;
                    orientation_slope_wa = 90; 
                    orientation_rotation_wa = 0;
                    boundary_wa = 'AMBIENT';
                    model_cons_wa = 0;
                    model_heattrans_wa = 2;
                    view_factor_wa = 1;
                    amb_factor_wa = 0.5;
                    inside_wa = 1;
                    model_inf_wa = 0;
                    C_wa(1) = 0;
                    C_wa(2) = 0;
                    C_wa(3) = 0;
                    n_wa(1) = 0;
                    n_wa(2) = 0;
                    n_wa(3) = 0;
                    V_wa(1) = 0;
                    V_wa(2) = 0;
                    V_wa(3) = 0;
                    construction_wa = data{1,index_construction_wa}; 
                    control_i_wa = 1;
                    windows_wa = [];
                    walls_list = [walls_list WALL(name_wa, boundary_wa, X_wa, Y_wa, Z_wa, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, orientation_rotation_wa, inside_wa, construction_wa, model_cons_wa, model_heattrans_wa, view_factor_wa, amb_factor_wa, model_inf_wa, C_wa, n_wa, V_wa, control_i_wa, windows_wa, [])];
                end

                if data3{index_raw_tb(1),index_column_tbarea} == 0
                else
                    name_wa = [data3{index_raw_tb(1),index_column_tbname}]; 
                    X_wa = 0;
                    Y_wa = 0;
                    Z_wa = 0;
                    width_wa = data3{index_raw_tb(1),index_column_tbarea};
                    height_wa = 1;
                    orientation_azimuth_wa = 0;
                    orientation_slope_wa = 90; 
                    orientation_rotation_wa = 0;
                    boundary_wa = 'AMBIENT';
                    construction_wa = 'Ambient_thermal_bridge'; 
                    model_cons_wa = 0;
                    model_heattrans_wa = 2;
                    view_factor_wa = 1;
                    amb_factor_wa = 0.5;
                    inside_wa = 1;
                    model_inf_wa = 0;
                    C_wa(1) = 0;
                    C_wa(2) = 0;
                    C_wa(3) = 0;
                    n_wa(1) = 0;
                    n_wa(2) = 0;
                    n_wa(3) = 0;
                    V_wa(1) = 0;
                    V_wa(2) = 0;
                    V_wa(3) = 0;
                    control_i_wa = 1;
                    windows_wa = [];
                    walls_list = [walls_list WALL(name_wa, boundary_wa, X_wa, Y_wa, Z_wa, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, orientation_rotation_wa, inside_wa, construction_wa, model_cons_wa, model_heattrans_wa, view_factor_wa, amb_factor_wa, model_inf_wa, C_wa, n_wa, V_wa, control_i_wa, windows_wa, [])];
                end

                if data3{index_raw_tb(2),index_column_tbarea} == 0 
                else
                    name_wa = [data3{index_raw_tb(2),index_column_tbname}];
                    X_wa = 0;
                    Y_wa = 0;
                    Z_wa = 0;
                    width_wa = data3{index_raw_tb(2),index_column_tbarea};
                    height_wa = 1;
                    orientation_azimuth_wa = 0;
                    orientation_slope_wa = 90; 
                    orientation_rotation_wa = 0;
                    boundary_wa = 'AMBIENT';
                    construction_wa = 'Perimeter_thermal_bridge'; 
                    model_cons_wa = 0;
                    model_heattrans_wa = 2;
                    view_factor_wa = 1;
                    amb_factor_wa = 0.5;
                    inside_wa = 1;
                    model_inf_wa = 0;
                    C_wa(1) = 0;
                    C_wa(2) = 0;
                    C_wa(3) = 0;
                    n_wa(1) = 0;
                    n_wa(2) = 0;
                    n_wa(3) = 0;
                    V_wa(1) = 0;
                    V_wa(2) = 0;
                    V_wa(3) = 0;
                    control_i_wa = 1;
                    windows_wa = [];
                    walls_list = [walls_list WALL(name_wa, boundary_wa, X_wa, Y_wa, Z_wa, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, orientation_rotation_wa, inside_wa, construction_wa, model_cons_wa, model_heattrans_wa, view_factor_wa, amb_factor_wa, model_inf_wa, C_wa, n_wa, V_wa, control_i_wa, windows_wa, [])];
                end

                if data3{index_raw_tb(3),index_column_tbarea} == 0
                else
                    name_wa = [data3{index_raw_tb(3),index_column_tbname}];
                    X_wa = 0;
                    Y_wa = 0;
                    Z_wa = 0;
                    width_wa = data3{index_raw_tb(3),index_column_tbarea};
                    height_wa = 1;
                    orientation_azimuth_wa = 0;
                    orientation_slope_wa = 180; 
                    orientation_rotation_wa = 0;
                    boundary_wa = 'GROUND';
                    construction_wa = 'Ground_thermal_bridge'; 
                    model_cons_wa = 0;
                    model_heattrans_wa = 2;
                    view_factor_wa = 1;
                    amb_factor_wa = 0.5;
                    inside_wa = 1;
                    model_inf_wa = 0;
                    C_wa(1) = 0;
                    C_wa(2) = 0;
                    C_wa(3) = 0;
                    n_wa(1) = 0;
                    n_wa(2) = 0;
                    n_wa(3) = 0;
                    V_wa(1) = 0;
                    V_wa(2) = 0;
                    V_wa(3) = 0;
                    control_i_wa = 1;
                    windows_wa = [];
                    walls_list = [walls_list WALL(name_wa, boundary_wa, X_wa, Y_wa, Z_wa, width_wa, height_wa, orientation_slope_wa, orientation_azimuth_wa, orientation_rotation_wa, inside_wa, construction_wa, model_cons_wa, model_heattrans_wa, view_factor_wa, amb_factor_wa, model_inf_wa, C_wa, n_wa, V_wa, control_i_wa, windows_wa, [])];
                end
                
                n50_room = data5{index_raw_n50,index_n50};
                wind_e_room = data5{index_raw_wind_e,index_n50};
                area_room = heated_area;
                volume = data5{index_raw_volume_1,index_volume_1};
                heated_volume = data5{index_raw_volume_2,index_volume_2};
                if heated_volume == volume
                else
                    warning('In PHPP heated volume different from the n50 volume')
                end
                
                obj = obj.add_room('whole_building', area_room, heated_volume/area_room, walls_list, n50_room, wind_e_room);
                
                Excel.Quit
                Excel.delete
                clear Excel
                warning('Excel file closed!')
            catch ME
                ME
                Excel.Quit
                Excel.delete
                clear Excel
                warning('Excel file closed!')
            end
        end
        
        function room = get_room(obj, name)
            % The output is the room "name" with all his properties
            % 1 ... name of the room
            ind = [];
            for jj = 1:length(obj.room)
                if strcmp(obj.room(jj).name,name)
                    ind = jj;
                    break
                end
            end
            
            % check if room is not existing
            if ind
                room = obj.room(ind);
            else
                error(['room ' name{:} ' not existing!'])
                name
                % error(['room not existing!' eval(name)])
            end
        end
        
        function obj = set_room(obj, name, room)
            % to set the room "room" under the name "name"
            % 1 ... name that you want to give to the room
            % 2 ... object ROOM with the room caracteristics
            ind = [];
            for jj = 1:length(obj.room)
                if strcmp(obj.room(jj).name,name)
                    ind = jj;
                    break
                end
            end
            % check if room is not existing
            if ind
                obj.room(ind)
                obj.room(ind) = room;
            else
%                 error(['room ' name ' not existing!'])
                error(['room not existing!'])
            end
        end
        
        function obj = copy_room(obj,name,name_new)
            % to do a copy named "name_new" of the room "name"
            % 1 ... name of the room that you want to copy
            % 2 ... name of the copy
            ind = [];
            for jj = 1:length(obj.room)
                % take the indice of room
                if strcmp(obj.room(jj).name,name)
                    ind = jj;
                    break
                end
            end
            % check if room to copy is existing
            if ind
                ind1 = [];
                for jj = 1:length(obj.room)
                    % substitute name of room
                    if strcmp(obj.room(jj).name,name_new)
                        ind1 = strcmp(obj.room(jj).name,name_new);
                        break
                    end
                end
                % check if new room is already existing
                if ind1
                    error(['room ' name_new ' already existing! Can not be copied with this name.'])
                else
                    temp_room = obj.room(ind);
                    temp_room.name = name_new;
                    obj.room = [obj.room temp_room];
                end
            else
                error(['room ' name ' not existing!'])
            end
        end
        
        function print_room(obj, name)
            room = obj.get_room(name);
            for ii = 1: size(room.wall,2)
                plot(room.wall(1,ii), rand(1,3))
                axis equal
                view(3)
                rotate3d on
                axis tight
            end
        end
        
        function obj = print_geometry(obj)
            for jj = 1:length(obj.room)
                for ii = 1: size(obj.room(jj).wall,2)
                    hold all
                    plot(obj.room(jj).wall(1,ii), [0.7 0.5 0.71])
                end
            end
            axis equal
            view(3)
            rotate3d on
            axis tight
        end
        
    end
end


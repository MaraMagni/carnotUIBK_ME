
%% THERMALZONE.m
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
% DS,EL	    2019-01-24   updates for GUI v2.0

%%
classdef THERMALZONE
    % THERMALZONE
    
    properties
        name = 'new thermalzone';
        zone = [];
        intersection = [];
    end
    
    methods
        % a THEMALZONE object is always emtpy
        function obj = THERMALZONE(NUMBEROFZONES)
            if nargin == 0
                NUMBEROFZONES = 10;
            else
            end
            for ii = 1:NUMBEROFZONES
                obj = obj.add_zone(ii, ['EMPTY_' num2str(ii)], {}, 0);
            end
            for ii = 1:NUMBEROFZONES
                tt(ii) = ii;
                for jj = 1:NUMBEROFZONES
                    if ii ~= jj && all(jj ~= tt)
                        if ii < 10
                            if jj <10
                                num = ii*10+jj;
                            else
                                num = ii*100+jj;
                            end
                        else
                            num = ii*100+jj; 
                        end
                        obj = obj.add_intersection(num,['EMPTY_' num2str(ii) '_' num2str(jj)], [ii,jj]);
                    end
                end
            end
        end
        
        % add a zone
        function obj = add_zone(obj, number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant, profile_tc, profile_tr, profile_time, profile_rH, profile_CO2, profile_VOC, profile_p)
            % to add a zone to thermal zone
            % 1 ... number of the zone
            % 2 ... name of the zone
            % 3 ... model: %0 ... none/temperature, 1 ... ideal, 2 ... 1-node, 3 ... 2-node, 4 ... 2-node wo mass
            % 4 ... optional, 0: orientation of the external walls is not
            % important and the walls are merged, 1 if the orientation is
            % important
            % 5 ... optional, initial temperature of the zone
            % 6 ... optional, initial relative humidity of the zone
            % 7 ... optional, initial CO2 level of the zone
            % 6 ... optional, initial VOC level of the zone
            % 7 ... optional specific capacity of the zone
            % 8 ... time constant
            % 9 ... profile of the convective temperature; if the model == 0
            % 10 ... profile of the radiative temperature; if the model == 0
            % 11 ... profile of the time associated to the profile_tc and profile_tr; if the model == 0
            
            if (nargin == 5)
                ind = [];
                for jj = 1:length(obj.zone)
                    if obj.zone(jj).number == number
                        ind = jj;
                        break
                    end
                end
                if ind
                    obj.zone(ind) = ZONE(number, name, rooms, model);
                else
                    obj.zone = [obj.zone ZONE(number, name, rooms, model)];
                end
            elseif (nargin == 6)
                ind = [];
                for jj = 1:length(obj.zone)
                    if obj.zone(jj).number == number
                        ind = jj;
                        break
                    end
                end
                if ind
                    obj.zone(ind) = ZONE(number, name, rooms, model, orientation_important);
                else
                    obj.zone = [obj.zone ZONE(number, name, rooms, model, orientation_important)];
                end
            elseif (nargin == 9)
                profile_tc = t_ini;
                profile_tr = phi_ini;
                profile_time = CO2_ini;
                ind = [];
                for jj = 1:length(obj.zone)
                    if obj.zone(jj).number == number
                        ind = jj;
                        break
                    end
                end
                if ind
                    obj.zone(ind) = ZONE(number, name, rooms, model, orientation_important, profile_tc, profile_tr, profile_time);
                else
                    obj.zone = [obj.zone ZONE(number, name, rooms, model, orientation_important, profile_tc, profile_tr, profile_time)];
                end
            elseif (nargin == 11)
                ind = [];
                for jj = 1:length(obj.zone)
                    if obj.zone(jj).number == number
                        ind = jj;
                        break
                    end
                end
                if ind
                    obj.zone(ind) = ZONE(number, name, rooms, model, 1, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant);
                else
                    obj.zone = [obj.zone ZONE(number, name, rooms, model, 1, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant)];
                end
            elseif (nargin == 12)
                ind = [];
                for jj = 1:length(obj.zone)
                    if obj.zone(jj).number == number
                        ind = jj;
                        break
                    end
                end
                if ind
                    obj.zone(ind) = ZONE(number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant);
                else
                    obj.zone = [obj.zone ZONE(number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant)];
                end
            elseif (nargin == 15)
                ind = [];
                for jj = 1:length(obj.zone)
                    if obj.zone(jj).number == number
                        ind = jj;
                        break
                    end
                end
                if ind
                    obj.zone(ind) = ZONE(number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant, profile_tc, profile_tr, profile_time);
                else
                    obj.zone = [obj.zone ZONE(number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant, profile_tc, profile_tr, profile_time)];
                end
            elseif (nargin == 19)
                ind = [];
                for jj = 1:length(obj.zone)
                    if obj.zone(jj).number == number
                        ind = jj;
                        break
                    end
                end
                if ind
                    obj.zone(ind) = ZONE(number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant, profile_tc, profile_tr, profile_time, profile_rH, profile_CO2, profile_VOC, profile_p);
                else
                    obj.zone = [obj.zone ZONE(number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant, profile_tc, profile_tr, profile_time, profile_rH, profile_CO2, profile_VOC, profile_p)];
                end
            end
        end
        
        function zone = get_zone(obj, name)
            % to get a zone by a name
            % 1 ... name of the zone
            ind = [];
            for jj = 1:length(obj.zone)
                if strcmp(obj.zone(jj).name,name)
                    ind = jj;
                    break
                end
            end
            % check if zone is not existing
            if ind
                zone = obj.zone(ind);
            else
                error(['zone ' name ' not existing!'])
            end
        end
        
        function obj = zone_fromexcel(obj, name_xls)
            % to add the zone according to the excel sheet "Zones"
            % name of the excel
            [~, ~, raw_zones] = xlsread(name_xls, 'Zones');
            raw_zones(1:2,:) = [];      
            for ii = 1:size(raw_zones,1)
                rooms = {};
                number = raw_zones{ii,1};
                name = raw_zones{ii,2};
                rooms = raw_zones(ii,3:(52+20));
                rooms(cellfun(@(rooms) any(isnan(rooms)),rooms)) = [];
                rooms = cellstr(rooms);
                model = raw_zones{ii,53+20};
                orientation_important = raw_zones{ii,54+20};
                ver1 = isnan((raw_zones{ii,61+20}));
                ver2 = isnan((raw_zones{ii,62+20}));
                ver3 = isnan((raw_zones{ii,63+20}));
                if isnan(raw_zones{ii,1}(1))==0 && isnan(raw_zones{ii,2}(1))==0 && isnan(raw_zones{ii,53+20}(1))==0 && isnan(raw_zones{ii,3}(1))==0 && isnan(raw_zones{ii,54+20}(1))==0
                    if isnan(raw_zones{ii,55+20}(1))==0 && isnan(raw_zones{ii,56+20}(1))==0 && isnan(raw_zones{ii,57+20}(1))==0 && isnan(raw_zones{ii,58+20}(1))==0 && isnan(raw_zones{ii,59+20}(1))==0 && isnan(raw_zones{ii,60+20}(1))==0
                        t_ini = raw_zones{ii,55+20};
                        phi_ini = raw_zones{ii,56+20};
                        CO2_ini = raw_zones{ii,57+20};
                        VOC_ini = raw_zones{ii,58+20};
                        cp_spec = raw_zones{ii,59+20};
                        timeconstant = raw_zones{ii,60+20};
                        if ver1(1) == 0 && ver2(1) == 0 && ver3(1) == 0
                            profile_tc = str2num(raw_zones{ii,61+20});
                            profile_tr = str2num(raw_zones{ii,62+20});
                            profile_time = str2num(raw_zones{ii,63+20});
                            profile_rH = ones(1,length(profile_tr))*50;
                            profile_CO2 = ones(1,length(profile_tr))*400;
                            profile_VOC = ones(1,length(profile_tr))*0;
                            profile_p = ones(1,length(profile_tr))*1e5;
                            obj = obj.add_zone(number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant, profile_tc, profile_tr, profile_time, profile_rH, profile_CO2, profile_VOC, profile_p);
                        else
                            obj = obj.add_zone(number, name, rooms, model, orientation_important, t_ini, phi_ini, CO2_ini, VOC_ini, cp_spec, timeconstant);
                        end
                    elseif isnan(raw_zones{ii,55+20}(1))==1 && isnan(raw_zones{ii,56+20}(1))==1 && isnan(raw_zones{ii,57+20}(1))==1 && isnan(raw_zones{ii,58+20}(1))==1 && isnan(raw_zones{ii,59+20}(1))==1 && isnan(raw_zones{ii,60+20}(1))==1
                        if ver1(1) == 0 && ver2(1) == 0 && ver3(1) == 0
                            profile_tc = str2num(raw_zones{ii,61+20});
                            profile_tr = str2num(raw_zones{ii,62+20});
                            profile_time = str2num(raw_zones{ii,63+20});
                            profile_rH = ones(1,length(profile_tr))*50;
                            profile_CO2 = ones(1,length(profile_tr))*400;
                            profile_VOC = ones(1,length(profile_tr))*0;
                            profile_p = ones(1,length(profile_tr))*1e5;
                            if (model == 0 || model ==1) && isnan(raw_zones{ii,61+20}(1))==1 && isnan(raw_zones{ii,62+20}(1))==1 && isnan(raw_zones{ii,62+20}(1))==1
                                error('No profile of temperature specified in the excel for model 0 or 1')
                            else
                                obj = obj.add_zone(number, name, rooms, model, orientation_important, profile_tc, profile_tr, profile_time, profile_rH, profile_CO2, profile_VOC, profile_p);
                            end
                        else
                            obj = obj.add_zone(number, name, rooms, model, orientation_important);
                        end
                    end
                end 
            end
        end
        
        function obj = zone_to_excel(obj, name_xls, building,variant_thermalzone)
            
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
            xlswrite1(name_xls,{''},'Zones','A3:CE12')
            
            count_thzone = 0;
            
            for ii=1:size(building.thermalzone(variant_thermalzone).zone,2)
                if isnan(building.thermalzone(variant_thermalzone).zone(ii).heated_volume)
                else
                    count_thzone = count_thzone+1;
                    thzone_pfad = building.thermalzone(variant_thermalzone).zone(ii);
                    rooms = cell(1,70);
                    for jj = 1:size(thzone_pfad.rooms,2)
                        rooms(1,jj) = thzone_pfad.rooms(1,jj);
                    end
                	matrix_to_write_zone(ii,:) = [{count_thzone} {thzone_pfad.name} rooms {thzone_pfad.model} {thzone_pfad.orientation_important} {thzone_pfad.t_ini} {thzone_pfad.phi_ini} {thzone_pfad.CO2_ini} {thzone_pfad.VOC_ini} {thzone_pfad.cp_spec} {thzone_pfad.timeconstant} {['[' num2str(thzone_pfad.profile_Tc) ']']} {['[' num2str(thzone_pfad.profile_Tr) ']']} {['[' num2str(thzone_pfad.profile_timevalues/(24*3600)) ']*24*3600']}];  
               
                end
                
            end
            xlswrite1(name_xls,matrix_to_write_zone,'Zones',['A3:CE' num2str(count_thzone+2)]) 
            
            Excel.ActiveWorkbook.Save
            Excel.Quit
            Excel.delete
            clear Excel
            warning('Excel file closed!')
        end
        
        function obj = zone_from_XML(obj, name_XML)
            building_xml = xml2struct(name_XML);
            name_XML = building_xml.gbXML;
            
            model = 3;
            orientation_important = 1;
            
            if isfield(name_XML,'Zone')
                for jk=1:length(name_XML.Zone)
                    if length(name_XML.Zone) > 1
                        thz_compare = name_XML.Zone{jk}.Attributes.id;
                    else
                        thz_compare = name_XML.Zone.Attributes.id;
                    end
                    rooms = {};
                    number = jk;
                    name = thz_compare;
                    for jjk=1:length(name_XML.Campus.Building.Space)
                        if strcmp(thz_compare,name_XML.Campus.Building.Space{jjk}.Attributes.zoneIdRef)
                            rooms{length(rooms)+1} = name_XML.Campus.Building.Space{jjk}.Attributes.id;
                        end
                    end

                    rooms = cellstr(rooms);
                    obj = obj.add_zone(number, name, rooms, model, orientation_important);
                end
            else
                warning('No thermal zones defined in gbXML!')
            end
        end
        
        function obj = update_zone(obj, number, geometry, building, variant_gains)
            % to update the zone:
            % A. It takes the zone, generates the matrix for walls, doors and
            % windows; B. It puts the internal walls in internal and with a
            % half of the area C. It merges the walls with the same
            % characteristics and sums the areas
            % 1 ... number of the zone
            % 2 ... object geometry
            % 3 ... object building
            
            ind = [];
            % to individuate the zone
            for jj = 1:length(obj.zone)
                if obj.zone(jj).number == number
                    ind = jj;
                    break
                end
            end
            % check if zone is not existing
            if ind
                room_tt = [];
                room_zz = [];
                volume_tt = [];
                volume_zz = [];
                room_ = [];
                for tt = 1:length(obj.zone(ind).rooms)
                    % uuu(tt) = tt;
                    % for zz = 1:length(obj.zone(ind).rooms)
                    %     if  tt ~= zz && all(zz ~= uuu)
                    %         room_tt = geometry.get_room(obj.zone(ind).rooms(tt));
                    %         room_zz = geometry.get_room(obj.zone(ind).rooms(zz));
                    %         volume_tt = room_tt.area*room_tt.height;
                    %         volume_zz = room_zz.area*room_zz.height;
                    %         obj.zone(ind).n50 = (room_tt.n50*volume_tt+room_zz.n50*volume_zz)/(volume_tt+volume_zz);
                    %     elseif length(obj.zone(ind).rooms)==1
                    %         room_ = geometry.get_room(obj.zone(ind).rooms(1));
                    %         obj.zone(ind).n50 = room_.n50;
                    %     end
                    % end
                   volume(tt) = geometry.get_room(obj.zone(ind).rooms(tt)).height * geometry.get_room(obj.zone(ind).rooms(tt)).area;
                   n50(tt) =   geometry.get_room(obj.zone(ind).rooms(tt)).n50;

                end
                if exist('volume')
					obj.zone(ind).n50 = sum(volume.*n50)/sum(volume);
                else
					obj.zone(ind).n50 = 0;
                end
                
                mm_gains = 1;
                % assign the gains to the zone
                for ll = 1 : size(building.gains(variant_gains).gain_to_zone,2)
                    my_gain = [];
                    if building.gains(variant_gains).gain_to_zone(1,ll).number_of_zone == ind
                        my_gain = building.gains(variant_gains).get_gain(building.gains(variant_gains).gain_to_zone(1,ll).name_gains);
                        obj.zone(ind).matrix_gains{mm_gains,1} = my_gain.name;
                        obj.zone(ind).matrix_gains{mm_gains,2} = my_gain.model;
                        obj.zone(ind).matrix_gains{mm_gains,3} = my_gain.type;
                        obj.zone(ind).matrix_gains{mm_gains,4} = my_gain.timevalues;
                        obj.zone(ind).matrix_gains{mm_gains,5} = my_gain.timeduration;
                        obj.zone(ind).matrix_gains{mm_gains,6} = my_gain.values1;
                        obj.zone(ind).matrix_gains{mm_gains,7} = my_gain.values2;
                        obj.zone(ind).matrix_gains{mm_gains,9} = my_gain.control;
                        mm_gains = mm_gains + 1;
                    end
                end
                ind_sum = 1;
                ind_sum_wi = 1;
                for kk = 1:length(obj.zone(ind).rooms)
                	room(kk) = geometry.get_room(obj.zone(ind).rooms(kk));
                    % fill in the matrix with the value for each wall
                    for ll = 1:length(room(kk).wall)
                        area = calc_area(room(kk).wall(ll));
                        if area < 0
                            warning(['Error: windows plus doors are bigger than the area of the wall ' room(kk).name ' (' num2str(kk) ')!'])
                            area = 0;
                        end
                        obj.zone(ind).matrix_wd{ind_sum,1} = room(kk).wall(ll).construction;
                        obj.zone(ind).matrix_wd{ind_sum,2} = area;
                        obj.zone(ind).matrix_wd{ind_sum,3} = room(kk).wall(ll).boundary;
                        obj.zone(ind).matrix_wd{ind_sum,4} = room(kk).wall(ll).orientation_slope;
                        obj.zone(ind).matrix_wd{ind_sum,5} = room(kk).wall(ll).orientation_azimuth;    %EV 18.01.2021: azimuth = azimuth (not anymore *(-1). Correction already made in geometry. % (BUG) DS 31.10.16: azimuth multiplied with (-1)
                        obj.zone(ind).matrix_wd{ind_sum,6} = room(kk).wall(ll).orientation_rotation;
                        obj.zone(ind).matrix_wd{ind_sum,7} = room(kk).wall(ll).model_cons;
                        obj.zone(ind).matrix_wd{ind_sum,8} = room(kk).wall(ll).model_heattrans;
                        obj.zone(ind).matrix_wd{ind_sum,9} = room(kk).wall(ll).view_factor;
                        obj.zone(ind).matrix_wd{ind_sum,10} = room(kk).wall(ll).amb_factor;
                        obj.zone(ind).matrix_wd{ind_sum,11} = 0; % solar_ratio
                        obj.zone(ind).matrix_wd{ind_sum,12} = 1; % number of boundary (neighbour, ground)
                        obj.zone(ind).matrix_wd{ind_sum,13} = room(kk).wall(ll).model_inf; % model_infiltration
                        obj.zone(ind).matrix_wd{ind_sum,14} = room(kk).wall(ll).height; % height
                        obj.zone(ind).matrix_wd{ind_sum,15} = room(kk).wall(ll).C; % C matrix
                        obj.zone(ind).matrix_wd{ind_sum,16} = room(kk).wall(ll).n; % n matrix
                        obj.zone(ind).matrix_wd{ind_sum,17} = room(kk).wall(ll).V; % V matrix
                        obj.zone(ind).matrix_wd{ind_sum,18} = room(kk).wall(ll).control_i; % control_i
                        obj.zone(ind).matrix_wd{ind_sum,19} = room(kk).name;
                        ind_sum = ind_sum+1;
                        % fill in the matrix with the value for each door
                        for mm = 1:length(room(kk).wall(ll).doors)
                            area = calc_area(room(kk).wall(ll).doors(mm));
                            obj.zone(ind).matrix_wd{ind_sum,1} = room(kk).wall(ll).doors(mm).construction;
                            obj.zone(ind).matrix_wd{ind_sum,2} = area;
                            obj.zone(ind).matrix_wd{ind_sum,3} = room(kk).wall(ll).boundary;
                            obj.zone(ind).matrix_wd{ind_sum,4} = room(kk).wall(ll).orientation_slope;
                            obj.zone(ind).matrix_wd{ind_sum,5} = room(kk).wall(ll).orientation_azimuth;    %EV 18.01.2021: azimuth = azimuth (not anymore *(-1). Correction already made in geometry. % (BUG) DS 31.10.16
                            obj.zone(ind).matrix_wd{ind_sum,6} = room(kk).wall(ll).orientation_rotation;
                            obj.zone(ind).matrix_wd{ind_sum,7} = room(kk).wall(ll).doors(mm).model_cons;
                            obj.zone(ind).matrix_wd{ind_sum,8} = room(kk).wall(ll).doors(mm).model_heattrans;
                            obj.zone(ind).matrix_wd{ind_sum,9} = room(kk).wall(ll).doors(mm).view_factor;
                            obj.zone(ind).matrix_wd{ind_sum,10} = room(kk).wall(ll).doors(mm).amb_factor;
                            obj.zone(ind).matrix_wd{ind_sum,11} = 0; % solar_ratio
                            obj.zone(ind).matrix_wd{ind_sum,12} = 1; % number of boundary (neighbour, ground)
                            obj.zone(ind).matrix_wd{ind_sum,13} = room(kk).wall(ll).doors(mm).model_inf; % model_infiltration
                            obj.zone(ind).matrix_wd{ind_sum,14} = room(kk).wall(ll).doors(mm).height; % height
                            obj.zone(ind).matrix_wd{ind_sum,15} = room(kk).wall(ll).doors(mm).C; % C matrix
                            obj.zone(ind).matrix_wd{ind_sum,16} = room(kk).wall(ll).doors(mm).n; % n matrix
                            obj.zone(ind).matrix_wd{ind_sum,17} = room(kk).wall(ll).doors(mm).V; % V matrix
                            obj.zone(ind).matrix_wd{ind_sum,18} = room(kk).wall(ll).doors(mm).control_i; % control_i
                            obj.zone(ind).matrix_wd{ind_sum,19} = room(kk).name;
                            ind_sum = ind_sum+1;
                        end
                        % fill in the matrix with the value for each window
                        for nn = 1:length(room(kk).wall(ll).windows)
                            area = calc_area(room(kk).wall(ll).windows(nn));
                            perimeter = room(kk).wall(ll).windows(nn).width*2+room(kk).wall(ll).windows(nn).height*2;
                            perimeter_glass = room(kk).wall(ll).windows(nn).width_glass*2+room(kk).wall(ll).windows(nn).height_glass*2;
                            frame = 1 - room(kk).wall(ll).windows(nn).width_glass*room(kk).wall(ll).windows(nn).height_glass/area;
                            obj.zone(ind).matrix_wi{ind_sum_wi,1} = room(kk).wall(ll).windows(nn).construction;
                            obj.zone(ind).matrix_wi{ind_sum_wi,2} = room(kk).wall(ll).windows(nn).width;
                            obj.zone(ind).matrix_wi{ind_sum_wi,3} = room(kk).wall(ll).windows(nn).height;
                            obj.zone(ind).matrix_wi{ind_sum_wi,4} = room(kk).wall(ll).boundary;
                            obj.zone(ind).matrix_wi{ind_sum_wi,5} = room(kk).wall(ll).orientation_slope;
                            obj.zone(ind).matrix_wi{ind_sum_wi,6} = room(kk).wall(ll).orientation_azimuth;     %EV 18.01.2021: azimuth = azimuth (not anymore *(-1) ). Correction already made in geometry. Before: obj.zone(ind).matrix_wi{ind_sum_wi,6} = room(kk).wall(ll).orientation_azimuth*(-1) % (BUG) DS 31.10.16
                            obj.zone(ind).matrix_wi{ind_sum_wi,7} = room(kk).wall(ll).orientation_rotation;
                            obj.zone(ind).matrix_wi{ind_sum_wi,8} = room(kk).wall(ll).windows(nn).model_cons; 
                            obj.zone(ind).matrix_wi{ind_sum_wi,9} = frame; % part of frame
                            obj.zone(ind).matrix_wi{ind_sum_wi,10} = (1-frame)*area; % glass area
                            obj.zone(ind).matrix_wi{ind_sum_wi,11} = room(kk).wall(ll).windows(nn).view_factor;
                            obj.zone(ind).matrix_wi{ind_sum_wi,12} = room(kk).wall(ll).windows(nn).amb_factor;
                            obj.zone(ind).matrix_wi{ind_sum_wi,13} = room(kk).wall(ll).windows(nn).fstime;
                            obj.zone(ind).matrix_wi{ind_sum_wi,14} = room(kk).wall(ll).windows(nn).fsvalue;
                            obj.zone(ind).matrix_wi{ind_sum_wi,15} = room(kk).wall(ll).windows(nn).fd;
                            obj.zone(ind).matrix_wi{ind_sum_wi,16} = (room(kk).wall(ll).windows(nn).psi_i(1,1)+room(kk).wall(ll).windows(nn).psi_i(1,2))*room(kk).wall(ll).windows(nn).width + (room(kk).wall(ll).windows(nn).psi_i(2,1)+room(kk).wall(ll).windows(nn).psi_i(2,2))*room(kk).wall(ll).windows(nn).height;
                            obj.zone(ind).matrix_wi{ind_sum_wi,17} = room(kk).wall(ll).windows(nn).width_glass*2 + room(kk).wall(ll).windows(nn).height_glass*2;
                            obj.zone(ind).matrix_wi{ind_sum_wi,18} = room(kk).wall(ll).windows(nn).control_s;
                            obj.zone(ind).matrix_wi{ind_sum_wi,19} = room(kk).wall(ll).windows(nn).model_inf; % model_infiltration
							if length(room(kk).wall(ll).Z) > 1
                                obj.zone(ind).matrix_wi{ind_sum_wi,20} = room(kk).wall(ll).windows(nn).Y + room(kk).wall(ll).Z(2); % z
                            else
                                obj.zone(ind).matrix_wi{ind_sum_wi,20} = room(kk).wall(ll).windows(nn).Y + room(kk).wall(ll).Z(1); % z
                            end
                            obj.zone(ind).matrix_wi{ind_sum_wi,21} = room(kk).wall(ll).windows(nn).C; % C matrix
                            obj.zone(ind).matrix_wi{ind_sum_wi,22} = room(kk).wall(ll).windows(nn).n; % n matrix
                            obj.zone(ind).matrix_wi{ind_sum_wi,23} = room(kk).wall(ll).windows(nn).V; % V matrix
                            obj.zone(ind).matrix_wi{ind_sum_wi,24} = room(kk).wall(ll).windows(nn).control_i; % control_i
                            obj.zone(ind).matrix_wi{ind_sum_wi,25} = room(kk).wall(ll).windows.width; % width for each window
                            obj.zone(ind).matrix_wi{ind_sum_wi,26} = room(kk).wall(ll).windows.height;% height for each window
                            obj.zone(ind).matrix_wi{ind_sum_wi,27} = room(kk).wall(ll).windows(nn).shadingtop;
                            obj.zone(ind).matrix_wi{ind_sum_wi,28} = room(kk).wall(ll).windows(nn).shadingleft;
                            obj.zone(ind).matrix_wi{ind_sum_wi,29} = room(kk).wall(ll).windows(nn).shadingright;
                            obj.zone(ind).matrix_wi{ind_sum_wi,30} = room(kk).wall(ll).windows(nn).shadinghorizont;
                            obj.zone(ind).matrix_wi{ind_sum_wi,31} = room(kk).name;
                            ind_sum_wi = ind_sum_wi+1;
                        end  
                    end
                end  
                
                % to set the internal walls
                ttt = [];
                for oo = 1:size(obj.zone(ind).matrix_wd,1)
                    ttt(oo) = oo;
                    for pp = 1:size(obj.zone(ind).matrix_wd,1)
                        if oo ~= pp && all(pp ~= ttt)
                            if ((strcmp(obj.zone(ind).matrix_wd{oo,1}, obj.zone(ind).matrix_wd{pp,1})) && ...
                                (obj.zone(ind).matrix_wd{oo,2} == obj.zone(ind).matrix_wd{pp,2}) && ...
                                (obj.zone(ind).matrix_wd{oo,4} == obj.zone(ind).matrix_wd{pp,4}+180 || obj.zone(ind).matrix_wd{oo,4} == obj.zone(ind).matrix_wd{pp,4}-180 || obj.zone(ind).matrix_wd{oo,4} == obj.zone(ind).matrix_wd{pp,4}) && ...
                                (floor(obj.zone(ind).matrix_wd{oo,5}*100)/100 == floor((obj.zone(ind).matrix_wd{pp,5}+180)*100)/100 || floor(obj.zone(ind).matrix_wd{oo,5}*100)/100 == floor((obj.zone(ind).matrix_wd{pp,5}-180)*100)/100 || floor(obj.zone(ind).matrix_wd{oo,5}*100)/100 == floor(obj.zone(ind).matrix_wd{pp,5}*100)/100) && ...
                                (obj.zone(ind).matrix_wd{oo,6} == obj.zone(ind).matrix_wd{pp,6}) && ...
                                (obj.zone(ind).matrix_wd{oo,7} == obj.zone(ind).matrix_wd{pp,7}) && ...
                                (obj.zone(ind).matrix_wd{oo,8} == obj.zone(ind).matrix_wd{pp,8}) && ...
                                (obj.zone(ind).matrix_wd{oo,9} == obj.zone(ind).matrix_wd{pp,9}) && ...
                                (obj.zone(ind).matrix_wd{oo,10} == obj.zone(ind).matrix_wd{pp,10}) && ...
                                (obj.zone(ind).matrix_wd{oo,12} == obj.zone(ind).matrix_wd{pp,12}) && ...
                                (obj.zone(ind).matrix_wd{oo,13} == obj.zone(ind).matrix_wd{pp,13}) && ...
                                (obj.zone(ind).matrix_wd{oo,14} == obj.zone(ind).matrix_wd{pp,14}) && ...
                                isequal(obj.zone(ind).matrix_wd{oo,15}, obj.zone(ind).matrix_wd{pp,15})  && ...
                                isequal(obj.zone(ind).matrix_wd{oo,16}, obj.zone(ind).matrix_wd{pp,16}) && ...
                                isequal(obj.zone(ind).matrix_wd{oo,17}, obj.zone(ind).matrix_wd{pp,17}) && ...
                                (obj.zone(ind).matrix_wd{oo,18} == obj.zone(ind).matrix_wd{pp,18}) )
                                % compare boundary conditions
                                if strcmp(obj.zone(ind).matrix_wd{oo,3},obj.zone(ind).matrix_wd{pp,19}) && strcmp(obj.zone(ind).matrix_wd{oo,19},obj.zone(ind).matrix_wd{pp,3})
                                    obj.zone(ind).matrix_wd{oo,4} = obj.zone(ind).matrix_wd{pp,4};
                                    obj.zone(ind).matrix_wd{oo,5} = obj.zone(ind).matrix_wd{pp,5};
                                    obj.zone(ind).matrix_wd{oo,6} = obj.zone(ind).matrix_wd{pp,6};
                                    obj.zone(ind).matrix_wd{oo,2} = obj.zone(ind).matrix_wd{oo,2}/2;
                                    obj.zone(ind).matrix_wd{pp,2} = obj.zone(ind).matrix_wd{pp,2}/2;
                                    obj.zone(ind).matrix_wd{oo,3} = 'INTERNAL';
                                    obj.zone(ind).matrix_wd{pp,3} = 'INTERNAL';
                                end
                            end
                        end
                    end
                end
                ttt = [];
                uu = 1;
                canc =[];
                % sum the areas of the walls that have the same
                % characteristics
                for oo = 1:size(obj.zone(ind).matrix_wd,1)
                    ttt(oo) = oo;
                    for pp = 1:size(obj.zone(ind).matrix_wd,1)
                        if oo ~= pp && all(pp ~= ttt)
                            % compare obj.zone(ind).matrix
                            if  (strcmp(obj.zone(ind).matrix_wd{oo,1}, obj.zone(ind).matrix_wd{pp,1}) && ...
                                strcmp(obj.zone(ind).matrix_wd{oo,3},obj.zone(ind).matrix_wd{pp,3}) && ...
                                obj.zone(ind).matrix_wd{oo,7} == obj.zone(ind).matrix_wd{pp,7} && ...
                                obj.zone(ind).matrix_wd{oo,8} == obj.zone(ind).matrix_wd{pp,8} && ...
                                obj.zone(ind).matrix_wd{oo,9} == obj.zone(ind).matrix_wd{pp,9} && ...
                                obj.zone(ind).matrix_wd{oo,10} == obj.zone(ind).matrix_wd{pp,10} && ...
                                obj.zone(ind).matrix_wd{oo,12} == obj.zone(ind).matrix_wd{pp,12} && ...
                                obj.zone(ind).matrix_wd{oo,13} == obj.zone(ind).matrix_wd{pp,13} && ...
                                obj.zone(ind).matrix_wd{oo,18} == obj.zone(ind).matrix_wd{pp,18})
                                if strcmp(obj.zone(ind).matrix_wd{oo,3}, 'INTERNAL') && strcmp(obj.zone(ind).matrix_wd{pp,3}, 'INTERNAL')
                                    obj.zone(ind).matrix_wd{oo,14} = (obj.zone(ind).matrix_wd{oo,14}+obj.zone(ind).matrix_wd{pp,14})/2;
                                    obj.zone(ind).matrix_wd{oo,15} = (obj.zone(ind).matrix_wd{oo,15}*obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,15}*obj.zone(ind).matrix_wd{pp,2})/(obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,2});
                                    obj.zone(ind).matrix_wd{oo,16} = (obj.zone(ind).matrix_wd{oo,16}*obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,16}*obj.zone(ind).matrix_wd{pp,2})/(obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,2});
                                    obj.zone(ind).matrix_wd{oo,17} = (obj.zone(ind).matrix_wd{oo,17}+obj.zone(ind).matrix_wd{pp,17});
                                    obj.zone(ind).matrix_wd{oo,2} = obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,2};
                                    canc(uu) = pp;
                                    uu = uu+1;
                                elseif (obj.zone(ind).matrix_wd{oo,4} == obj.zone(ind).matrix_wd{pp,4} && ...
                                        obj.zone(ind).matrix_wd{oo,5} == obj.zone(ind).matrix_wd{pp,5} && ...
                                        obj.zone(ind).matrix_wd{oo,6} == obj.zone(ind).matrix_wd{pp,6})
                                    
                                    obj.zone(ind).matrix_wd{oo,14} = (obj.zone(ind).matrix_wd{oo,14}+obj.zone(ind).matrix_wd{pp,14})/2;
                                    obj.zone(ind).matrix_wd{oo,15} = (obj.zone(ind).matrix_wd{oo,15}*obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,15}*obj.zone(ind).matrix_wd{pp,2})/(obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,2});
                                    obj.zone(ind).matrix_wd{oo,16} = (obj.zone(ind).matrix_wd{oo,16}*obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,16}*obj.zone(ind).matrix_wd{pp,2})/(obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,2});
                                    obj.zone(ind).matrix_wd{oo,17} = (obj.zone(ind).matrix_wd{oo,17}+obj.zone(ind).matrix_wd{pp,17});
                                    obj.zone(ind).matrix_wd{oo,2} = obj.zone(ind).matrix_wd{oo,2}+obj.zone(ind).matrix_wd{pp,2};
                                    canc(uu) = pp;
                                    uu = uu+1;  
                                end
                            end 
                        end
                    end
                     obj.zone(ind).matrix_wd{oo,19} = [];
                end
                count = 0;
                canc = sort(canc);
                canc = unique(canc);
                %delete the empty rows
                for ii = 1:length(canc)
                    obj.zone(ind).matrix_wd(canc(ii)-count,:) = [];
                    count = count+1;
                end
                ttt = [];
                uu = 1;
                canc =[];
                % sum the areas of the windows that have the same
                % characteristics
                for oo = 1:size(obj.zone(ind).matrix_wi,1)
                    ttt(oo) = oo;
                    for pp = 1:size(obj.zone(ind).matrix_wi,1)
                        if oo ~= pp && all(pp ~= ttt)
                        % compare obj.zone(ind).matrix
                            if  ((strcmp(obj.zone(ind).matrix_wi{oo,1}, obj.zone(ind).matrix_wi{pp,1})) && ...
                                (strcmp(obj.zone(ind).matrix_wi{oo,4}, obj.zone(ind).matrix_wi{pp,4})) && ...
                                (obj.zone(ind).matrix_wi{oo,5} == obj.zone(ind).matrix_wi{pp,5}) && ...
                                (obj.zone(ind).matrix_wi{oo,6} == obj.zone(ind).matrix_wi{pp,6}) && ...
                                (obj.zone(ind).matrix_wi{oo,7} == obj.zone(ind).matrix_wi{pp,7}) && ...
                                (obj.zone(ind).matrix_wi{oo,8} == obj.zone(ind).matrix_wi{pp,8}) && ...
                                (obj.zone(ind).matrix_wi{oo,18} == obj.zone(ind).matrix_wi{pp,18}) && ...
                                (obj.zone(ind).matrix_wi{oo,19} == obj.zone(ind).matrix_wi{pp,19}) && ...
                                (obj.zone(ind).matrix_wi{oo,24} == obj.zone(ind).matrix_wi{pp,24}) )
                            
                                area_oo = obj.zone(ind).matrix_wi{oo,2}*obj.zone(ind).matrix_wi{oo,3};
                                area_pp = obj.zone(ind).matrix_wi{pp,2}*obj.zone(ind).matrix_wi{pp,3};
                                area_tot = area_oo+area_pp;
                                area_oo_glass = obj.zone(ind).matrix_wi{oo,10};
                                area_pp_glass = obj.zone(ind).matrix_wi{pp,10};
                                obj.zone(ind).matrix_wi{oo,2} = obj.zone(ind).matrix_wi{oo,2}+obj.zone(ind).matrix_wi{pp,2};
                                obj.zone(ind).matrix_wi{oo,3} = area_tot/ obj.zone(ind).matrix_wi{oo,2}; %(obj.zone(ind).matrix_wi{oo,3}+obj.zone(ind).matrix_wi{pp,3})/2;
                                area = area_oo_glass+area_pp_glass;
                                obj.zone(ind).matrix_wi{oo,10} = obj.zone(ind).matrix_wi{oo,10}+obj.zone(ind).matrix_wi{pp,10};
                                obj.zone(ind).matrix_wi{oo,9} = 1-obj.zone(ind).matrix_wi{oo,10}/area_tot;
                                obj.zone(ind).matrix_wi{oo,11} = (area_oo_glass*obj.zone(ind).matrix_wi{oo,11}+area_pp_glass*obj.zone(ind).matrix_wi{pp,11})/area;
                                obj.zone(ind).matrix_wi{oo,12} = (area_oo_glass*obj.zone(ind).matrix_wi{oo,12}+area_pp_glass*obj.zone(ind).matrix_wi{pp,12})/area;
                                
                                if obj.zone(ind).matrix_wi{oo,2}*obj.zone(ind).matrix_wi{oo,3}-area_tot>0.3
                                    display(['Attention mistake oo=' num2str(oo) ' pp=' num2str(pp) 'AreaWi= ' num2str(obj.zone(ind).matrix_wi{oo,2}*obj.zone(ind).matrix_wi{oo,3}) ' area_tot= ' num2str(area_tot)])
                                end
                                obj.zone(ind).matrix_wi{oo,13} = (area_oo_glass*obj.zone(ind).matrix_wi{oo,13}+area_pp_glass*obj.zone(ind).matrix_wi{pp,13})/area;
                                obj.zone(ind).matrix_wi{oo,14} = (area_oo_glass*obj.zone(ind).matrix_wi{oo,14}+area_pp_glass*obj.zone(ind).matrix_wi{pp,14})/area;
                                obj.zone(ind).matrix_wi{oo,15} = (area_oo_glass*obj.zone(ind).matrix_wi{oo,15}+area_pp_glass*obj.zone(ind).matrix_wi{pp,15})/area;
                                obj.zone(ind).matrix_wi{oo,16} = (obj.zone(ind).matrix_wi{oo,16}+obj.zone(ind).matrix_wi{pp,16});
                                obj.zone(ind).matrix_wi{oo,17} = (obj.zone(ind).matrix_wi{oo,17}+obj.zone(ind).matrix_wi{pp,17});
                                obj.zone(ind).matrix_wi{oo,20} = (obj.zone(ind).matrix_wi{oo,20}+obj.zone(ind).matrix_wi{pp,20})/2;
                                obj.zone(ind).matrix_wi{oo,21} = (obj.zone(ind).matrix_wi{oo,21}*area_oo+obj.zone(ind).matrix_wi{pp,21}*area_pp)/area_tot;
                                obj.zone(ind).matrix_wi{oo,22} = (obj.zone(ind).matrix_wi{oo,22}*area_oo+obj.zone(ind).matrix_wi{pp,22}*area_pp)/area_tot;
                                obj.zone(ind).matrix_wi{oo,23} = obj.zone(ind).matrix_wi{oo,23} + obj.zone(ind).matrix_wi{pp,23};
                                obj.zone(ind).matrix_wi{oo,25} = [obj.zone(ind).matrix_wi{oo,25}; obj.zone(ind).matrix_wi{pp,25}];
                                obj.zone(ind).matrix_wi{oo,26} = [obj.zone(ind).matrix_wi{oo,26}; obj.zone(ind).matrix_wi{pp,26}];
                                obj.zone(ind).matrix_wi{oo,27} = [obj.zone(ind).matrix_wi{oo,27}; obj.zone(ind).matrix_wi{pp,27}];
                                obj.zone(ind).matrix_wi{oo,28} = [obj.zone(ind).matrix_wi{oo,28}; obj.zone(ind).matrix_wi{pp,28}];
                                obj.zone(ind).matrix_wi{oo,29} = [obj.zone(ind).matrix_wi{oo,29}; obj.zone(ind).matrix_wi{pp,29}];
                                obj.zone(ind).matrix_wi{oo,30} = [obj.zone(ind).matrix_wi{oo,30}; obj.zone(ind).matrix_wi{pp,30}];
                                canc(uu) = pp;
                                uu = uu+1;
                            end 
                        end
                    end
                    obj.zone(jj).matrix_wi{oo,31} = [];
                end
                count = 0;
                canc = sort(canc);
                canc = unique(canc);
                %delete the double rows
                for ii = 1:length(canc)
                    obj.zone(ind).matrix_wi(canc(ii)-count,:) = [];
                    count = count+1;
                 end
             else
                 error(['zone ' number ' not existing!'])
             end
        end
        
        function obj = update_zone_end(obj, building)
            % cleans all updates zones:  A. It updates the boundary 
            % conditions with the name of the zones; B. It sums the walls 
            % with the same characteristics
            % 1 ... building object
            names_room_zone = {};
            count = 1;
            % to have a matrix with the name of the zones with the rooms
            for ii = 1:length(obj.zone)
                for jj = 1:length(obj.zone(ii).rooms)
                    names_room_zone{count,1} = obj.zone(ii).rooms{jj};
                    names_room_zone{count,2} = obj.zone(ii).name;
                    count = count+1;
                end
            end
            % to change the boundary conditions of the matrix of the walls
            % from the name of the rooms to the name of the zones
            for ii = 1:length(obj.zone)
                for jj = 1:size(obj.zone(ii).matrix_wd,1)
                    for ll = 1:size(names_room_zone,1)
                        if (strcmp(obj.zone(ii).matrix_wd{jj,3}, names_room_zone{ll,1}))
                            obj.zone(ii).matrix_wd{jj,3} = names_room_zone{ll,2};
                        end
                    end
                end
            end
            % to sum the walls in one zone with the same boundary
            % conditions (if they have the same structure, ... then they are summed up)
            for jj = 1:length(obj.zone)
                ttt = [];
                uu = 1;
                canc = [];
                for oo = 1:size(obj.zone(jj).matrix_wd,1)
                    ttt(oo) = oo;
                    for pp = 1:size(obj.zone(jj).matrix_wd,1)
                        if oo ~= pp && all(pp ~= ttt)
                            % compare obj.zone(jj).matrix
                            if  ((strcmp(obj.zone(jj).matrix_wd{oo,1}, obj.zone(jj).matrix_wd{pp,1})) &&... % construction name
                                (strcmp(obj.zone(jj).matrix_wd{oo,3},obj.zone(jj).matrix_wd{pp,3})) &&... % boundary
                                obj.zone(jj).matrix_wd{oo,6} == obj.zone(jj).matrix_wd{pp,6}...
                                && obj.zone(jj).matrix_wd{oo,7} == obj.zone(jj).matrix_wd{pp,7} &&...
                                obj.zone(jj).matrix_wd{oo,8} == obj.zone(jj).matrix_wd{pp,8} &&...
                                obj.zone(jj).matrix_wd{oo,13} == obj.zone(jj).matrix_wd{pp,13} &&...
                                obj.zone(jj).matrix_wd{oo,9} == obj.zone(jj).matrix_wd{pp,9})
                                if ( (obj.zone(jj).matrix_wd{oo,4} == obj.zone(jj).matrix_wd{pp,4}) && ((obj.zone(jj).matrix_wd{oo,5} == obj.zone(jj).matrix_wd{pp,5})) ) | strcmp(obj.zone(jj).matrix_wd{oo,3},'INTERNAL')
                                    obj.zone(jj).matrix_wd{oo,2} = obj.zone(jj).matrix_wd{oo,2}+obj.zone(jj).matrix_wd{pp,2};
                                    canc(uu) = pp;
                                    uu = uu+1;
                                elseif  ~strcmp(obj.zone(jj).matrix_wd{oo,3},'AMBIENT') & (((obj.zone(jj).matrix_wd{oo,4} == obj.zone(jj).matrix_wd{pp,4}) & obj.zone(jj).matrix_wd{oo,4} == 90) | (obj.zone(jj).matrix_wd{oo,4} ~= 90 & obj.zone(jj).matrix_wd{pp,4} ~= 90))
                                    obj.zone(jj).matrix_wd{oo,2} = obj.zone(jj).matrix_wd{oo,2}+obj.zone(jj).matrix_wd{pp,2};
                                    canc(uu) = pp;
                                    uu = uu+1;
                                % elseif  strcmp(obj.zone(jj).matrix_wd{oo,3},'INTERNAL')
                                %     obj.zone(jj).matrix_wd{oo,2} = obj.zone(jj).matrix_wd{oo,2}+obj.zone(jj).matrix_wd{pp,2};
                                %     canc(uu) = pp;
                                %     uu = uu+1;                                
                                end
                            end
                        end
                    end
                    % to put in the number of boundary (matrix wd) the
                    % number of NEIGHBOUR or GROUND
                    if (length(obj.zone(jj).matrix_wd{oo,3}) >9 && (strcmp(obj.zone(jj).matrix_wd{oo,3}(1:9), 'NEIGHBOUR'))) || (length(obj.zone(jj).matrix_wd{oo,3}) >6 && (strcmp(obj.zone(jj).matrix_wd{oo,3}(1:6), 'GROUND')))
                        if (strcmp(obj.zone(jj).matrix_wd{oo,3}(end-1), '_'))
                            obj.zone(jj).matrix_wd{oo,12} = str2num(obj.zone(jj).matrix_wd{oo,3}(end));
                            stringa = obj.zone(jj).matrix_wd{oo,3};
                            obj.zone(jj).matrix_wd{oo,3} = {};
                            obj.zone(jj).matrix_wd{oo,3} = stringa(1:(end-2));
                        else
                            obj.zone(jj).matrix_wd{oo,12} = 1;
                        end
                    else
                        obj.zone(jj).matrix_wd{oo,12} = 1;
                    end
                end
                canc = sort(canc);
                canc = unique(canc);
                count = 0;
                
                % delete the empty rows
                for ii = 1:length(canc)
                    obj.zone(jj).matrix_wd(canc(ii)-count,:) = [];
                    count = count+1;
                end
                
                % calculate solar_factor
                A_tot = 0;  
                for ii = 1:size(obj.zone(jj).matrix_wd,1)
                    if (strcmp(obj.zone(jj).matrix_wd{ii,3}, obj.zone(jj).name))
%                     if (strcmp(obj.zone(jj).matrix_wd{ii,3}, 'INTERNAL'))
                        disp('INTERNAL')
                        A_tot = A_tot + 2*obj.zone(jj).matrix_wd{ii,2};
                    else
                        A_tot = A_tot + obj.zone(jj).matrix_wd{ii,2};
                    end
                end
                
                for ii = 1:size(obj.zone(jj).matrix_wd,1)
                    obj.zone(jj).matrix_wd{ii,11} = obj.zone(jj).matrix_wd{ii,2}/A_tot;
                    
                    switch obj.zone(jj).matrix_wd{ii,3} 
                        case 'INTERNAL'
                            obj.zone(jj).matrix_wd{ii,11} = obj.zone(jj).matrix_wd{ii,11}/ 2;
                    end
                end
            end
            
            for ii = 1:length(obj.zone)
                for jj = 1:size(obj.zone(ii).matrix_wi,1)
                    time_factor = obj.zone(ii).matrix_wi{jj,13};
                    seq_factor = obj.zone(ii).matrix_wi{jj,14};
                    
                    if length(time_factor) == 13
                        if time_factor(1) == 0 && round(time_factor(end)) == 365*24*3600
                            % everything is fine
                        else
                            warning(['The shading vector for a window in the zone ' num2str(ii) ' looks strange. An automatic reparation is tried. Please check it!'])
                            time_factor = [0 31 59 90 120 151 181 212 243 273 304 334 365]*24*3600;
                        end
                        time_factor_ = time_factor-365*24*3600;
                        seq_factor_ = seq_factor;
                        for lll = 0:building.maxruntime
                            time_factor_ = [time_factor_, time_factor(2:end)+lll*365*24*3600];
                            seq_factor_ = [seq_factor_, seq_factor(2:end)];
                        end
                    else
                        time_factor_ = time_factor-365*24*3600;
                        seq_factor_ = seq_factor;
                        for lll = 0:building.maxruntime
                            time_factor_ = [time_factor_, time_factor(2:end)+lll*365*24*3600];
                            seq_factor_ = [seq_factor_, seq_factor(2:end)];
                        end
                    end
                    
                    obj.zone(ii).win_factor_seq{jj}  = [time_factor_' seq_factor_'];
                end
            end
        end
        
        function obj = add_intersection(obj, number, name, zones)
            % to add a new intersection
            % 1 ... number of the intersection
            % 2 ... name of the intersection
            % 3 ... list of the two zones that involve the intersection
            ind = [];
                obj.intersection{zones(1),zones(2)} = INTERSECTION(number, name, zones);
        end
         
        function obj = update_intersection(obj, number)
            % to update the intersection:
            % A. It takes the walls of the zones with same area and same
            % characteristics and mutual BC and and put one of it in the
            % intersection 
            % B. It deletes this walls from the matrix of the walls
            % 1 ... number of the intersection
           
            ind = [];
            % to individuate the zone
            for jj = 1:size(obj.intersection,1)    
            tt(jj) = jj;
                for kk = 1:size(obj.intersection,2)
                    if jj ~= kk && all(kk ~= tt)
                        if obj.intersection{jj,kk}.number == number
                            ind(1) = jj;
                            ind(2) = kk;
                            break
                        end
                    end
                end
            end
            % check if zone is not existing
            if ind
                % does it for each room of the zone
                ind_z = [];
                count = 1;
                for kk = 1:length(obj.intersection{ind(1),ind(2)}.zones)
                    for jj = 1:length(obj.zone)
                        if obj.zone(jj).number == obj.intersection{ind(1),ind(2)}.zones(kk)
                            ind_z(count) = jj;
                            count = count+1;
                        end
                    end
                end
                ind_sum = 1;
                ttt = [];
                zzz = [];
                canc_ll = [];
                canc_mm = [];
                for ll = 1:length(obj.zone(ind_z))
                    ttt(ll) = ll;
                    for mm = 1:length(obj.zone(ind_z))
                        if ll ~= mm && all(mm ~= ttt)
                            ind_canc = 1;
                            for nn = 1:size(obj.zone(ind_z(ll)).matrix_wd,1)
                                zzz(nn) = nn;
                                for oo = 1:size(obj.zone(ind_z(mm)).matrix_wd,1)
                                    % if the characteristics of the walls
                                    % are the same, then it puts the wall
                                    % in the intersection
                                    % if (strcmp(obj.zone(ind_z(ll)).matrix_wd{nn,1}, obj.zone(ind_z(mm)).matrix_wd{oo,1}) && (round(obj.zone(ind_z(ll)).matrix_wd{nn,2},2)==round(obj.zone(ind_z(mm)).matrix_wd{oo,2},2)) && ((obj.zone(ind_z(ll)).matrix_wd{nn,4} == obj.zone(ind_z(mm)).matrix_wd{oo,4}+180) || (obj.zone(ind_z(ll)).matrix_wd{nn,4} == obj.zone(ind_z(mm)).matrix_wd{oo,4}-180) || (obj.zone(ind_z(ll)).matrix_wd{nn,4} == obj.zone(ind_z(mm)).matrix_wd{oo,4}) ) && (obj.zone(ind_z(ll)).matrix_wd{nn,6} == obj.zone(ind_z(mm)).matrix_wd{oo,6}) && (obj.zone(ind_z(ll)).matrix_wd{nn,7} == obj.zone(ind_z(mm)).matrix_wd{oo,7}) && (obj.zone(ind_z(ll)).matrix_wd{nn,8} == obj.zone(ind_z(mm)).matrix_wd{oo,8}) && (obj.zone(ind_z(ll)).matrix_wd{nn,9} == obj.zone(ind_z(mm)).matrix_wd{oo,9}) && (obj.zone(ind_z(ll)).matrix_wd{nn,13} == obj.zone(ind_z(mm)).matrix_wd{oo,13}) )
                                    if (strcmp(obj.zone(ind_z(ll)).matrix_wd{nn,1}, obj.zone(ind_z(mm)).matrix_wd{oo,1}) && (floor(obj.zone(ind_z(ll)).matrix_wd{nn,2}*100)/100)==(floor(obj.zone(ind_z(mm)).matrix_wd{oo,2}*100)/100) && ((obj.zone(ind_z(ll)).matrix_wd{nn,4} == obj.zone(ind_z(mm)).matrix_wd{oo,4}+180) || (obj.zone(ind_z(ll)).matrix_wd{nn,4} == obj.zone(ind_z(mm)).matrix_wd{oo,4}-180) || (obj.zone(ind_z(ll)).matrix_wd{nn,4} == obj.zone(ind_z(mm)).matrix_wd{oo,4}) ) && (obj.zone(ind_z(ll)).matrix_wd{nn,6} == obj.zone(ind_z(mm)).matrix_wd{oo,6}) && (obj.zone(ind_z(ll)).matrix_wd{nn,7} == obj.zone(ind_z(mm)).matrix_wd{oo,7}) && (obj.zone(ind_z(ll)).matrix_wd{nn,8} == obj.zone(ind_z(mm)).matrix_wd{oo,8}) && (obj.zone(ind_z(ll)).matrix_wd{nn,9} == obj.zone(ind_z(mm)).matrix_wd{oo,9}) && (obj.zone(ind_z(ll)).matrix_wd{nn,13} == obj.zone(ind_z(mm)).matrix_wd{oo,13}) ) %MM 23 07 2025 bug with similar numbers and round function leading to different areas
                                        if (strcmp(obj.zone(ind_z(ll)).matrix_wd{nn,3}, obj.zone(ind_z(mm)).name) && strcmp(obj.zone(ind_z(mm)).matrix_wd{oo,3}, obj.zone(ind_z(ll)).name))
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,1} = obj.zone(ind_z(ll)).matrix_wd{nn,1};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,2} = obj.zone(ind_z(ll)).matrix_wd{nn,2};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,3} = obj.zone(ind_z(ll)).matrix_wd{nn,3};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,4} = obj.zone(ind_z(ll)).matrix_wd{nn,4};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,5} = obj.zone(ind_z(ll)).matrix_wd{nn,5};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,6} = obj.zone(ind_z(ll)).matrix_wd{nn,6};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,7} = obj.zone(ind_z(ll)).matrix_wd{nn,7};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,8} = obj.zone(ind_z(ll)).matrix_wd{nn,8};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,9} = obj.zone(ind_z(ll)).matrix_wd{nn,9};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,10} = obj.zone(ind_z(ll)).matrix_wd{nn,10};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,11} = [obj.zone(ind_z(ll)).matrix_wd{nn,11} obj.zone(ind_z(mm)).matrix_wd{oo,11}];
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,12} = obj.zone(ind_z(ll)).matrix_wd{nn,12};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,13} = obj.zone(ind_z(ll)).matrix_wd{nn,13};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,14} = obj.zone(ind_z(ll)).matrix_wd{nn,14};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,15} = obj.zone(ind_z(ll)).matrix_wd{nn,15};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,16} = obj.zone(ind_z(ll)).matrix_wd{nn,16};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,17} = obj.zone(ind_z(ll)).matrix_wd{nn,17};
                                            obj.intersection{ind(1),ind(2)}.matrix_wd{ind_sum,18} = obj.zone(ind_z(ll)).matrix_wd{nn,18};
                                            ind_sum = ind_sum+1;
                                            canc_ll(ind_canc,:) = [ll nn];
                                            canc_mm(ind_canc,:) = [mm oo];
                                            ind_canc = ind_canc+1;
                                        end 
                                    elseif (strcmp(obj.zone(ind_z(ll)).matrix_wd{nn,3}, obj.zone(ind_z(ll)).name))
                                        obj.zone(ind_z(ll)).matrix_wd{nn,3} = 'INTERNAL';
                                    end
                                end
                            end
                            
                            % to delete the walls from the zones
                            if canc_ll
                                canc_ll_new = [];
                                canc_mm_new = [];
                                ord = [];
                                [canc_ll_new ord] = sort(canc_ll(:,2));
                                canc_ll=canc_ll(ord,:);
                                canc_ll=unique(canc_ll,'rows');
                                ord=[];
                                [canc_mm_new ord] = sort(canc_mm(:,2));
                                canc_mm=canc_mm(ord,:);
                                canc_mm=unique(canc_mm,'rows');
                                count = 0;
                                for ii = 1:size(canc_ll,1)
                                    obj.zone(ind_z(canc_ll(ii,1))).matrix_wd(canc_ll(ii,2)-count,:) = [];
                                    count = count+1;
                                end
                                count = 0;
                                for ii = 1:size(canc_mm,1)
                                    obj.zone(ind_z(canc_mm(ii,1))).matrix_wd(canc_mm(ii,2)-count,:) = [];
                                    count = count+1;
                                end
                            else
                                obj.intersection{ind(1),ind(2)}.matrix_wd={};
                                obj.intersection{ind(1),ind(2)}.name = ['EMPTY_' num2str(ind(1)) '_' num2str(ind(2))];
                            end
                        end
                    end
                end
            else % with if ind
            error(['intersection ' number ' not existing!'])
            end
        end
        
        function obj = heatedarea_zone(obj, number, geometry)
            % calculates the heated area and heated volume for a zone
            % 1 ... number of the zone
            % 2 ... geometry object
            ind = [];
            for jj = 1:length(obj.zone)
                if obj.zone(jj).number == number
                    ind = jj;
                    break
                end
            end
            % check if zone is not existing
            if ind
                area = 0;
                vol = 0;
                num = 0;
                for kk = 1:length(obj.zone(ind).rooms)
                    room(kk) = geometry.get_room(obj.zone(ind).rooms(kk));
                    area = area + room(kk).area;
                    num = num+1;
                    vol = (vol + room(kk).height*room(kk).area);
                end
                % height = height/num;
                obj.zone(ind).heated_area = area;
                obj.zone(ind).heated_volume = vol;
            else
                error(['zone number ' number ' is not existing!'])
            end
            
        end
        
        function check_solar_ratio(obj,number)
            % check that the sum of the solar ratio in 1 zone is equal to
            % 1, if not it gives a warning
            % 1 ... number of the zone
            factor = 0;
            for jj = 1:length(obj.zone)
                if obj.zone(jj).number == number
                    for ii = 1:size(obj.zone(jj).matrix_wd,1)
                        if strcmp(obj.zone(jj).matrix_wd{ii,3},'INTERNAL')
                            factor = factor + 2*obj.zone(jj).matrix_wd{ii,11};
                        else
                            factor = factor + obj.zone(jj).matrix_wd{ii,11};
                        end
                    end
                end
            end
            for jj = 1:size(obj.intersection,1)    
                tt(jj) = jj;
                for kk = 1:size(obj.intersection,2)
                    if jj ~= kk && all(kk ~= tt)
                        for ll = 1:length(obj.intersection{jj,kk}.zones)
                            if obj.intersection{jj,kk}.zones(ll) == number
                                for ii = 1:size(obj.intersection{jj,kk}.matrix_wd,1)
                                    factor_temp = obj.intersection{jj,kk}.matrix_wd{ii,11};
                                    factor = factor + factor_temp(ll);
                                end
                            end
                        end
                    end
                end
            end
            if (factor > 0.999) && (factor < 1.001)
%                 disp(['Solar ratio for zone ' num2str(number) ' equal to 1 (' num2str(factor) ').'])
            else
                warning(['Solar ratio for zone ' num2str(number) ' not equal to 1 (' num2str(factor) ')!'])
            end
        end
        
        function check_matrix(obj, number, number2)
            % check the matrixes (wd, wi and gains) of a zone or a 
            % intersection with uitable
            % 1 ... number of the zone
            % 2 ... number of the second zone (just if you want to plot the
            % matrix of a intersection)
            
            ind = [];
            t1 = 0;
            t2 = 0;
            % to individuate the zone
            if (nargin < 3)
                for jj = 1:length(obj.zone)
                    if obj.zone(jj).number == number
                        ind = jj;
                        break
                    end
                end

                if size(obj.zone(ind).matrix_wd,1) > 0
                    f1 = figure;
                    f1.Name = ['zone ' num2str(ind) ' (' obj.zone(ind).name '): walls/doors'];
                    f1.NumberTitle = 'off';
                    f1.MenuBar = 'none';
                    cnames_wd = {'construction','area','boundary','orientation_slope','orientation_azimuth','orientation_rotation','model_contruction','model_heattransfer','view factor','ambient factor','solar ratio','number of boundary','model_inf','height','C','n','V','control_i'};

                    for ii = 1:size(obj.zone(ind).matrix_wd,1)
                        data_wd(ii,1:18) = {obj.zone(ind).matrix_wd{ii,1:14} num2str(obj.zone(ind).matrix_wd{ii,15}) num2str(obj.zone(ind).matrix_wd{ii,16}) num2str(obj.zone(ind).matrix_wd{ii,17}) (obj.zone(ind).matrix_wd{ii,18})};
                    end
                    t1 = uitable(f1, 'data', data_wd , 'ColumnName', cnames_wd, 'unit', 'normalized', 'Position', [0 0 1 1]);
                else
                    warning(['No walls in the zone ' num2str(ind) '.'])
                end

                if size(obj.zone(ind).matrix_wi,1) > 0
                    f2 = figure;
                    f2.Name = ['zone ' num2str(ind) ' (' obj.zone(ind).name '): windows'];
                    f2.NumberTitle = 'off';
                    f2.MenuBar = 'none';
                    cnames_wi = {'construction','width','height','boundary','orientation_slope','orientation_azimuth','orientation_rotation','model_contruction','frame ratio','glass area','view factor','ambient factor','fs time','fs values','fd','l*psi_installation','length of glass','control_s','model_inf','z','C','n','V','control_i','width_multiple','height_multiple','shadingtop','shadingleft','shadingright','shadinghorizont'};
                    for ii = 1:size(obj.zone(ind).matrix_wi,1)
                        data_wi(ii,1:30) = {obj.zone(ind).matrix_wi{ii,1:12} num2str(obj.zone(ind).matrix_wi{ii,13}) num2str(obj.zone(ind).matrix_wi{ii,14}) obj.zone(ind).matrix_wi{ii,15:20} num2str(obj.zone(ind).matrix_wi{ii,21}) num2str(obj.zone(ind).matrix_wi{ii,22}) num2str(obj.zone(ind).matrix_wi{ii,23}) (obj.zone(ind).matrix_wi{ii,24}) num2str(obj.zone(ind).matrix_wi{ii,25})  num2str(obj.zone(ind).matrix_wi{ii,26})  num2str(obj.zone(ind).matrix_wi{ii,27})  num2str(obj.zone(ind).matrix_wi{ii,28}) num2str(obj.zone(ind).matrix_wi{ii,29})  num2str(obj.zone(ind).matrix_wi{ii,30})};
                    end
                    t2 = uitable(f2, 'data', data_wi , 'ColumnName', cnames_wi, 'unit', 'normalized', 'Position', [0 0 1 1]);
                else
                    warning(['No windows in the zone ' num2str(ind) '.'])
                end

                if size(obj.zone(ind).matrix_gains,1) > 0
                    f3 = figure;
                    f3.Name = ['zone ' num2str(ind) ' (' obj.zone(ind).name '): gains'];
                    f3.NumberTitle = 'off';
                    f3.MenuBar = 'none';
                    cnames_gains = {'name','model','type','time values','time duration','values 1','values 2','values 3','control'};
                    for ii = 1:size(obj.zone(ind).matrix_gains,1)
                        data_gains(ii,1:9) = {obj.zone(ind).matrix_gains{ii,1:3} num2str(obj.zone(ind).matrix_gains{ii,4}) num2str(obj.zone(ind).matrix_gains{ii,5}) num2str(obj.zone(ind).matrix_gains{ii,6}) num2str(obj.zone(ind).matrix_gains{ii,7}) num2str(obj.zone(ind).matrix_gains{ii,8})  (obj.zone(ind).matrix_gains{ii,9})  };
                    end
                    t2 = uitable(f3, 'data', data_gains , 'ColumnName', cnames_gains, 'unit', 'normalized', 'Position', [0 0 1 1]);
                else
                    warning(['No gains in the zone ' num2str(ind) '.'])
                end
            else
                
                for jj = 1:size(obj.intersection,1)    
                tt(jj) = jj;
                    for kk = 1:size(obj.intersection,2)
                        if jj ~= kk && all(kk ~= tt)
                            if (obj.intersection{jj,kk}.zones(1) == number && obj.intersection{jj,kk}.zones(2) == number2) || (obj.intersection{jj,kk}.zones(2) == number && obj.intersection{jj,kk}.zones(1) == number2)
                                ind(1) = jj;
                                ind(2) = kk;
                                break
                            end
                        end
                    end
                end
                if size(obj.intersection{ind(1),ind(2)}.matrix_wd,1) > 0
                    f1 = figure;
                    f1.Name = ['intersection ' num2str(ind(1)) '_' num2str(ind(2)) ' (' obj.intersection{ind(1),ind(2)}.name '): walls/doors'];
                    f1.NumberTitle = 'off';
                    f1.MenuBar = 'none';
                    cnames_wd = {'construction','area','boundary','orientation_slope','orientation_azimuth','orientation_rotation','model_contruction','model_heattransfer','view factor','ambient factor','solar ratio','number of boundary','model_inf','height','C','n','V','control_i'};

                    for ii = 1:size(obj.intersection{ind(1),ind(2)}.matrix_wd,1)
                        data_wd(ii,1:18) = {obj.intersection{ind(1),ind(2)}.matrix_wd{ii,1:10} num2str(obj.intersection{ind(1),ind(2)}.matrix_wd{ii,11}) (obj.intersection{ind(1),ind(2)}.matrix_wd{ii,12:14}) num2str(obj.intersection{ind(1),ind(2)}.matrix_wd{ii,15}) num2str(obj.intersection{ind(1),ind(2)}.matrix_wd{ii,16}) num2str(obj.intersection{ind(1),ind(2)}.matrix_wd{ii,17}) (obj.intersection{ind(1),ind(2)}.matrix_wd{ii,18})};
                    end
                    t1 = uitable(f1, 'data', data_wd , 'ColumnName', cnames_wd, 'unit', 'normalized', 'Position', [0 0 1 1]);
                else
                    warning(['No walls in the intersection ' num2str(ind(1)) '_' num2str(ind(2)) '.'])
                end
            end
        end
        
        function plot_building(obj, num_zone, geometry)
            % to plot the walls and window of a zone
            % 1 ... list of the number of the zone
            % 2 ... geometry object
            colour =[];
            colour(1,1:3) = [249 109 26] ./ 255;
            colour(2,1:3) = [15 118 44] ./ 255;
            colour(3,1:3) = [37 37 251] ./ 255;
            colour(4,1:3) = [181 21 16] ./ 255;
            colour(5,1:3) = [254 219 62] ./ 255;
            colour(6,1:3) = [102 29 227] ./ 255;
            colour(7,1:3) = [26 238 226] ./ 255;
            colour(8,1:3) = [99 168 215] ./ 255;
            colour(9,1:3) = [252 185 155] ./ 255;
            colour(10,1:3) = [245 247 135] ./ 255;
            figure
            hold all
            for kk = 1:length(num_zone)
                for ll = 1:length(obj.zone(num_zone(kk)).rooms)
                    room = geometry.get_room(obj.zone(num_zone(kk)).rooms(ll)); 
                    for mm = 1:length(room.wall)
                        if strcmp(room.wall(mm).name(end-2:end-1), 'fl') || strcmp(room.wall(mm).name(end-2:end-1), 'ce')
                            plot(room.wall(mm), colour(kk,1:3))
                            plot(room.wall(mm), 'red')
                            axis equal
                            rotate3d on
                            axis tight
                        else
                            plot(room.wall(mm), colour(kk,1:3))
                            axis equal
                            rotate3d on
                            axis tight
                        end
                    end
                end
            end
        end
        
        function obj = update_thermalzone(obj, geom, buil, variant_gains)
            % A. It runs the functions "update_zone", "heatedarea_zone" and 
            % "update_zone_end". B. It creates the intersections C. It runs
            % the function "update_intersection" d. If the orientation of
            % the walls is not important, the external walls are merged
            % 1 ... object geometry
            % 2 ... object building
            
            for jj = 1:length(obj.zone)
                obj.zone(jj).matrix_wd = [];
                obj.zone(jj).matrix_wi = [];
                obj.zone(jj).matrix_gains = [];
                obj.zone(jj).win_factor_seq = [];
            end
                
            for jj = 1:length(obj.zone)
                obj = obj.update_zone(jj, geom, buil, variant_gains);
                obj = obj.heatedarea_zone(jj, geom);
            end
            obj = obj.update_zone_end(buil);
            
            tt = [];
            for ii = 1:length(obj.zone)
                tt(ii) = ii;
                for jj = 1:length(obj.zone)
                    if ii ~= jj && all(jj ~= tt)
                        if ii < 10
                            if jj <10
                                num = ii*10+jj;
                            else
                                num = ii*100+jj;
                            end
                        else
                            num = ii*100+jj; 
                        end
                        obj = obj.add_intersection(num,['intersection_' num2str(ii) '_' num2str(jj)], [ii,jj]);
                    end
                end
            end

            tt = [];

            for ii = 1:length(obj.zone)
                tt(ii) = ii;
                for jj = 1:length(obj.zone)
                    if ii ~= jj && all(jj ~= tt)
                        if ii < 10
                            if jj <10
                                num = ii*10+jj;
                            else
                                num = ii*100+jj;
                            end
                        else
                            num = ii*100+jj; 
                        end
                        obj = obj.update_intersection(num);
                    end
                end
            end
            
            for jj = 1:length(obj.zone)
                if obj.zone(jj).orientation_important == 0
                    ttt = [];
                    uu = 1;
                    canc =[];
                    % sum the areas of the walls that have the same
                    % characteristics
                    for oo = 1:size(obj.zone(jj).matrix_wd,1)
%                         obj.zone(jj).matrix_wd{oo,4} = 90;
                        obj.zone(jj).matrix_wd{oo,5} = 180;
                        obj.zone(jj).matrix_wd{oo,6} = 0;
                    end
                    for oo = 1:size(obj.zone(jj).matrix_wd,1)
                        ttt(oo) = oo;
                        for pp = 1:size(obj.zone(jj).matrix_wd,1)
                            if oo ~= pp && all(pp ~= ttt)
                                % compare obj.zone(jj).matrix
                                if  (strcmp(obj.zone(jj).matrix_wd{oo,1}, obj.zone(jj).matrix_wd{pp,1}) && ...
                                    strcmp(obj.zone(jj).matrix_wd{oo,3},obj.zone(jj).matrix_wd{pp,3}) && ...
                                    obj.zone(jj).matrix_wd{oo,7} == obj.zone(jj).matrix_wd{pp,7} && ...
                                    obj.zone(jj).matrix_wd{oo,8} == obj.zone(jj).matrix_wd{pp,8} && ...
                                    obj.zone(jj).matrix_wd{oo,9} == obj.zone(jj).matrix_wd{pp,9} && ...
                                    obj.zone(jj).matrix_wd{oo,10} == obj.zone(jj).matrix_wd{pp,10} && ...
                                    obj.zone(jj).matrix_wd{oo,12} == obj.zone(jj).matrix_wd{pp,12} && ...
                                    obj.zone(jj).matrix_wd{oo,13} == obj.zone(jj).matrix_wd{pp,13} && ...
                                    obj.zone(jj).matrix_wd{oo,18} == obj.zone(jj).matrix_wd{pp,18})&& ...
                                    (obj.zone(jj).matrix_wd{oo,4} == obj.zone(jj).matrix_wd{pp,4} && ...
                                    obj.zone(jj).matrix_wd{oo,5} == obj.zone(jj).matrix_wd{pp,5} && ...
                                    obj.zone(jj).matrix_wd{oo,6} == obj.zone(jj).matrix_wd{pp,6})

                                    obj.zone(jj).matrix_wd{oo,14} = (obj.zone(jj).matrix_wd{oo,14}+obj.zone(jj).matrix_wd{pp,14})/2;
                                    obj.zone(jj).matrix_wd{oo,15} = (obj.zone(jj).matrix_wd{oo,15}*obj.zone(jj).matrix_wd{oo,2}+obj.zone(jj).matrix_wd{pp,15}*obj.zone(jj).matrix_wd{pp,2})/(obj.zone(jj).matrix_wd{oo,2}+obj.zone(jj).matrix_wd{pp,2});
                                    obj.zone(jj).matrix_wd{oo,16} = (obj.zone(jj).matrix_wd{oo,16}*obj.zone(jj).matrix_wd{oo,2}+obj.zone(jj).matrix_wd{pp,16}*obj.zone(jj).matrix_wd{pp,2})/(obj.zone(jj).matrix_wd{oo,2}+obj.zone(jj).matrix_wd{pp,2});
                                    obj.zone(jj).matrix_wd{oo,17} = (obj.zone(jj).matrix_wd{oo,17}+obj.zone(jj).matrix_wd{pp,17});
                                    obj.zone(jj).matrix_wd{oo,2} = obj.zone(jj).matrix_wd{oo,2}+obj.zone(jj).matrix_wd{pp,2};
                                    obj.zone(jj).matrix_wd{oo,11} = obj.zone(jj).matrix_wd{oo,11}+obj.zone(jj).matrix_wd{pp,11};
                                    canc(uu) = pp;
                                    uu = uu+1;  
                                end 
                            end
                        end
                         obj.zone(jj).matrix_wd{oo,19} = [];
                    end
                    count = 0;
                    canc = sort(canc);
                    canc = unique(canc);
                    % delete the empty rows
                    for ii = 1:length(canc)
                        obj.zone(jj).matrix_wd(canc(ii)-count,:) = [];
                        count = count+1;
                    end
                end
            end
            
            for jj = 1:length(obj.zone)
                if size(obj.zone(1,jj).matrix_wd,1)<=6
                else
                    if jj==1
                        if size(obj.zone(1,jj).matrix_wd,1)<=10
                        else 
                            warning(['Too many walls (' num2str(size(obj.zone(1,jj).matrix_wd,1)) ') in zone ' num2str(jj) '. Max walls: 10!'])
                        end
                    else
                        warning(['Too many walls (' num2str(size(obj.zone(1,jj).matrix_wd,1)) ') in zone ' num2str(jj) '. Max walls: 6!'])
                    end
                end
            end
            tt = [];
            for jj = 1:size(obj.intersection,1)    
                tt(jj) = jj;
                for kk = 1:size(obj.intersection,2)
                    if jj ~= kk && all(kk ~= tt)
                        if size(obj.intersection{jj,kk}.matrix_wd,1)<=3
                        else
                            warning(['Too many walls (' num2str(size(obj.intersection{jj,kk}.matrix_wd,1)) ') in intersection ' num2str(jj) '-' num2str(kk) '. Max walls: 3!'])
                        end
                    end
                end
            end
        end
        
        function obj = add_cpspectozone_setorientimp(obj, name_xls_PHPP, language, version, number_zone, orientation_important)
            % PHPP: to take the specific cp from the PHPP and to set the
            % orientation of the wall to not important
            % 1 ... name of the file xls of the PHPP
            % 2 ... language: 1:german, 0:english
            % 3 ... version of PHPP used
            % 4 ... number of the zone
            
            filename = name_xls_PHPP;
            switch version
                case '9.1'
                    if language
                        sheet = 'Nachweis';
                    else
                        sheet = 'Verification';
                    end
                    range = 'K29';
                    [~, ~, data] = xlsread(filename, sheet, range);
                
                 case '10.2'
                    if language
                        sheet = 'Nachweis';
                    else
                        sheet = 'Verification';
                    end
                    range = 'K30';
                    [~, ~, data] = xlsread(filename, sheet, range);
            end
            obj.zone(number_zone).cp_spec = data{1,1}*3600;
            obj.zone(number_zone).orientation_important = orientation_important;
        end
        
    end
end

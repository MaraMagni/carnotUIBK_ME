%% BUILDING.m
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
% DS        2018-05-25   v1.3: cleanup the disp
% DS,EL	    2019-01-24   updates for GUI v2.0

%%
classdef BUILDING
    % BUILDING
    
    properties
        name = '';
        model = '';
        variant_geometry = 1;
        variant_construction = 1;
        variant_thermalzone = 1;
        variant_boundary = 1;
        variant_gains = 1;
        variant_hvac = 1;
        variant_result = 1;
        geometry = GEOMETRY();
        construction = CONSTRUCTION();
        thermalzone = THERMALZONE();
        boundary = BOUNDARY()
        gains = GAINS();
        hvac = HVAC();
        result = RES();
        PHPP = [];
        EXCEL = [];
        XML = [];
        maxruntime = 5; % years of maximium simulation (5 years)
        preruntime = 20*24*3600; % time of pre-simulation (20 days)
        runtime = 365*24*3600; % time of simulation (1 year)
        sampletime_1 = 600; % seconds
        sampletime_2 = 3600; % seconds
        sampletime_3 = 60; % seconds
        sampletime_4 = 10; % seconds
        datalogger = 1; % switch on datalogger
        internal_version = 1.0;     % do not change!
    end
    
    methods
        function obj = BUILDING()
            
        end
        
        function disp_checkmatrix(obj, thzone, input)
            clc
            if input == 1
                disp(['Variant Thermalzone number ' num2str(thzone) ': plot the matrixes of the zones'])
                for jj = 1:length(obj.thermalzone(thzone).zone)
                    disp(['       <a href="matlab:' inputname(1) '.thermalzone(' num2str(thzone) ').check_matrix(' num2str(jj) ')">zone ' num2str(jj) '</a>'])     
                end
                
            elseif input == 2
                disp(['Variant Thermalzone number ' num2str(thzone) ': plot the matrixes of the intersections'])
                tt = [];
                for ll = 1:size(obj.thermalzone(thzone).intersection,1)
                    tt(ll) = ll;
                    for mm = 1:size(obj.thermalzone(thzone).intersection,2)
                        if mm~=ll && all(mm~=tt)
                            disp(['       <a href="matlab:' inputname(1) '.thermalzone(' num2str(thzone) ').check_matrix(' num2str(ll) ',' num2str(mm) ')">intersection ' num2str(ll) '-' num2str(mm) '</a>'])     
                        end
                    end
                end
            end
        end
        
        function plot_rooms(obj, geom)
            disp(['Variant Geometry number ' num2str(geom) ': plot the rooms'])
            clc
            disp('  ')
            for ii = 1:length(obj.geometry(geom).room)
                name_room = obj.geometry(geom).room(ii).name;
                disp(['       <a href="matlab:' inputname(1) '.geometry(' num2str(geom) ').print_room(''' name_room '''); ">' name_room '</a>'])     
            end
        end
        
        function plot_zones(obj, thzone, geom)
            disp(['Variant Geometry number ' num2str(geom) ', Variant Thermalzone number ' num2str(thzone) ': plot the zones'])
            clc
            for ii = 1:length(obj.thermalzone(thzone).zone)
                if (length(obj.thermalzone(thzone).zone(1,ii).name)>4) && strcmp (obj.thermalzone(thzone).zone(1,ii).name(1:5), 'EMPTY')
                else 
                    name_zone = obj.thermalzone(thzone).zone(ii).name;
                    disp(['       <a href="matlab:' inputname(1) '.thermalzone(' num2str(thzone) ').plot_building(' num2str(ii) ', ' inputname(1) '.geometry(' num2str(geom) ')); ">' name_zone '</a>'])     
                end
            end
        end
        
        function disp(obj)
            % to display the building properties with links to the
            % principal functions to plot the inputs and the results
            fprintf('<strong> *** GENERAL *** </strong>\n')
            disp(['Used model: ' obj.model])
            disp(['Pre Run Time: ' num2str(obj.preruntime/3600/24) ' days'])
            disp(['Run Time: ' num2str(obj.runtime/3600/24) ' days'])
            disp(['Sample Time: ' num2str(obj.sampletime_1) ' s'])
            if obj.datalogger == 1
                dl = 'yes';
            else
                dl = 'no';
            end
            disp(['Data Logger: ' dl])
                      
            disp(' ')
            fprintf('<strong> *** THERMAL ZONES *** </strong>\n')
            for ii = 1:length(obj.thermalzone)
                list_zones = [];
                for jj =  1:size(obj.thermalzone(ii).zone,2)
                    if (length(obj.thermalzone(ii).zone(1,jj).name)>4) && strcmp (obj.thermalzone(ii).zone(1,jj).name(1:5), 'EMPTY')
                    else 
                        list_zones = [list_zones jj];
                    end
                end
                disp(['Variant number ' num2str(ii)])
                for ll = 1:length(list_zones)
                    name_rooms = [];
                    for mm = 1:length(obj.thermalzone(ii).zone(1,list_zones(ll)).rooms)
                        name_rooms = [name_rooms strjoin(obj.thermalzone(ii).zone(1,list_zones(ll)).rooms(mm)) '   '];
                    end
                    if obj.thermalzone(ii).zone(1,list_zones(ll)).model == 0
                        mod = 'none/temperature';
                    elseif obj.thermalzone(ii).zone(1,list_zones(ll)).model == 1
                        mod = 'ideal';
                    elseif obj.thermalzone(ii).zone(1,list_zones(ll)).model == 2
                        mod = '1-node';
                    elseif obj.thermalzone(ii).zone(1,list_zones(ll)).model == 3
                        mod = '2-node';
                    elseif obj.thermalzone(ii).zone(1,list_zones(ll)).model == 4
                        mod = '1-node without mass balance';
                    end
                disp([obj.thermalzone(ii).zone(1,list_zones(ll)).name ': ' name_rooms ' , MODEL:' mod ', HEATED AREA: '  num2str(obj.thermalzone(ii).zone(1,list_zones(ll)).heated_area) ' m²'])
                end
            end
            
            disp(['       <a href="matlab:' inputname(1) '.thermalzone(' num2str(ii) ').plot_building(1:10,' inputname(1) '.geometry(1))">plot all the thermal zones</a>'])
            disp(['       <a href="matlab:' inputname(1) '.plot_zones(' num2str(ii) ', 1)">plot ZONES' '</a>'])
            
            disp(' ')
            fprintf('<strong> *** GEOMETRY *** </strong>\n')
            for ii = 1:length(obj.geometry)
                disp(['Variant number ' num2str(ii)])
                disp(['       <a href="matlab:' inputname(1) '.plot_rooms(' num2str(ii) ');">plot ROOMS' '</a>'])
                disp(['       <a href="matlab:' inputname(1) '.geometry(' num2str(ii) ').print_geometry();">plot all the geometry' '</a>'])
            end
            
            disp(' ')
            fprintf('<strong> *** STRUCTURES *** </strong>\n')
            for ii = 1:length(obj.construction)
                disp(['Variant number ' num2str(ii)])
                disp(['Number of Structures: ' num2str(length(obj.construction(ii).structure))])
                disp(['       <a href="matlab:' inputname(1) '.construction(' num2str(ii) ').structure.disp()">info structures</a>'])     
                disp(['       <a href="matlab:' inputname(1) '.construction(' num2str(ii) ').structure.disp(1)">more info structures</a>'])   
                disp(['       <a href="matlab:' inputname(1) '.construction(' num2str(ii) ').structure.plot()">plot structures</a>'])   
            end
            
            disp(' ')
            fprintf('<strong> *** INTERNAL GAINS *** </strong>\n')
            for ii = 1:length(obj.gains)
                disp(['Variant number ' num2str(ii)])
                disp(['       <a href="matlab:' inputname(1) '.gains(' num2str(ii) ').plot_gain()">plot gains</a>']) 
                disp('  ')
            end
            
            disp(' ')
            fprintf('<strong> *** BOUNDARY *** </strong>\n')
            for ii = 1:length(obj.boundary)
                disp(['Variant number ' num2str(ii)])
                disp(['       <a href="matlab:' inputname(1) '.boundary(' num2str(ii) ').ground.plot()">plot ground temperature</a>'])     
                disp(['       <a href="matlab:' inputname(1) '.boundary(' num2str(ii) ').neighbour.plot()">plot neighbour temperature</a>'])   
                disp(['       <a href="matlab:' inputname(1) '.boundary(' num2str(ii) ').weather.plot()">plot weather temperature and radiation</a>     <a href="matlab:' inputname(1) '.boundary(' num2str(ii) ').weather.calculate_weather()">display monthly value of ambient temperature</a>'])   
            end
            
            disp(' ')
            fprintf('<strong> *** RESULTS *** </strong>\n')
            for ii=1:length(obj.result)
                if obj.result(ii).number == 0
%                     disp('  ')
                else
                    disp(['Result number ' num2str(obj.result(ii).number) ''])
                    disp(['   Date: ' num2str(obj.result(ii).date_of_sim) ''])
                    disp(['   Description: ' obj.result(ii).description ''])
                    if isfield(obj.result(ii).PHPP, 'name')
                        disp(['   PHPP Used: ' obj.result(ii).PHPP.name])
                    end
                    if isfield(obj.result(ii).EXCEL, 'name')
                        disp(['   EXCEL Used: ' obj.result(ii).EXCEL.name])
                    end
%                     if isfield(obj.result(ii).XML, 'name')
%                         disp(['   XML Used: ' obj.result(ii).XML.name])
%                     end
                    
                    if ~ischar(obj.result(ii).time_simulation)
                        if obj.result(ii).time_simulation/3600>1
                            time_simulation = [num2str(obj.result(ii).time_simulation/3600) ' h'];
                        else
                            time_simulation = [num2str(obj.result(ii).time_simulation/3600*60) ' min'];
                        end
                        disp(['   Simulation Time: ' time_simulation])
                    end
                    disp(['   Number of zones: ' num2str(length(obj.result(ii).list_zones))])
                    disp('  VARIANT  ')
                    disp(['    Variant: Geometry: ' num2str(obj.result(ii).variant_geometry) ', Construction: ' num2str(obj.result(ii).variant_construction) ', Thermalzone: ' num2str(obj.result(ii).variant_thermalzone) ', Boundary: ' num2str(obj.result(ii).variant_boundary) ', Gains: ' num2str(obj.result(ii).variant_gains) ', HVAC: ' num2str(obj.result(ii).variant_hvac) ''])
                    disp('  FUNCTIONS  ')
                    disp(['       <a href="matlab:' inputname(1) '.result.info(' num2str(obj.result(ii).number) ',' inputname(1) ');">info results</a>     <a href="matlab:' inputname(1) '.result.plot(' num2str(obj.result(ii).number) ',' inputname(1) ');">plot results</a>'])    
                    disp(['       <a href="matlab:' inputname(1) '.result.plot_zones_thC(' num2str(obj.result(ii).number) ',' inputname(1) ');">plot temperatures, humidity and CO2</a>   <a href="matlab:' inputname(1) '.result.plot_zones_thC(' num2str(obj.result(ii).number) ',' inputname(1) ', ''rel'', ''ppm'', 1);">plot only general</a>'])  
                    disp(['       <a href="matlab:' inputname(1) '.result.different_monthly_energies(' num2str(obj.result(ii).number) ',' inputname(1) ');">plot the monthly energy balances</a>   <a href="matlab:' inputname(1) '.result.different_monthly_energies(' num2str(obj.result(ii).number) ',' inputname(1) ', 1);">plot only general</a>']) 
                    disp(['       <a href="matlab:' inputname(1) '.result.energy_demand(' num2str(obj.result(ii).number) ',' inputname(1) ');">energy demand</a>   <a href="matlab:' inputname(1) '.result.energy_demand(' num2str(obj.result(ii).number) ',' inputname(1) ', 1);">only general</a>'])      
                    disp(['       <a href="matlab:' inputname(1) '.result.plot_heat_cool_power(' num2str(obj.result(ii).number) ',' inputname(1) ');">plot heating and cooling power</a>'])    
                    disp(['       <a href="matlab:' inputname(1) '.result.plot_heat_temp_hours(' num2str(obj.result(ii).number) ',' inputname(1) ');">plot heat load arranged by hours and by ambient temperature</a>'])  
                    disp(['       <a href="matlab:' inputname(1) '.result.plot_temp_amb_buil_soil(' num2str(obj.result(ii).number) ',' inputname(1) ');">plot ambient, ground and mean internal temperature</a>'])  
                    disp(['       <a href="matlab:' inputname(1) '.result.plot_temperature_arranged_hours(' num2str(obj.result(ii).number) ',' inputname(1) ');">plot temperature arranged by hours</a>'])  
                    disp(['       <a href="matlab:' inputname(1) '.result.plot_monthly_losses_gains(' num2str(obj.result(ii).number) ',' inputname(1) ');">plot monthly losses and gains</a>'])
                    if isfield(obj.result(ii).PHPP, 'language')
                        disp(['       <a href="matlab:' inputname(1) '.result.compare_with_PHPP(' num2str(obj.result(ii).number) ', ' inputname(1) ',''' (obj.result(ii).PHPP.name) ''', ' num2str(obj.result(ii).PHPP.language) ', '''  obj.result(ii).PHPP.version ''');">comparison with the PHPP</a>'])
                    end
                    disp('  ')
                end
            end
        end
        
        function plot(obj)
            % to plot the geometry of building
            obj.thermalzone.plot_building(1:length(obj.thermalzone.zone),obj.geometry)
            rotate3d on
            axis tight
        end
        
        function obj = add_variant_geometry(obj, num, geom)
            % to add a variant of the geometery
            % 1 ... number of the variant
            % 2 ... geometry object
            obj.geometry(num) = geom;
        end
        
        function obj = add_variant_construction(obj, num, cons)
            % to add a variant of the construction
            % 1 ... number of the variant
            % 2 ... construction object
            obj.construction(num) = cons;
        end
        
        function obj = add_variant_thermalzone(obj, num, thzo)
            % to add a variant of the thermalzone
            % 1 ... number of the variant
            % 2 ... thermalzone object
            obj.thermalzone(num) = thzo;
        end
        
        function obj = add_variant_boundary(obj, num, boun)
            % to add a variant of the boundary
            % 1 ... number of the variant
            % 2 ... boundary object
            obj.boundary(num) = boun;
        end
        
        function obj = add_variant_gains(obj, num, intgain)
            % to add a variant of the internal gains
            % 1 ... number of the variant
            % 2 ... gains object
            obj.gains(num) = intgain;
        end
        
        function obj = add_variant_hvac(obj, num, hvac)
            % to add a variant of the hvac
            % 1 ... number of the variant
            % 2 ... hvac object
            obj.hvac(num) = hvac;
        end
        
        function obj = add_variant_result(obj, num, res)
            % to add a variant of the result
            % 1 ... number of the variant
            % 2 ... result object
            obj.result(num) = res;
        end
        
        function obj2 = get_building(obj, variant_geometry, variant_construction, variant_thermalzone, variant_boundary, variant_gains, variant_hvac, variant_result)
            % to get the building from the variants of the objects
            obj2 = BUILDING();
            
            if nargin == 6
                obj2.geometry = GEOMETRY();
                obj2.construction = CONSTRUCTION();
                obj2.thermalzone = THERMALZONE();
                obj2.boundary = BOUNDARY();
                obj2.gains = GAINS();
                obj2.hvac = HVAC();
                obj2.geometry = obj.geometry(variant_geometry);
                obj2.construction = obj.construction(variant_construction);
                obj2.thermalzone = obj.thermalzone(variant_thermalzone);
                obj2.boundary = obj.boundary(variant_boundary);
                obj2.gains = obj.gains(variant_gains);
                obj2.hvac = obj.hvac(variant_hvac);
                obj2.maxruntime = obj.maxruntime;
                obj2.preruntime = obj.preruntime;
                obj2.runtime = obj.runtime;
                obj2.sampletime_1 = obj.sampletime_1;
                obj2.sampletime_2 = obj.sampletime_2;
                obj2.sampletime_3 = obj.sampletime_3;
                obj2.sampletime_4 = obj.sampletime_4;
                obj2.datalogger = obj.datalogger;
            elseif nargin == 7
                obj2.geometry = GEOMETRY();
                obj2.construction = CONSTRUCTION();
                obj2.thermalzone = THERMALZONE();
                obj2.boundary = BOUNDARY();
                obj2.gains = GAINS();
                obj2.hvac = HVAC();
                obj2.geometry = obj.geometry(variant_geometry);
                obj2.construction = obj.construction(variant_construction);
                obj2.thermalzone = obj.thermalzone(variant_thermalzone);
                obj2.boundary = obj.boundary(variant_boundary);
                obj2.gains = obj.gains(variant_gains);
                obj2.hvac = obj.hvac(variant_hvac);
                obj2.maxruntime = obj.maxruntime;
                obj2.preruntime = obj.preruntime;
                obj2.runtime = obj.runtime;
                obj2.sampletime_1 = obj.sampletime_1;
                obj2.sampletime_2 = obj.sampletime_2;
                obj2.sampletime_3 = obj.sampletime_3;
                obj2.sampletime_4 = obj.sampletime_4;
                obj2.datalogger = obj.datalogger;
            else
                obj2.geometry = GEOMETRY();
                obj2.construction = CONSTRUCTION();
                obj2.thermalzone = THERMALZONE();
                obj2.boundary = BOUNDARY();
                obj2.gains = GAINS();
                obj2.hvac = HVAC();
                obj2.geometry = obj.geometry(obj.variant_geometry);
                obj2.construction = obj.construction(obj.variant_construction);
                obj2.thermalzone = obj.thermalzone(obj.variant_thermalzone);
                obj2.boundary = obj.boundary(obj.variant_boundary);
                obj2.gains = obj.gains(obj.variant_gains);
                obj2.hvac = obj.hvac(obj.variant_hvac);
                
                obj2.maxruntime = obj.maxruntime;
                obj2.preruntime = obj.preruntime;
                obj2.runtime = obj.runtime;
                obj2.sampletime_1 = obj.sampletime_1;
                obj2.sampletime_2 = obj.sampletime_2;
                obj2.sampletime_3 = obj.sampletime_3;
                obj2.sampletime_4 = obj.sampletime_4;
                obj2.datalogger = obj.datalogger;
                
                obj2.variant_geometry = obj.variant_geometry;
                obj2.variant_construction = obj.variant_construction;
                obj2.variant_thermalzone = obj.variant_thermalzone;
                obj2.variant_boundary = obj.variant_boundary;
                obj2.variant_gains = obj.variant_gains;
                obj2.variant_hvac = obj.variant_hvac;
                obj2.PHPP = obj.PHPP;
                obj2.EXCEL = obj.EXCEL;
                obj2.name = obj.name;
                obj2.model = obj.model;
            end
        end
        
        function obj = add_simulation(obj, number, description_simulation, pre_time, time, saveAIB, saveBDB, saveBOUNDARY, saveHVAC, overwrite)
            % to save results of an existing simulation
            % 1 ... number
            % 2 ... description of simulation
            % 3 ... time for compilation of the model (min)
            % 4 ... time for simulating (computational time) (min)
            % 5 ... saveAIB
            % 6 ... saveBDB
            % 7 ... saveBOUNDARY
            % 8 ... saveHVAC
            % 9 ... optional if you want to overwrite the simulation number
            
            % check if the result number "number" is already existing
            if nargin == 9
                ind = [];
                for ii = 1:length(obj.result)
                    if obj.result(ii).number == number
                        error(['Result number ' num2str(obj.result(ii).number) ' already existing, if you want to overwrite the result, add a 1 as 3rd input of add_simulation' ])
                        ind = ii;
                        break
                    end
                end
            
            % to overwrite a result
            elseif nargin == 10
                if overwrite
                    ind = [];
                else
                    error(['Result number ' num2str(obj.result(ii).number) ' already existing!'])
                end
            end
            
            % to run the simulation and save the result in the actual building object
            if ind
            else
                date_of_sim = datestr(now);
                building_saved = obj.get_building();
                obj.result(number) = RES(number, building_saved, saveAIB, saveBDB, saveBOUNDARY, saveHVAC, date_of_sim, pre_time, time, description_simulation, obj.PHPP, obj.EXCEL, obj.variant_geometry, obj.variant_construction, obj.variant_thermalzone, obj.variant_boundary, obj.variant_gains, obj.variant_hvac);

            end
            
            % to save the result in the folder "building.name" under the name "result_number"
            try
                if exist([obj.name], 'dir') == 7
                else
                    mkdir([obj.name])
                end
                savedir = eval(['''' obj.name '\result_' num2str(number) '''']);
                obj.result = obj.result.save(savedir, number);
            catch
                warning('Saving the result was not possible.')    
            end
            % to save the building in the file named "building.name"
            try
                obj = obj.save();
            catch
                warning('Saving the building object was not possible.')    
            end
        end
        
        function obj = simulate(obj, number, description_simulation, overwrite)
            % to run a simulation and save it
            % 1 ... number
            % 2 ... description of simulation
            % 3 ... optional if you want to overwrite the simulation number
            
            % check if the result number "number" is already existing
            if nargin == 3
                ind = [];
                for ii = 1:length(obj.result)
                    if obj.result(ii).number == number
                        error(['Result number ' num2str(obj.result(ii).number) ' already existing, if you want to overwrite the result, add a 1 as 3rd input of simulate' ])
                        ind = ii;
                        break
                    end
                end
            
            % to overwrite a result
            elseif nargin == 4
                if overwrite
                    ind = [];
                else
                    error(['Result number ' num2str(obj.result(ii).number) ' already existing!'])
                end
            end
            
            % to run the simulation and save the result in the actual building object
            if ind
            else
                % tic
                date_of_sim = datestr(now);
                building_saved = obj.get_building();
                PHPP_save = obj.PHPP;
                EXCEL_save = obj.EXCEL;
                variant_geometry_save = obj.variant_geometry;
                variant_construction_save = obj.variant_construction;
                variant_thermalzone_save = obj.variant_thermalzone;
                variant_boundary_save = obj.variant_boundary;
                variant_gains_save = obj.variant_gains;
                variant_hvac_save = obj.variant_hvac;
                try
                    disp(['Simulation started with model ' obj.model '.'])
                    sim(obj.model);
                    disp(['Simulation finished within ' num2str(time_simulation/60) ' hours.'])
                catch
                    warning('During the simulation an error occured.')
                end
                % time_sim = toc;
                % load building again
                try
                    load(building.name)
                catch
                    disp('reload of building was not possible...')
                end
                
                % save result
                % obj.result(number) = RES(number, building_saved, saveAIB, saveBDB, saveBOUNDARY, saveHVAC, date_of_sim, time_sim, description_simulation, PHPP_save, EXCEL_save, variant_geometry_save, variant_construction_save, variant_thermalzone_save, variant_boundary_save, variant_gains_save, variant_hvac_save);
%                 obj.result(number) = RES(number, building_saved, saveAIB, saveBDB, saveBOUNDARY, saveHVAC, date_of_sim, time_sim, description_simulation, obj.PHPP, obj.EXCEL, obj.variant_geometry, obj.variant_construction, obj.variant_thermalzone, obj.variant_boundary, obj.variant_gains, obj.variant_hvac);
                obj.result(number) = RES(number, building_saved, saveAIB, saveBDB, saveBOUNDARY, saveHVAC, date_of_sim, pre_time, time, description_simulation, obj.PHPP, obj.EXCEL, obj.variant_geometry, obj.variant_construction, obj.variant_thermalzone, obj.variant_boundary, obj.variant_gains, obj.variant_hvac);
            end
            
            % save the result in the folder "building.name" under the name "result_number"
            try
                if exist([obj.name], 'dir') == 7
                else
                    mkdir([obj.name])
                end
                savedir = eval(['''' obj.name '\result_' num2str(number) '''']);
                obj.result = obj.result.save(savedir, number);
            catch
                warning('Saving the result was not possible.')    
            end
            
            % save the building in the file named "building.name"
            try
                obj = obj.save();
            catch
                warning('Saving the building object was not possible.')    
            end
        end
        
        function obj = save(obj)
            % save the building object
            % clean the results
            result_mod = RES();
            for ii = 1:length(obj.result)
                result_mod(1,ii).list_zones = obj.result(1,ii).list_zones;
                result_mod(1,ii).number = obj.result(1,ii).number;
                result_mod(1,ii).date_of_sim = obj.result(1,ii).date_of_sim;
                result_mod(1,ii).description = obj.result(1,ii).description;
                result_mod(1,ii).time_compilation = obj.result(1,ii).time_compilation;
                result_mod(1,ii).time_simulation = obj.result(1,ii).time_simulation;
                result_mod(1,ii).EXCEL = obj.result(1,ii).EXCEL;
                result_mod(1,ii).PHPP = obj.result(1,ii).PHPP;
                result_mod(1,ii).variant_geometry = obj.result(1,ii).variant_geometry;
                result_mod(1,ii).variant_construction = obj.result(1,ii).variant_construction;
                result_mod(1,ii).variant_thermalzone = obj.result(1,ii).variant_thermalzone;
                result_mod(1,ii).variant_boundary = obj.result(1,ii).variant_boundary;
                result_mod(1,ii).variant_gains = obj.result(1,ii).variant_gains;
                result_mod(1,ii).variant_hvac = obj.result(1,ii).variant_hvac;
            end
            obj.result = [];
            obj.result = result_mod;
            building = obj;
            save(obj.name,'building','-v7.3');
        end
    end
end
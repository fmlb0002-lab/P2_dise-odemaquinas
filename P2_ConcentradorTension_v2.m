clear; close all; clc

% --------- Materiales ----------
nu_pol = 0.37;  E_pol = 2.35e9;
nu_PLA = 0.36;  E_PLA = 3.50e9;

mat.PC  = struct("E",E_pol,"nu",nu_pol);
mat.PLA = struct("E",E_PLA,"nu",nu_PLA);

% --------- Importación ----------
carpetas = {"Orificio FA", "Orificio central", "Entalla lateral"};

for i = 1:numel(carpetas)
    archivos = dir(fullfile(carpetas{i}, "00*.mat"));
    [~, idx] = sort({archivos.name}); archivos = archivos(idx);

    nombre = matlab.lang.makeValidName(carpetas{i});
    datos.(nombre).files = {archivos.name};
    datos.(nombre).S = cell(numel(archivos),1);

    for k = 1:numel(archivos)
        datos.(nombre).S{k} = importdata(fullfile(archivos(k).folder, archivos(k).name));
    end
end

% --------- Procesado + export ----------
% 1) EntallaLateral (PC)
stress_EntLat = lame_stress(datos.EntallaLateral.S, mat.PC);
export_maps_sigma_x(stress_EntLat, "maps_EntallaLateral_x", [0 3.5e6]);

% 2) OrificioCentral (PC)
stress_OrCent = lame_stress(datos.OrificioCentral.S, mat.PC);
export_maps_sigma_x(stress_OrCent, "maps_OrificioCentral_x", [0 3.5e6]);

% 3) OrificioFA (PLA)
stress_OrFA = lame_stress(datos.OrificioFA.S, mat.PLA);
export_maps_sigma_x(stress_OrFA, "maps_OrificioFA_x", [0 5e6]);




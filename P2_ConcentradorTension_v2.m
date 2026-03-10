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
export_maps_sigma_y(stress_EntLat, "maps_EntallaLateral_y", [0 9e6]);

% 2) OrificioCentral (PC)
stress_OrCent = lame_stress(datos.OrificioCentral.S, mat.PC);
export_maps_sigma_y(stress_OrCent, "maps_OrificioCentral_y", [0 9e6]);

% 3) OrificioFA (PLA)
stress_OrFA = lame_stress(datos.OrificioFA.S, mat.PLA);
export_maps_sigma_y(stress_OrFA, "maps_OrificioFA_y", [0 3e7]);

%4) CORTE EN DONDE EXISTE LA TENSION MÁXIMA

CorteFibraDemanda( ...
    stress_EntLat, 6, ...
    "mapa_EntLat_0006.png", ...
    "perfil_EntLat_0006.png", ...
    [0 9], 125, 1e6, "MPa")

CorteFibraDemanda( ...
    stress_OrCent, 6, ...
    "mapa_OrCent_0006.png", ...
    "perfil_OrCent_0006.png", ...
    [0 9], 140, 1e6, "MPa")

CorteFibraDemanda( ...
    stress_OrFA, 5, ...
    "mapa_OrFA_0005.png", ...
    "perfil_OrFA_0005.png", ...
    [0 30], 86, 1e6, "MPa")
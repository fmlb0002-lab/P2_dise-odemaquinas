function CorteFibraDemanda(stress, estado, outname_mapa, outname_perfil, valores, fila, escala, unidad)
% CorteFibraDemanda
% ------------------------------------------------------------
% Genera 2 imágenes separadas para un estado concreto:
%   1) mapa de tensiones sigma_x con la fibra marcada
%   2) gráfico del perfil de la fibra
%
% ENTRADAS:
%   stress         : cell array de structs, donde stress{k}.sx es la matriz
%   estado         : índice del estado a representar (ej. 6)
%   outname_mapa   : nombre del archivo del mapa
%   outname_perfil : nombre del archivo del perfil
%   valores        : límites de color [min max]
%   fila           : número de fila o "auto"
%   escala         : 1 si está en la unidad final, 1e6 si Pa -> MPa
%   unidad         : "Pa" o "MPa"
%
% EJEMPLO:
% CorteFibraDemanda(stress_EntLat, 6, ...
%    "mapa_EntLat_0006.png", "perfil_EntLat_0006.png", ...
%    [0 3.5], 125, 1e6, "MPa")

    if nargin < 5 || isempty(valores)
        error('Debes indicar "valores", por ejemplo [0 3.5].');
    end
    if nargin < 6 || isempty(fila)
        fila = "auto";
    end
    if nargin < 7 || isempty(escala)
        escala = 1;
    end
    if nargin < 8 || isempty(unidad)
        unidad = "Pa";
    end

    if estado < 1 || estado > numel(stress)
        error('El estado seleccionado está fuera de rango.');
    end

    sy = stress{estado}.sy / escala;

    % -------------------------------
    % Selección de fila
    % -------------------------------
    if ischar(fila) || isstring(fila)
        if strcmpi(string(fila), "auto")
            max_fila = max(sy, [], 2, "omitnan");
            [~, fila_k] = max(max_fila);
        else
            error('El argumento "fila" como texto solo admite "auto".');
        end
    elseif isnumeric(fila) && isscalar(fila)
        fila_k = round(fila);
    else
        error('El argumento "fila" debe ser un número o "auto".');
    end

    fila_k = max(1, min(size(sy,1), fila_k));
    perfil = sy(fila_k, :);
    x = 1:size(sy,2);

    % =========================================================
    % 1) MAPA DE TENSIONES
    % =========================================================
    fig1 = figure("Color","w");
    imagesc(sy)
    caxis(valores)
    colormap("turbo")
    axis image
    hold on
    plot([1 size(sy,2)], [fila_k fila_k], "w-", "LineWidth", 2)
    hold off

    cb = colorbar;
    cb.Color = "k";
    set(gca,"XColor","k","YColor","k");

    t = title(sprintf('\\sigma_y (%s) - Estado %04d', unidad, estado));
    t.Color = "k";

    exportgraphics(fig1, outname_mapa, "Resolution", 300);
    close(fig1)

    % =========================================================
    % 2) PERFIL DE LA FIBRA
    % =========================================================
    fig2 = figure("Color","w");
    plot(x, perfil, "k-", "LineWidth", 1.8)
    grid on
    set(gca,"Color","w","XColor","k","YColor","k")

    xlabel("Columna", "Color","k")
    ylabel(sprintf('\\sigma_x (%s)', unidad), "Color","k")

    t = title(sprintf('Perfil de \\sigma_x en la fila %d - Estado %04d', fila_k, estado));
    t.Color = "k";

    exportgraphics(fig2, outname_perfil, "Resolution", 300);
    close(fig2)
end
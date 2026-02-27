function export_quiver_displacement(S, outdir, step, thr)
    if ~exist(outdir,"dir"); mkdir(outdir); end
    n = numel(S);

    % ===== 1) Escala GLOBAL para exagerar flechas de forma consistente =====
    maxAll = 0;
    rangeAll = 0;

    for k = 1:n
        R = S{k};
        valid = R.sigma > thr;

        U = R.u; V = R.v;
        U(~valid) = NaN; V(~valid) = NaN;

        Umag = sqrt(U.^2 + V.^2);
        maxAll = max(maxAll, max(Umag, [], "all", "omitnan"));

        rangeX = max(R.x,[],"all") - min(R.x,[],"all");
        rangeY = max(R.y,[],"all") - min(R.y,[],"all");
        rangeAll = max(rangeAll, max(rangeX, rangeY));
    end

    % Si todo es cero/NaN (p.ej. estado inicial), evita división por cero
    if ~isfinite(maxAll) || maxAll <= 0
        maxAll = 1;
    end

    % Flecha máxima ~3% del tamaño del campo
    Ldes = 0.09 * rangeAll;
    if ~isfinite(Ldes) || Ldes <= 0
        Ldes = 1;
    end
    amp  = Ldes / maxAll;   % factor de exageración (visual)

    % ===== 2) Exportación por estado =====
    for k = 1:n
        R = S{k};

        X = R.x; Y = R.y;
        U = R.u; V = R.v;

        valid = R.sigma > thr;
        U(~valid) = NaN; V(~valid) = NaN;

        % Fondo: magnitud de desplazamiento
        Umag = sqrt(U.^2 + V.^2);
        Umag(~valid) = NaN;

        % Submuestreo
        Xs = X(1:step:end, 1:step:end);
        Ys = Y(1:step:end, 1:step:end);
        Us = U(1:step:end, 1:step:end) * amp;   % exageración
        Vs = V(1:step:end, 1:step:end) * amp;

        fig = figure("Color","w");
        ax  = axes(fig);
        set(ax,"Color","w","XColor","k","YColor","k");
        hold(ax,"on")

        % Fondo claro (magnitud)
        imagesc(ax, X(1,:), Y(:,1), Umag);
        set(ax,"YDir","normal");
        colormap(ax, gray);

        % caxis robusto (evita errores cuando Umag es constante o vacío)
        vals = Umag(isfinite(Umag));
        if isempty(vals)
            cl = [0 1];
        else
            cl = prctile(vals, [2 98]);
            if any(~isfinite(cl)) || cl(1) >= cl(2)
                cl = [min(vals) max(vals)];
                if cl(1) >= cl(2)
                    cl = [cl(1) cl(1)+eps];
                end
            end
        end
        caxis(ax, cl);

        axis(ax,"image"); axis(ax,"tight");

        % Flechas (negras y visibles)
        q = quiver(ax, Xs, Ys, Us, Vs, 0, "k");
        q.LineWidth   = 1.2;
        q.MaxHeadSize = 2.5;

        title(ax, sprintf("Campo (u,v) - Estado %04d", k), "Color","k");
        xlabel(ax,"x"); ylabel(ax,"y");
        set(ax,"FontSize",14,"LineWidth",1,"Box","on","TickDir","out");

        fname = fullfile(outdir, sprintf("quiver_%04d.png", k));
        exportgraphics(fig, fname, "Resolution", 300);
        close(fig)
    end
end
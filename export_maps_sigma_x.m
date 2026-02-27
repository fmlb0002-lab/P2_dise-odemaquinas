function export_maps_sigma_x(stress, outdir, valores)
    if ~exist(outdir,"dir"); mkdir(outdir); end

    n = numel(stress);
    for k = 1:n
        sx = stress{k}.sx;

        fig = figure("Color","w");
        imagesc(sx)
        caxis(valores)
        colormap("turbo")
        axis image

        cb = colorbar; cb.Color = "k";
        set(gca,"XColor","k","YColor","k");

        t = title(sprintf('\\sigma_x (MPa) - Estado %04d', k));
        t.Color = "k";

        fname = fullfile(outdir, sprintf("sigma_x_%04d.png", k));
        exportgraphics(fig, fname, "Resolution", 300);
        close(fig)
    end
end
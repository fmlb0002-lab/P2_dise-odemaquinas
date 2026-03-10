function export_maps_sigma_y(stress, outdir, valores)
    if ~exist(outdir,"dir"); mkdir(outdir); end

    n = numel(stress);
    for k = 1:n
        sy = stress{k}.sy;

        fig = figure("Color","w");
        imagesc(sy)
        caxis(valores)
        colormap("turbo")
        axis image

        cb = colorbar; cb.Color = "k";
        set(gca,"XColor","k","YColor","k");

        t = title(sprintf('\\sigma_y (MPa) - Estado %04d', k));
        t.Color = "k";

        fname = fullfile(outdir, sprintf("sigma_y_%04d.png", k));
        exportgraphics(fig, fname, "Resolution", 300);
        close(fig)
    end
end
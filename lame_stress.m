function stress = lame_stress(S, mat)
    E  = mat.E;
    nu = mat.nu;

    mu = E/(2*(1+nu));
    c  = E/(1-nu^2);

    n = numel(S);
    stress = cell(1,n);

    for k = 1:n
        R = S{k};

        exx = R.exx;  eyy = R.eyy;  exy = R.exy;

        sx  = c*(exx + nu*eyy);
        sy  = c*(eyy + nu*exx);
        txy = 2*mu*exy;

        stress{k} = struct("sx",sx,"sy",sy,"txy",txy);
    end
end
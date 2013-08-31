function [Lx,Ly,Lxx,Lxy,Lyy,hx,hy,hxx,hxy,hyy]=imderivgauss_anisotropic(I,sigma)
    % ISOPHOTE_CALCULATION2 Calculate the isophotes and their curvature,
    %   curvedness, target displacement coordinates/pixels/indices, 
    %   displacement vectors and radius
    %
    %   This implementation uses anisotropic Gauss filtering instead of
    %   Matlab's built-in filter operation.
    %
    % @author B. Schauerte
    % @date 2011
    %
    % Copyright (C) Boris Schauerte - All Rights Reserved
    % Unauthorized copying of this file, via any medium is strictly prohibited
    % Proprietary and confidential
    % Written by Boris Schauerte <schauerte@ieee.org>, 2011
    
    % parameters
    if nargin < 2
        sigma = 1;
    end
    
    phi=0;
    Lx  =  anigauss(I,sigma,sigma,phi,0,1);
    Ly  = -anigauss(I,sigma,sigma,phi,1,0);
    Lxx =  anigauss(I,sigma,sigma,phi,0,2);
    Lyy =  anigauss(I,sigma,sigma,phi,2,0);
    Lxy = -anigauss(I,sigma,sigma,phi,1,1);
    %Lx  = anigauss(I,sigma,sigma,phi,0,1);
    %Ly  = anigauss(I,sigma,sigma,phi,1,0);
    %Lxx = anigauss(I,sigma,sigma,phi,0,2);
    %Lyy = anigauss(I,sigma,sigma,phi,2,0);
    %Lxy = anigauss(I,sigma,sigma,phi,1,1);
    %Lx  = anigauss(I,sigma,sigma,phi,1,0);
    %Ly  = anigauss(I,sigma,sigma,phi,0,1);
    %Lxx = anigauss(I,sigma,sigma,phi,2,0);
    %Lyy = anigauss(I,sigma,sigma,phi,0,2);
    %Lxy = anigauss(I,sigma,sigma,phi,1,1);
    hx  = 0;
    hy  = 0;
    hxx = 0;
    hyy = 0;
    hxy = 0;
    
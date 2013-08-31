function [Lx,Ly,Lxx,Lxy,Lyy]=imderiv2(I)
    % IMDERIV2 calculates 1st and 2nd order image derivatives
    %
    % Simplest implementation, see http://en.wikipedia.org/wiki/Edge_detection#Differential_edge_detection
    %
    % @author B. Schauerte
    % @date   2011
    %
    % Copyright (C) Boris Schauerte - All Rights Reserved
    % Unauthorized copying of this file, via any medium is strictly prohibited
    % Proprietary and confidential
    % Written by Boris Schauerte <schauerte@ieee.org>, 2011
    
    hLx=[-0.5 0 0.5];
    %hLy=[0.5; 0; -0.5];
    hLy=[-0.5; 0; 0.5];
    hLxx=[1 -2 1];
    %hLxy=[-1/4 0 1/4; 0 0 0; 1/4 0 -1/4]; % i.e. hLy x hLx
    hLxy=-[-1/4 0 1/4; 0 0 0; 1/4 0 -1/4]; % i.e. hLy x hLx
    hLyy=[1; -2; 1];
    Lx=imfilter(I,hLx);
    Ly=imfilter(I,hLy);
    Lxx=imfilter(I,hLxx);
    Lxy=imfilter(I,hLxy);
    Lyy=imfilter(I,hLyy);
  
%function eval_bioid_isophote_eye_center_detector
  % Evaluate the isophote bases eye center detector on the BioID data set
  %
  % @author Boris Schauerte
  % @email  boris.schauerte@eyezag.com
  % @date   2011
  %
  % Copyright (C) 2011  Boris Schauerte
  % 
  % This program is free software: you can redistribute it and/or modify
  % it under the terms of the GNU General Public License as published by
  % the Free Software Foundation, either version 3 of the License, or
  % (at your option) any later version.
  %
  % This program is distributed in the hope that it will be useful,
  % but WITHOUT ANY WARRANTY; without even the implied warranty of
  % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  % GNU General Public License for more details.
  %
  % You should have received a copy of the GNU General Public License
  % along with this program.  If not, see <http://www.gnu.org/licenses/>.

  if ~exist('progressbar','file'), addpath(genpath('../libs/progressbar/')); end
  
  if not(isunix)
    data_bioid_path='C:\Users\Boris\Desktop\data\BioID';%'/cvhci/data/face/BioID'
  else
    data_bioid_path='/cvhci/data/face/BioID';
  end
  data_bioid_nsamples=1520; % number of samples that we want to use for eval
  
  % parameters
  gsigma = 0.65; %1;%0.70;%1; % the sigma (std. dev.) for the Gaussian derivatives
  %gsigma = 3; %1;%0.70;%1; % the sigma (std. dev.) for the Gaussian derivatives
  %ewx=36; ewy=26; % crop window size
  ewx=40; ewy=30; % crop window size
  %ewx=64; ewy=48; % crop window size
  
  % results
  tndl = zeros(data_bioid_nsamples,1); % table of normalized left eye center detection distances
  tndr = zeros(data_bioid_nsamples,1); % table of normalized right eye center detection distances
  
  % some statistics of the data set
  tiod = zeros(data_bioid_nsamples,1); % table of interocular distances, i.e. distance between the eyes
  
  progressbar;
  for data_bioid_sample=1:data_bioid_nsamples
    % load image
    img=uint8(readpgm([data_bioid_path '/images/BioID_' sprintf('%04d',data_bioid_sample) '.pgm']));
    
    % read annotations
    [elx,ely,erx,ery]=read_bioid_eye([data_bioid_path '/metadata/BioID_' sprintf('%04d',data_bioid_sample) '.eye']);
    el=[elx ely];
    er=[erx ery];
    
    % crop the eye regions
    hewx=floor(ewx/2); hewy=floor(ewy/2);
    signs=[-1 +1];
    calx = (elx-hewx+1+randi(5)*signs(randi(2))); % crop anchor point for the left eye
    caly = (ely-hewy+1+randi(5)*signs(randi(2))); % crop anchor point for the left eye
    carx = (erx-hewx+1+randi(5)*signs(randi(2))); % crop anchor point for the right eye
    cary = (ery-hewy+1+randi(5)*signs(randi(2))); % crop anchor point for the right eye
    calx = max(calx,1);
    caly = max(caly,1);
    carx = max(carx,1);
    cary = max(cary,1);
    img_left_eye=img(caly:(caly+ewy-1),calx:(calx+ewx-1)); % crop left eye
    img_right_eye=img(cary:(cary+ewy-1),carx:(carx+ewx-1)); % crop right eye
    
    % run isophote eye center detection
    %[lecx lecy]=run_isophote_eye_detector2(img,img_left_eye,[calx caly (calx+ewx-1) (caly+ewy-1)],gsigma);
    %[recx recy]=run_isophote_eye_detector2(img,img_right_eye,[carx cary (carx+ewx-1) (cary+ewy-1)],gsigma);
    [lecx,lecy,~,~,~,~,lsacc]=run_isophote_eye_detector(img_left_eye,gsigma);
    [recx recy,~,~,~,~,rsacc]=run_isophote_eye_detector(img_right_eye,gsigma);
    % calculate the absolute position of the eye center detection in the image
    lec=[(lecx + (calx - 1)) (lecy + (caly - 1))];
    rec=[(recx + (carx - 1)) (recy + (cary - 1))];
    % @todo: check whether or not there is a bug (misunderstanding of the
    %        indices, because -2 gives considerably better results)
    %lec=[(lecx + (calx - 2)) (lecy + (caly - 2))];
    %rec=[(recx + (carx - 2)) (recy + (cary - 2))];
    
    % calculate evaluation measures
    ed = norm(el - er);  % distance beween the eyes (for normalization); aka interocular distance
    dl = norm(el - lec); % distance between ground truth and detection
    dr = norm(er - rec); % distance between ground truth and detection
    
    % interocular distance
    tiod(data_bioid_sample) = ed;
    
    tndl(data_bioid_sample) = dl / ed; % normalize distance
    tndr(data_bioid_sample) = dr / ed; % normalize distance

    % display some examples
    if mod(data_bioid_sample-1,100)==0
      if isempty(figh_eye)
        figh_eye=figure('name','image'); 
      end
      figure(figh_eye);
      subplot(2,3,1); subimage(img); 
      hold on; 
      plot(elx,ely,'gx','MarkerSize',10,'LineWidth',1); plot(erx,ery,'gx','MarkerSize',10,'LineWidth',1); 
      plot(lec(1),lec(2),'rx','MarkerSize',10,'LineWidth',1); plot(rec(1),rec(2),'rx','MarkerSize',10,'LineWidth',1);
      hold off;
      subplot(2,3,2); subimage(mat2gray(img_left_eye)); hold on; plot(lecx,lecy,'rx','MarkerSize',10,'LineWidth',1); hold off;
      subplot(2,3,3); subimage(mat2gray(img_right_eye)); hold on; plot(recx,recy,'rx','MarkerSize',10,'LineWidth',1); hold off;
      subplot(2,3,5); subimage(mat2gray(lsacc));
      subplot(2,3,6); subimage(mat2gray(rsacc));
    end
    
    progressbar(data_bioid_sample/data_bioid_nsamples);
  end
  
  % plot accuracy
  es = [0:0.01:0.3];
  accl=zeros(2,numel(es));
  accr=zeros(2,numel(es));
  accb=zeros(2,numel(es));
  accw=zeros(2,numel(es));
  accl(1,:) = es;
  accr(1,:) = es;
  accb(1,:) = es;
  accw(1,:) = es;
  for i=1:numel(es)
    accl(2,i) = numel(find(tndl <= es(i))) / data_bioid_nsamples;
    accr(2,i) = numel(find(tndr <= es(i))) / data_bioid_nsamples;
    accb(2,i) = numel(find(min(tndr,tndl) <= es(i))) / data_bioid_nsamples;
    accw(2,i) = numel(find(max(tndr,tndl) <= es(i))) / data_bioid_nsamples;
  end
  acca=(accl + accr) / 2; % average eye accuracy
  
  % plot the accuracy
  figure('name','accuracy');
  hold on;
  plot(accb(1,:),accb(2,:),'g')
  plot(accw(1,:),accw(2,:),'r')
  plot(acca(1,:),acca(2,:),'k')
  plot(accl(1,:),accl(2,:),'c')
  plot(accr(1,:),accr(2,:),'m')
  
  % short summary of evaluation results
  fprintf('%0.02f: b=%0.03f a=%0.03f w=%0.03f  l=%0.03f r=%0.03f\n',accb(1,6),accb(2,6),acca(2,6),accw(2,6),accl(2,6),accr(2,6))
  fprintf('%0.02f: b=%0.03f a=%0.03f w=%0.03f  l=%0.03f r=%0.03f\n',accb(1,11),accb(2,11),acca(2,11),accw(2,11),accl(2,11),accr(2,11))
  fprintf('%0.02f: b=%0.03f a=%0.03f w=%0.03f  l=%0.03f r=%0.03f\n',accb(1,16),accb(2,16),acca(2,16),accw(2,16),accl(2,16),accr(2,16))
  fprintf('%0.02f: b=%0.03f a=%0.03f w=%0.03f  l=%0.03f r=%0.03f\n',accb(1,26),accb(2,26),acca(2,26),accw(2,26),accl(2,26),accr(2,26))
  
  % short summary of data set statistics/characteristics
  %fprintf('Interocular distance: min= %f mean=%f max=%f\n',min(tiod(:)),mean(tiod(:)),max(tiod(:)));
  %figure; plot(sort(tiod));
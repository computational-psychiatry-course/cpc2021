%
% [Sin,SNin] = Sin_vsh_ctf(r_sphere,R,EX,EY,EZ,Lin)
%
% Calculate the internal SSS basis Sin for a CTF system
% using vector spherical harmonics
%
function [Sin,SNin] = Sin_vsh_ctf(r_sphere,R,EX,EY,EZ,Lin)
% Copyright (c) 2016, Elekta Oy
% ---------------------------------------
% 
% Redistribution and use of the Software in source and binary forms, with or without 
% modification, are permitted for non-commercial use.
% 
% The Software is provided "as is" without warranties of any kind, either express or
% implied including, without limitation, warranties that the Software is free of defects,
% merchantable, fit for a particular purpose. Developer/user agrees to bear the entire risk 
% in connection with its use and distribution of any and all parts of the Software under this license.
% 
mu0 = 1.25664e-6; % Permeability of vacuum
%
% For numerical surface integration:
%
%baseline = 50e-3;
dx = 4.5e-3;
dy = 4.5e-3;
dz1 = 0;
dz2 = 50e-3;
D = [dx dy dz1; dx -dy dz1; -dx dy dz1; -dx -dy dz1; dx dy dz2; dx -dy dz2; -dx dy dz2; -dx -dy dz2]';
for j = 1:8
   if j <= 4
      weights(j) = 1/(4*1);
   else
      weights(j) = -1/(4*1);
   end
end
weights = weights';

for ch = 1:size(R,2)
   disp(ch)
   count = 1;
   R(:,ch) = R(:,ch) - r_sphere;
   for l = 1:Lin
      for m = -l:l
	 Sin(ch,count) = -mu0*vsh_response(R(:,ch),EX(:,ch),EY(:,ch),EZ(:,ch),D,weights,l,m);
	 count = count + 1;
      end
   end
end
for j = 1:size(Sin,2)
   SNin(:,j) = Sin(:,j)/norm(Sin(:,j));
end


function Sin_element = vsh_response(r,ex,ey,ez,D,weights,l,m)

for j = 1:length(weights)
   r_this = r + D(1,j)*ex + D(2,j)*ey + D(3,j)*ez;
   rn = norm(r_this);
   theta = acos(r_this(3)/rn);
   phi = atan2(r_this(2),r_this(1));
   sint = sin(theta);
   sinp = sin(phi);
   cost = cos(theta);
   cosp = cos(phi);
   vs = vsh_modified_in(theta,phi,l,m)'/rn^(l+2);
   V(1,j) = vs(1)*sint*cosp + vs(2)*cost*cosp - vs(3)*sinp;
   V(2,j) = vs(1)*sint*sinp + vs(2)*cost*sinp + vs(3)*cosp;
   V(3,j) = vs(1)*cost - vs(2)*sint;
end
Sin_element = dot(V*weights,ez); % Cartesian coordinates
%Sin_element = Sin_element/sqrt((l+1)*(2*l+1));  % Back to orthonormal presentation



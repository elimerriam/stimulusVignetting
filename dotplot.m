% dotplot.m
%
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%      usage: dotplot(x,y,c,a,r);
%         by: eli merriam
%       date: 05/13/09
%    purpose: x and y coordinates, color, alpha, size
%        $Id: dotplot.m,v 1.3 2017/11/22  zvi

function h = dotplot(x,y,c,a,r);

% check arguments
if ~any(nargin == [5])
  help dotplot
  return
end

% check the size of the inputs
ndots = size(x,1);
if ~(size(y,1)==ndots & size(c,1)==ndots & size(a,1)==ndots)
  disp('all input vectors must be the same length!')
end

% define a dot of a given radius
% r = 3;
nslices = 72;
ndots = length(x);

th = linspace(-pi,pi,nslices);
r = repmat(r, nslices, 1);
[xDot, yDot] = pol2cart(th',r);


xDot = repmat(xDot, 1,length(x)) + repmat(x(:)', nslices, 1);
yDot = repmat(yDot, 1,length(y)) + repmat(y(:)', nslices, 1);

c = reshape(repmat(c(:)', nslices,1), nslices*ndots,1);
a = reshape(repmat(a(:)', nslices,1), nslices*ndots,1);

h = patch(xDot, yDot, 1);
f = get(h, 'faces');
v = get(h, 'vertices');
cla

h=patch('vertices', v, 'faces', f, 'facevertexcdata', c, 'facevertexalphadata', a, 'facecolor', 'interp', 'facealpha', 'interp', 'edgecolor', 'none');
axis equal;



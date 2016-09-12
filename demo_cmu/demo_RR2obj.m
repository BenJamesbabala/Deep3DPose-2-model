

clear
clc

%%
% prepare data
addpath('../prepare/mesh/skel/');
addpath('../prepare/mesh/quatern/');

addpath('../prepare/mesh2/io/');

% male!
addpath(genpath('../prepare/scape/MATLAB_daz_m_srf'));

% generate textured model

Meta.instance.readA;
Meta.instance.readPCA;

% ponints weights
weights = Meta.instance.weight;
[weights_sort, ind] = sort(weights, 2);

% triangles = Meta.instance.triangles;
triangles = load('../prepare/mesh2/data/facespoints.txt');

% Be careful!!! Here faces of textured models is
% different from original models!!!

%%
% textured models

textures = load('../prepare/mesh2/data/textures.txt');
facespoints = load('../prepare/mesh2/data/facespoints.txt');
facestextures = load('../prepare/mesh2/data/facestextures.txt');

% besides points, the textured obj file has below content
% vt
restfiles = '';
for skel_id = 1:7025
    restfiles = sprintf('%svt %f %f\n', restfiles, textures(skel_id, :));
end

% mtl
restfiles = sprintf('%s%s\n', restfiles, 'usemtl Material');

% face
for skel_id = 1:12894
    restfiles = sprintf('%sf %d/%d %d/%d %d/%d\n', restfiles,...
        facespoints(skel_id, 1), facestextures(skel_id, 1),...
        facespoints(skel_id, 2), facestextures(skel_id, 2),...
        facespoints(skel_id, 3), facestextures(skel_id, 3)...
        );
end

%%
% shape
% it is a 12 dim vector. You can set your own parameters
% you can
shapepara = Meta.instance.sem_default;

%%
% load

load cmu_RR

sknum = size(jointsRR, 4);

%%
% RR2obj

objfolder = '../results';
texturefolder = '../textures';

for skel_id = 1:100:sknum
    
    % skel_id = randi(sknum);
    
    RR = jointsRR(:, :, 1:15, skel_id);
    R = jointsRR(:, :, 16, skel_id);
    
    % generate points
    points = Body(RR, shapepara).points;
    
    % rot to original pose
    p = R'*points';
    p = 0.5*p;
    
    points = p';
    points = moveToCenter(weights, points, 2);
    p = points';
    
    generate_blender( p, restfiles,...
        objfolder, [num2str(skel_id)],...
        texturefolder, randi(3));
end



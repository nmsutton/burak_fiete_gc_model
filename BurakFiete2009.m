% Burak and Fiete 2009's continuous attractor model
% Eric Zilli - 20110812 - v1.0
% Updates by Nate Sutton 2022

simdur = 100e3; % total simulation time, ms
ncells = 30*30; % total number of cells in network
tau = 10; %% Cell parameters % grid cell synapse time constant, ms
t = 0; % simulation time variable, ms
load('data/W_Bu09_torus_n900_l2.mat'); % load weight matrix
load('data/B_saved.mat'); % velocity input matrix
%gc_firing = 1-floor(rand(1,ncells)*2); %% Initial conditions % activation of each cell
%gc_firing = floor(rand(1,ncells)*4);
%gc_firing = rand(1,ncells);
load('data/gc_firing_init.mat'); % initial gc firing
mex_hat = W;%W*5;
% filter out weights of neurons not matching example preferred direction
if true
    max_ind = sqrt(size(W(:,1)));
    for x = 1:max_ind
        for y = 1:max_ind
            ind = ((y-1) * max_ind) + x;
            if (get_pd(x,y) ~= 'r')                
                %mex_hat(:,ind) = .1;
                mex_hat(:,ind) = 0;
                %B(ind) = 1;
                B(ind) = 1;
            else
                B(ind) = 1.01;
            end
        end
    end
end

% plotting
spikeThresh = 0.1; % threshold for plotting a cell as having spiked
livePlot = 40;
watchCell = ncells/2-sqrt(ncells)/2; %% Firing field plot variables % which cell's spatial activity will be plotted?
nSpatialBins = 60;
minx = -0.90; maxx = 0.90; % m
miny = -0.90; maxy = 0.90; % m
occupancy = zeros(nSpatialBins);
spikes = zeros(nSpatialBins);
spikeCoords = [];
h = figure('color','w','name','Activity of sheet of cells on brain''s surface'); %% Make optional figure of sheet of activity
drawnow

fprintf('Simulation starting. Press ctrl+c to end...\n') %% Simulation
while t<simdur
  t = t+1;

  scl_gc_in = 2.1;%0.5; % scale gc input
  in_firing = ((mex_hat*2.5)*(gc_firing*scl_gc_in)')';
  %in_firing = round(in_firing*1000)/1000; % round for carlsim
  %in_firing = round(in_firing*500)/500; % round for carlsim
  %ex_firing = ones(1,900)*1;
  %ex_firing = 4-(8-(B*7));%*.5;
  %ex_firing = B*50;
  ex_firing = B*.2;
  %ex_firing = round(ex_firing*1000)/1000; % round for carlsim
  %ex_firing = round(ex_firing*10)/10; % round for carlsim
  new_firing = in_firing + ex_firing;
  new_firing = new_firing.*(new_firing>0);
  gc_firing = gc_firing + (new_firing - gc_firing)/tau;
  %gc_firing = round(gc_firing*10)/10; % round for carlsim
  %gc_firing = round(gc_firing*1000)/1000; % round for carlsim
  %gc_firing = round(gc_firing*500)/500; % round for carlsim

  % plotting
  custom_colormap = load('neuron_space_colormap.mat');
  if livePlot>0 && (livePlot==1 || mod(t,livePlot)==1)
    figure(h); ax(1) = subplot(131);
    imagesc(reshape(gc_firing,sqrt(ncells),sqrt(ncells)));
    colormap(ax(1),custom_colormap.CustomColormap2);
    axis square
    title({sprintf('t = %.1f ms',t),'Population activity'})
    set(gca,'ydir','normal')
    cb = colorbar;
    drawnow
  end
end

% command to view matrices
% gc_firing_reshaped = reshape(gc_firing,30,30);in_firing_reshaped = reshape(in_firing,30,30);ex_firing_reshaped = reshape(ex_firing,30,30);new_firing_reshaped = reshape(new_firing,30,30);

function pd = get_pd(x, y)
    % find neuron preferred direction
	if (mod(y,2) == 0)
		if (mod(x,2) == 0)
			pd = 'd';
		else 
			pd = 'r';
        end
    else
		if (mod(x,2) == 0)
			pd = 'l';
        else
			pd = 'u';	
        end
    end
end
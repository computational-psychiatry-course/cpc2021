function [VOLLOCS, LOCS, verbose] = ...
    tapas_physio_create_scan_timing_from_gradients_philips(log_files, ...
    scan_timing, verbose)
% Extracts slice and volume scan events from gradients timecourse of Philips
% SCANPHYSLOG file
%
%   [VOLLOCS, LOCS] = ...
%   tapas_physio_create_scan_timing_from_gradients_philips(logfile,
%       scan_timing, verbose);
%
% IN
%   log_files   is a structure containing the following filenames (with full
%           path)
%       .log_cardiac        contains ECG or pulse oximeter time course
%                           for Philips: 'SCANPHYSLOG<DATE&TIME>.log';
%                           can be found on scanner in G:/log/scanphyslog-
%                           directory, one file is created per scan, make sure to take
%                           the one with the time stamp corresponding to your PAR/REC
%                           files
%       .log_respiration    contains breathing belt amplitude time course
%                           for Philips: same as .log_cardiac
%
%   scan_timing  - 
%   Parameters for sequence timing & synchronization
%   scan_tming.sqpar =    slice and volume acquisition starts, TR,
%                       number of scans etc.
%   scan_timing.sync =    synchronize phys logfile to scan acquisition
%
%       sync             gradient amplitude thresholds to detect slice and volume events
%
%           sync is a structure with the following elements
%           .zero    - gradient values below this value are set to zero;
%                      should be those which are unrelated to slice acquisition start
%           .slice   - minimum gradient amplitude to be exceeded when a slice
%                      scan starts
%           .vol     - minimum gradient amplitude to be exceeded when a new
%                      volume scan starts;
%                      leave [], if volume events shall be determined as
%                      every Nslices-th scan event
%           .grad_direction
%                    - leave empty to use nominal timing;
%                      if set, sequence timing is calculated from logged gradient timecourse;
%                    - value determines which gradient direction timecourse is used to
%                      identify scan volume/slice start events ('x', 'y', 'z')
%           .vol_spacing
%                   -  duration (in seconds) from last slice acq to
%                      first slice of next volume;
%                      leave [], if .vol-threshold shall be used
%
%       sqpar                   - sequence timing parameters
%           .Nslices        - number of slices per volume in fMRI scan
%           .TR             - repetition time in seconds
%           .Ndummies       - number of dummy volumes
%           .Nscans         - number of full volumes saved (volumes in nifti file,
%                             usually rows in your design matrix)
%           .Nprep          - number of non-dummy, volume like preparation pulses
%                             before 1st dummy scan. If set, logfile is read from beginning,
%                             otherwise volumes are counted from last detected volume in the logfile
%           .time_slice_to_slice - time between the acquisition of 2 subsequent
%                             slices; typically TR/Nslices or
%                             minTR/Nslices, if minimal temporal slice
%                             spacing was chosen
%            onset_slice    - slice whose scan onset determines the adjustment of the
%                             regressor timing to a particular slice for the whole volume
%
%                             NOTE: only necessary, if sync.grad_direction is empty
%   verbose
%
% OUT
%           VOLLOCS         - locations in time vector, when volume scan
%                             events started
%           LOCS            - locations in time vector, when slice or volume scan
%                             events started
%
% EXAMPLE
%   [VOLLOCS, LOCS, verbose] = tapas_physio_create_scan_timing_from_gradients_philips(logfile,
%   scan_timing, verbose);
%
%   See also

% Author: Lars Kasper
% Created: 2013-02-16
% Copyright (C) 2013 Institute for Biomedical Engineering, ETH/Uni Zurich.
%
% This file is part of the PhysIO toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.


sqpar   = scan_timing.sqpar;
sync    = scan_timing.sync;

% smaller than typical single shot EPI slice duration (including waiting
% for TE)
minSliceDuration = 0.040; 

doDetectVolumesByCounting           = (~isfield(sync, 'vol') || ...
    isempty(sync.vol)) && (~isfield(sync, 'vol_spacing') || ...
    isempty(sync.vol_spacing));
doDetectVolumesByGradientAmplitude  = ~doDetectVolumesByCounting && ...
    (~isfield(sync, 'vol_spacing') || isempty(sync.vol_spacing));
doCountSliceEventsFromLogfileStart  = ...
    strcmpi(log_files.align_scan, 'first');


%% check consistency of sync-values

if sync.slice <= sync.zero
    verbose = tapas_physio_log('Please set sync.scan_timing.slice > sync.scan_timing.zero', ...
        verbose, 2);
end

if doDetectVolumesByGradientAmplitude && (sync.slice > sync.vol)
    verbose = tapas_physio_log('Please set sync.scan_timing.vol > sync.scan_timing.slice', ...
        verbose, 2);
end



% everything stored in 1 logfile
if ~isfield(log_files, 'cardiac') || isempty(log_files.cardiac)
    logfile = log_files.respiration;
else
    logfile = log_files.cardiac;
end

Nscans          = sqpar.Nscans;
Ndummies        = sqpar.Ndummies;
Nslices         = sqpar.Nslices;


if doCountSliceEventsFromLogfileStart
    Nprep = sqpar.Nprep;
end

y = tapas_physio_read_physlogfiles_philips_matrix(logfile);

acq_codes   = y(:,10);
nSamples    = size(y,1);

dt          = log_files.sampling_interval(1);

%default: 500 Hz sampling frequency
if isempty(dt)
    dt      = 2e-3;
end

t           = -log_files.relative_start_acquisition + ((0:(nSamples-1))*dt)';



% finding scan volume starts (svolpulse)
switch lower(sync.grad_direction)
    case 'x'
        gradient_choice = y(:,7);
    case 'y'
        gradient_choice = y(:,8);
    case 'z'
        gradient_choice = y(:,9);
    case {'xyz', 'abs'}
        gradient_choice = sqrt(sum(y(:,7:9).^2,2));
end
gradient_choice         = reshape(gradient_choice, [] ,1);

% For new Ingenia log-files, recorded gradient strength may change after a
% certain time and introduce steps that are bad for recording

minStepDistanceSamples = ceil(1.5*sqpar.TR/dt);

% Normalize gradients, if thresholds are smaller than 1, i.e. relative
doNormalize = max([sync.slice, sync.vol, sync.zero]) < 1;

[gradient_choice, gainArray, normFactor] = ...
    tapas_physio_rescale_gradient_gain_fluctuations(...
    gradient_choice, minStepDistanceSamples, verbose, 'doNormalize', ...
    doNormalize);



% if no gradient timecourse was recorded in the logfile (due to insufficient
% Philips software keys), return nominal timing instead
if ~any(gradient_choice) % all values zero
    [VOLLOCS, LOCS] = tapas_physio_create_scan_timing_nominal(t, sqpar);
    verbose = tapas_physio_log('No gradient timecourse was logged in the logfile. Using nominal timing from sqpar instead', ...
        verbose, 1);
    return
end

z2 = gradient_choice; z2(z2<sync.zero)=0;
z2 = z2 + 1e-4*rand(size(z2)); % to find double-peaks/plateaus, make them a bit different


[tmp, LOCS]    = tapas_physio_findpeaks(z2,'minpeakheight',sync.slice, ...
    'minpeakdistance', ceil(minSliceDuration/dt));

try
    if doDetectVolumesByCounting
        if doCountSliceEventsFromLogfileStart
            VOLLOCS = LOCS(Nprep*Nslices + ...
                (1:Nslices:(Ndummies+Nscans)*Nslices));
        else % count from end
            VOLLOCS = LOCS((end-(Ndummies+Nscans)*Nslices+1):Nslices:end);
        end
        
    else
        if doDetectVolumesByGradientAmplitude
            [tmp, VOLLOCS] = tapas_physio_findpeaks(z2, ...
                'minpeakheight', sync.vol, ...
                'minpeakdistance', 2*(Nslices-1));
        else %detection via bigger spacing from last to first slice of next volume
            VOLLOCS = LOCS(find((diff(LOCS) > sync.vol_spacing/dt)) + 1);
        end
    end
    LOCS    = reshape(LOCS, [], 1);
    VOLLOCS = reshape(VOLLOCS, [], 1);
catch
    VOLLOCS = [];
end

if verbose.level>=1
    
    % Depict all gradients, raw
    verbose.fig_handles(end+1) = tapas_physio_get_default_fig_params();
    set(gcf,'Name', 'Sync: Thresholding Gradient for slice acq start detection');
    fs(1) = subplot(3,1,1); 
    
    plot(t, sqrt(sum(y(:,7:9).^2,2)), '--k');
    hold all;
    plot(t, y(:,7:9));
    
    
    if ismember(8,acq_codes)
        hold all;
        ampl = max(abs(y(~isinf(y))));
        stem(t, ampl/20*acq_codes);
    end
    
    
    legend('abs(G_x^2+G_y^2+G_z^2)', 'gradient x', 'gradient y', 'gradient z');
    title('Sync: Raw Gradient Time-courses');
    
    % Plot gradient thresholding for slice timing determination
    fs(2) = subplot(3,1,2);
    hp = plot(t,[gradient_choice z2]); hold all;
    hp(end+1) = plot(t, repmat(sync.zero, nSamples, 1));
    hp(end+1) = plot(t, repmat(sync.slice, nSamples, 1));
    lg = {'Chosen gradient for thresholding', ...
        'Gradient with values < sync.zero set to 0', ...
        'sync.zero', 'sync.slice'};
    
    if doDetectVolumesByGradientAmplitude
        hp(end+1) = plot(t, repmat(sync.vol, nSamples, 1));
        lg{end+1} = 'sync.vol';
    end
    title({'Thresholding Gradient for slice acq start detection', '- found scan events -'});
    legend(hp, lg);
    xlabel('t(s)');
    
    % Plot gradient thresholding for slice timing determination
    if ~isempty(VOLLOCS)
        heightStem = median(gradient_choice(VOLLOCS));
        hp(end+1) = stem(t(VOLLOCS), 1.25*heightStem*ones(size(VOLLOCS))); hold all
        lg{end+1} = sprintf('Found volume events (N = %d)', numel(VOLLOCS));
    end
    
    if ~isempty(LOCS)
        heightStem = median(gradient_choice(LOCS));
        hp(end+1) = stem(t(LOCS), heightStem*ones(size(LOCS))); hold all
        lg{end+1} = sprintf('Found slice events (N = %d)', numel(LOCS));
        
        dLocsSecs = diff(LOCS)*dt*1000;
        ymin = tapas_physio_prctile(dLocsSecs, 25);
        ymax = tapas_physio_prctile(dLocsSecs, 99);
        
        fs(3) = subplot(3,1,3);
        plot(t(LOCS(1:end-1)), dLocsSecs); title('duration between scan events - search for bad peaks here!');
        xlabel('t (s)');
        ylabel('t (ms)');
        ylim([0.9*ymin, 1.1*ymax]);
        linkaxes(fs,'x');
        
    end
    subplot(3,1,2);
    legend(hp, lg);
    
end


%% Return error if not enough events flund
% VOLLOCS = find(abs(diff(z2))>sync.vol);
if isempty(VOLLOCS) || isempty(LOCS)
    verbose = tapas_physio_log('No volume start events found, Decrease sync.vol or sync.slice after considering the Thresholding figure', ...
        verbose, 2);
elseif length(LOCS) < Nslices
    verbose = tapas_physio_log('Too few slice start events found. Decrease sync.slice after considering the Thresholding figure', ...
        verbose, 2);
end

if doCountSliceEventsFromLogfileStart
    if length(VOLLOCS)< (Nprep+Nscans+Ndummies)
        verbose = tapas_physio_log(sprintf(['Not enough volume events found. \n\tFound:  %d\n ' ...
            '\tNeeded: %d+%d+%d (Nprep+Ndummies+Nscans)\n' ...
            'Please lower sync.vol or sync.vol_spacing\n'], ...
            length(VOLLOCS), Nprep, Ndummies, Nscans), verbose, 2);
    end
else
    if length(VOLLOCS)< (Nscans+Ndummies)
        verbose = tapas_physio_log(sprintf(['Not enough volume events found. \n\tFound:  %d\n ' ...
            '\tNeeded: %d+%d (Ndummies+Nscans)\n' ...
            'Please lower sync.vol or sync.vol_spacing\n'], ...
            length(VOLLOCS), Ndummies, Nscans), verbose, 2);
    end
end


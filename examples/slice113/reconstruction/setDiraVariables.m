%% Set DIRA's variables
%
% Set Matlab path
p = path();
path(p, '../../../functions;../../../data')

% Names of files
resultsFileName = 'results.mat';
sinogramsFileName = 'sinograms.mat';
sinogramsBhFileName = 'sinogramsBH.mat';
spectraFileName = 'spectra.mat';
prostateMaskFileName = 'prostateMask.mat';

spectra =  load(spectraFileName);

%% Scanner model data
smd = ScannerModelData;
smd.eL = 80;            % low x-ray tube voltage in kV
smd.eH = 140;           % high x-ray tube voltage in kV
smd.eEL = 50.0;         % low effective energy in keV
smd.eEH = 88.5;         % high effective energy in keV
smd.ELow = spectra.currSpectLow(1:75, 1);
smd.NLow = spectra.currSpectLow(1:75, 2);
smd.EHigh = spectra.currSpectHigh(1:135, 1);
smd.NHigh = spectra.currSpectHigh(1:135, 2);
smd.L = 0.595;          % distance source - rot. center in m
smd.alpha = 38.4;       % fanbeam angle in deg
smd.N1 = 511;           % number of detector elements after rebinning
smd.dt1 = 0.402298392584693/(smd.N1+1); % detector element size
smd.interpolation = 2;  % Joseph projection generation

sinograms = load(sinogramsFileName);
sinogramsBH = load(sinogramsBhFileName);

% Phantom model data
pmd = PhantomModelData;
pmd.projLow = sinograms.projLow;
pmd.projHigh = sinograms.projHigh;
pmd.projLowBH = sinogramsBH.projLowBH;
pmd.projHighBH = sinogramsBH.projHighBH;


%% Elemental material composition (number of atoms per molecule) and
% mass density (in g/cm^3).

% Compact bone
boneStr = 'H0.403076C0.149395N0.033840O0.316004Na0.001473Mg0.000929P0.034249S0.001056Ca0.059978';
boneDens = 1.920;

% Bone marrow mixture
marrowMixStr = 'H0.620994C0.250615N0.008329O0.119144Na0.000124P0.000092S0.000267Cl0.000240K0.000145Fe0.000051';
marrowMixDens = 1.005;

% Lipid
lipidStr = 'H0.621918C0.341890O0.036192';
lipidDens = 0.920;

% Proteine
proteineStr = 'H0.480981C0.326573N0.089152O0.101004S0.002291';
proteineDens = 1.350;

% Prostate
prostStr = 'H0.629495C0.117335N0.012196O0.239088Na0.000265P0.000394S0.000571Cl0.000344K0.000312';
prostDens = 1.030;

% Calcium
caStr = 'Ca1.000000';
caDens = 1.550;

% Water
waterStr = 'H0.666667O0.333333';
waterDens = 1.000;

% Tissue 1
pmd.Dens2{1}(1) = boneDens;
Cross2{1}(:, 1) = [CalculateMAC(boneStr, smd.eEL),...
  CalculateMAC(boneStr, smd.eEH)];
pmd.Att2{1}(:, 1) = pmd.Dens2{1}(1)*Cross2{1}(:, 1);
mu2Low{1}(:, 1) = CalculateMACs(boneStr, 1:smd.eL);
mu2High{1}(:, 1) = CalculateMACs(boneStr, 1:smd.eH);

pmd.Dens2{1}(2) = marrowMixDens;
Cross2{1}(:, 2) = [CalculateMAC(marrowMixStr, smd.eEL),...
  CalculateMAC(marrowMixStr, smd.eEH)];
pmd.Att2{1}(:, 2) = pmd.Dens2{1}(2)*Cross2{1}(:, 2);
mu2Low{1}(:, 2) = CalculateMACs(marrowMixStr, 1:smd.eL);
mu2High{1}(:, 2) = CalculateMACs(marrowMixStr, 1:smd.eH);

% Tissue 2
pmd.Dens3{1}(1) = lipidDens;
pmd.Att3{1}(:, 1) = [pmd.Dens3{1}(1)*CalculateMAC(lipidStr, smd.eEL),...
  pmd.Dens3{1}(1)*CalculateMAC(lipidStr, smd.eEH)];
mu3Low{1}(:, 1) = pmd.Dens3{1}(1)*CalculateMACs(lipidStr, 1:smd.eL);
mu3High{1}(:, 1) = pmd.Dens3{1}(1)*CalculateMACs(lipidStr, 1:smd.eH);

pmd.Dens3{1}(2) = proteineDens;
pmd.Att3{1}(:, 2) = [pmd.Dens3{1}(2)*CalculateMAC(proteineStr, smd.eEL),...
  pmd.Dens3{1}(2)*CalculateMAC(proteineStr, smd.eEH)];
mu3Low{1}(:, 2) = pmd.Dens3{1}(2)*CalculateMACs(proteineStr, 1:smd.eL);
mu3High{1}(:, 2) = pmd.Dens3{1}(2)*CalculateMACs(proteineStr, 1:smd.eH);

pmd.Dens3{1}(3) = waterDens;
pmd.Att3{1}(:, 3) = [pmd.Dens3{1}(3)*CalculateMAC(waterStr, smd.eEL),...
  pmd.Dens3{1}(3)*CalculateMAC(waterStr, smd.eEH)];
mu3Low{1}(:, 3) = pmd.Dens3{1}(3)*CalculateMACs(waterStr, 1:smd.eL);
mu3High{1}(:, 3) = pmd.Dens3{1}(3)*CalculateMACs(waterStr, 1:smd.eH);

% Tissue 3
Dens3SA(1) = prostDens;
Att3SA(:, 1) = [Dens3SA(1)*CalculateMAC(prostStr, smd.eEL),...
  Dens3SA(1)*CalculateMAC(prostStr, smd.eEH)];
mu3LowSA(:, 1) = Dens3SA(1)*CalculateMACs(prostStr, 1:smd.eL);
mu3HighSA(:, 1) = Dens3SA(1)*CalculateMACs(prostStr, 1:smd.eH);

Dens3SA(2) = waterDens;
Att3SA(:, 2) = [Dens3SA(2)*CalculateMAC(waterStr, smd.eEL),...
  Dens3SA(2)*CalculateMAC(waterStr, smd.eEH)];
mu3LowSA(:, 2) = Dens3SA(2)*CalculateMACs(waterStr, 1:smd.eL);
mu3HighSA(:, 2) = Dens3SA(2)*CalculateMACs(waterStr, 1:smd.eH);

Dens3SA(3) = caDens;
Att3SA(:, 3) = [Dens3SA(3)*CalculateMAC(caStr, smd.eEL),...
  Dens3SA(3)*CalculateMAC(caStr, smd.eEH)];
mu3LowSA(:, 3) = Dens3SA(3)*CalculateMACs(caStr, 1:smd.eL);
mu3HighSA(:, 3) = Dens3SA(3)*CalculateMACs(caStr, 1:smd.eH);

% Ordering of coefficients are important first tissues for 2MD in the
% output order of tissue classification and then tissues for 3MD in output
% order of tissue classification.
pmd.tissueOrder2 = [1];
pmd.tissueOrder3 = [1];

pmd.muLow = cat(2, mu2Low{1}, mu3Low{1});
pmd.muHigh = cat(2, mu2High{1}, mu3High{1});

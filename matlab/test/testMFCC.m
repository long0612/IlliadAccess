% Test MFCC computation
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%

clear all; close all;
addpath(genpath('../../../../../voicebox/'))
addpath(genpath('../../../../../jsonlab'));
addpath(genpath('../../../../../V1_1_urlread2'));
addpath(genpath('../../../../../sas-clientLib/src'));

%% Test the mfcc algorithm
[y,fs] = audioread('../../../../../cohmm/data/GCWA/20160117213557235.wav');
%frameSize = 2^floor(log2(0.03*fs));
frameSize = 512;

% ground truth
d = 16;
nBank = floor(3*log(fs));
cepstCoef = melcepst(y,fs,'Mtaz',d,nBank,frameSize);

% manual implementation
%[h,a,b]=melbankm(nBank,frameSize,fs,0,0.5,'tz'); % dim-reduced h
h=melbankm(nBank,frameSize,fs,0,0.5,'tz'); % MFCC
%h=melbankm(16,frameSize,fs,0,0.5,'yu'); % TFRidge
hMsg = [];
for k = 1:size(h,1)
    hMsg = [hMsg '{' sprintf('%.6f,',full(h(k,:)))];
    hMsg(end) = [];
    hMsg = [hMsg sprintf('},\n')];
end
hMsg(end-1:end) = [];

% generate Hann window
win = hann(512)';
winStr = [];
winStr = [winStr '{' sprintf('%.6f,',win)];
winStr(end) = [];
winStr = [winStr sprintf('}')];

Y=enframe(y,hamming(frameSize),frameSize/2)'; % 'M' hamming
c = zeros(d,size(Y,2));
for k = 1:size(Y,2)
    %f=rfft(Y(:,k));
    allF = fft(Y(:,k));
    f = allF(1:frameSize/2+1);
    
    z=log(h*abs(f)); % 'a' amplitude
    %z=log(h*abs(f).^2); % 'p' power
    
    cTmp=dct(z)'; % nBank x 1
    c(:,k) = cTmp(2:d+1);
end
figure;
subplot(211); imagesc(c)
subplot(212); imagesc(cepstCoef')
suptitle(sprintf('frame size is %.3f s, norm diff is %.3f',frameSize/fs,norm(c-cepstCoef')));

%% test a single frame
% a frame from the sensor
fr = [0.0063423074020674125,0.001649840609314457,0.005061063669819562,0.005716019218441109,0.00793933107124501,0.005679079896848323,...
    0.006866804816746066,0.00864766204049122,0.0043608201937916456,0.00685158496333808,0.0048579896490906225,0.006057549345808853,...
	0.0013346739770572227,0.006103716252455332,0.005298840744020562,0.007815182963277562,0.005967943305559046,0.004255987125063645,...
	0.005867677303079816,0.005877828271928674,0.002034670335836269,0.0012072707607738385,0.0035402023542901143,0.003415989940100217,...
	0.0035064984255012404,0.0033533483385350753,0.004978098694364651,0.0021238673932660883,0.0018074377085761002,0.0018157304634703615,...
	3.8824789190986247E-4,0.002369563563727769,0.004481676620381599,0.007217508872406763,0.004663006375211411,0.002625836279836689,0.004936180761266241,...
	0.00548411282837604,9.180728498295116E-4,0.0027993843978600156,0.0022491998887784687,0.0016376229022950514,2.3412489155469227E-4,0.003594326287300729,...
	0.004831559371591743,0.004319432238065711,0.0035336931448877065,0.0034948780952262157,0.0047077352407659916,0.002637461263269844,0.003625490518639481,...
	0.004154291906928452,0.0024507757699596196,0.004139810481228409,0.003924204296854873,0.004206000582927682,0.0055767703831749995,0.004267036492976492,...
	0.003709845343186344,0.0033071357314389946,0.0039909261232856895,0.0032003831348067554,0.0030198316497821046,0.001842146443288252,0.002898813468003568,...
	0.0035742061568347404,0.004830650577378289,0.0037947419424626894,0.004346078873738896,0.00365598008709864,0.0025868622888178317,8.860066416718857E-4,...
	0.00407022313245926,0.003759151647272421,0.001070907111160618,0.001997374043405114,0.0016505060027524649,0.0020749272986715184,0.003663537046716901,...
	0.0031746637518885765,0.003072013931377413,0.0031712893122121267,0.0012354360556232217,0.0017392913328423828,0.0036786494474661223,0.002648270691166094,...
	5.17364556753202E-4,0.0018705735852090318,0.004491457485099255,0.004990897021348665,0.0025421729089936057,5.358426532582372E-4,0.0024313059494832784,...
	0.004172434753726657,0.002655880933572441,3.416769146917391E-4,0.0028697886686627704,0.0031193925734818795,9.677233228408717E-4,0.0020182610773793867,...
	0.002644032911372979,0.0013508152259455208,0.0014950568314887748,0.002291056945249895,0.0031583508877131815,0.0025893889948671667,0.004545044416746247,...
	0.002655829592414954,0.004226010294992278,0.003803900481254511,0.0023894210912962454,0.003387990570701414,0.003940573416533863,0.002035694079779685,...
	0.0016648287933914332,0.0016195841132688575,8.998517003289238E-4,6.196517965587272E-4,9.898890463692792E-4,7.086335725762749E-4,2.0010632891193246E-4,...
	3.0753230850102085E-4,1.868995406376394E-4,1.231183264979214E-4,4.665440037340202E-5,9.547238089619021E-5,9.330254156259548E-5,1.0175411816628508E-4]';
z = log(h(:,1:128)*fr);

cTmp=dct(z)';
N = numel(cTmp);
c = cTmp(2:d+1);

%% test results from remote data
servAddr = 'acoustic.ifp.illinois.edu';
DB = 'publicDb';
USER = 'nan';
PWD = 'publicPwd';
DATA = 'data';
EVENT = 'event';

fNameExt = '20160305062630305.wav';

events = IllColGet(servAddr,DB, USER, PWD, EVENT, fNameExt);
data = IllGridGet(servAddr, DB, USER, PWD, DATA, fNameExt);
[y, header] = wavread_char(data);
fs = double(header.sampleRate);
% must zero pad 50% overlapp to ensure size-match, results are slightly different due to
% internal buffer states on the phone
cepstCoef = melcepst([zeros(1,frameSize/2) y],fs,'Mtaz',d,nBank,frameSize);

figure;
subplot(211); imagesc(events{1}.MFCCFeat');
subplot(212); imagesc(cepstCoef')
suptitle(sprintf('frame size is %.3f s, norm diff is %.3f',frameSize/fs,norm( events{1}.MFCCFeat-cepstCoef )));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  Moon processing
clear,clc

p=['C:\Users\sergio\Documents\Photos\07062017\Moon\'];
file='IMG_7458.JPG';    %%name if the file to read
A=imread([p,file]); %%reads image file
cmap=colormap('gray');
A=rgb2ind(A,cmap);   %%converts RGB to index image
n=1;    %%steps to jump and reduce image size
A=A(1:n:end, 1:n:end);  %%reduces image size
figure(1)
imshow(A)
%% background pixels
bg=im2bw(A,0.1);   %%highlights the moon area
bgp=find(~bg);  %% finds the background (space) pixels
mp=find(bg);   %% finds the moon pixels

bg2=im2bw(A,0.02);   %%highlights the moon area
bgp2=find(~bg2);  %% finds the background (space) pixels
%% filtering
%%%% filters shape

%%%disk
h=fspecial('disk',25);
hg=fspecial('gaussian',size(h),0.3);
hl=fspecial('log',size(h),0.3);
ker=ones(size(h))*0;    %%% creates impulse kernel to generate a high pass filter
ker(floor(length(ker(:))/2)+1)=1;   %%creates impulse kernel 
nf=1/2;     %%factor to scale the high pass filter
k=0.5;    %% traces of a previous for loop
fact=nf*k;  %%factor to change the filter threshold
hpfl=(ker-hl)*fact; %%high frequency filter
Al=imfilter(A,hpfl);    %%filtered image
Alf=wiener2(Al,[5 5]);  %%noise reduction filtered image
Alf=wiener2(Alf,[5 5]);
hlpg=hg*fact;   %%low pass filter
Ag=imfilter(A,hlpg);    %%low pass filtered image
Aad=imadd(Alf,Ag);      %%addition of low pass and high pass filtered images


figure(2)
imshow(Aad) %%%Figure for poster. highleights terrain uneventies 

se = strel('square',3);  %%generates a gemoetric mask to sweep with
Asharp=imerode(Aad,se); %%reduces the contour noise and slightly sharpens the edges

%% section for snowflake figure
Asnow=uint8(Alf-30);
Asnow2=uint8((double(Asnow)).^1.2);
figure(3)
imshow(Asnow2)

%% section to select pixels for colored version
A2=(double(A)).^5;
A2=uint8(((A2/max(A2(:)))*255));
A2bw=im2bw(A2,0.05);
se = strel('disk',3);  %%generates a gemoetric mask to sweep with
A2bwe=imerode(A2bw,se);
% imshow(A2bwe)

%%% has pixels for crater region
A3=ones(size(A))*0;
A3(1:size(A,1)*900)=Aad(1:size(A,1)*900);
A3d=imfilter(A3,h);
A3db=(double(A3d)).^2;
A3db=uint8((A3db/max(A3db(:)))*255);
A3bw=im2bw(A3db,0.15);
%%%loads previously processed image to collect pixels on a determined region
load('C:\Users\sergio\Documents\Photos\07062017\Moon\moon07252017.mat','BW','x','y','xi','yi','portion')
A4=ones(size(A))*0;
A4(portion)=Aad(portion);
A4bw=im2bw(uint8(A4),0.09);
%%%loads previously processed image to collect pixels on a determined region
load('C:\Users\sergio\Documents\Photos\07062017\Moon\moon07252017_2.mat','BW2','x2','y2','xi2','yi2','portion2')
A5=ones(size(A))*0;
A5(portion2)=Aad(portion2);
A5bw=im2bw(uint8(A5),0.2);


%%% sets the pixels of interest
Am=ones(size(A))*0;
Am(find(A2bwe))=1;
Am(find(A3bw))=1;
Am(find(A4bw))=1;
Am(find(A5bw))=1;
landpixs=find(Am);
lakepixs=find(imsubtract(uint8(bg),uint8(Am)));
% % figure(1)
% % imshow(Am)
% imshow(uint8((imsubtract(uint8(bg),uint8(Am))))*255)
% Ami=uint8((imsubtract(uint8(bg),uint8(Am))))*255;
% Ami2=double(Ami);
% Ami2(bgp)=-1;
% %%%%%%%%%%%%%%%%%%%%%%%%
% %%
% At=double(Aad);
% At(bgp)=-1;


%% section creating color map
% number of colors
nb=1;   %%range of black colors
n1=1;
n2=30;
n3=70;
n4=100;
n5=131;

%%% black colors
c1=ones(nb,3)*0;
%%% blue colors
c21=interp1([n1 n2],[3 89]/255,[n1:n2],'linear');
c22=interp1([n1 n2],[13 235]/255,[n1:n2],'linear');
c23=interp1([n1 n2],[109 239]/255,[n1:n2],'linear');
%%% green colors
c31=interp1([n2+1 n3],[8 15]/255,[n2+1:n3],'linear');
c32=interp1([n2+1 n3],[108 209]/255,[n2+1:n3],'linear');
c33=interp1([n2+1 n3],[13 24]/255,[n2+1:n3],'linear');
%%% yellow colors
c41=interp1([n3+1 n4],[172 232]/255,[n3+1:n4],'linear');
c42=interp1([n3+1 n4],[203 247]/255,[n3+1:n4],'linear');
c43=interp1([n3+1 n4],[17 159]/255,[n3+1:n4],'linear');
%%% brown colors
c51=interp1([n4+1 n5],[246 252]/255,[n4+1:n5],'linear');
c52=interp1([n4+1 n5],[191 237]/255,[n4+1:n5],'linear');
c53=interp1([n4+1 n5],[102 212]/255,[n4+1:n5],'linear');
%%% white colors
c6=ones(256-n5,3);
%%% merges the colormap
cm=[c1;c21' c22' c23'; c31' c32' c33'; c41' c42' c43'; c51' c52' c53'; c6];

%% colored figures
figure(4)
Ac1=Aad;    %% copy the orginial processed figure
Ac1(bgp2)=0;    %% sets space pixels to 0
imshow(Ac1)
colormap(cm)

figure(5)
randl=ceil(n1+(n2-28-n1)*rand(length(lakepixs),1));
Ac2=Aad;
Ac2(lakepixs)=randl;
Ac2(bgp2)=0;
imshow(Ac2)
colormap(cm)


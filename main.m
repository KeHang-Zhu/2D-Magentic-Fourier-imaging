%% constant
gamma=2.803;%gyromagnetic ratio
ub=9.274*10^(-24);
u=ub;%magnetism for spin 1/2 particle
conv2um=1000;
int=10^(-9);%pixel size 1 nm
T2=0.3;%T2* 0.3us
pixel=0.001;
N=200;%number of points

%% parameter NV related
a0=1*10^(-8);%NV distance
aa0=a0*10^(6);%convert the average distance of NV into um
distance=ceil(a0/int);
n_spin=ceil(N/distance);%number of spins
delta_x=a0*10^6;%distance between NV centers in scale of um
delta_y=a0*10^6;%distance between NV centers in scale of um
C=1;%contrast 1


%% parameter material related
height=30;%the distance between NV center and material
HW=1.5*10^(-8);%half width of the magnetic field distribution
B0=0.2;%amplitude of the magnetic field Gauss ,therefore phi_s(x)=2pi*gamma*T2*B_max won't exceeds 2pi, avoids the dillemma
Size=10*10^(-7);%sample size 100nm
period=20;  %spatial period of magnetic field
delta_k=1/Size/10^(6);%field of view

%% lattice playground
disturbed=1;      %whether the NV grid is ideal or random

%underlying super-lattice structure
mode=1;                 %1 represents rectangular lattice
                        %2 represents regular triangular lattice, 
                        %3 represents regular hex lattice  
field=3;             %1 represent single domain wall (for test), 
                     %2 represent dipolar field generate by ferromagnetical aligned spins 
                     %3 represent magnetic field generated by Skyrmion 
                     
noise=0;            %0 represent projection noise measurement
                    %1 represnet photon-shot noise measurement
photon=1000;        %number of photon                   
                                                 
%% scanning part    
spacing=50; %real space scanning 50 nm
N_px=3;%scanning points in x direction
N_py=3;%scanning points in y direction
Recon=zeros(N_px,N_py,n_spin*n_spin);
scanning_x=zeros(N_px,N_py,n_spin*n_spin);
scanning_y=zeros(N_px,N_py,n_spin*n_spin);

%% %NV's position 
 [pos_NVx,pos_NVy]=position_2D(N,n_spin,distance,disturbed); 
 
%% set the field at the sensor location (with wider region)
 mul=spacing*(max(N_px,N_py)-1)+N;
 [MB]=Mag_senspr_2D(N,mul,B0,HW,pos_NVx,pos_NVy,int,n_spin,period,height,gamma,T2,field,mode); 
 
 pos_x=pixel:pixel:N/1000;
 pos_y=pixel:pixel:N/1000;
 
%% spectrum analysis of the magnetic field
%  GB=fft2(MB-mean(MB(:)));
%  ABS=abs(GB);
%  kx=0:1000/mul:1000;
%  ky=0:1000/mul:1000;
%  figure
%  surf(kx(1:30),ky(1:30),ABS(1:30,1:30))
%  view(2)
%  colorbar
%  xlabel('kx/um^{-1}');
%  ylabel('ky/um^{-1}');
%  title('Fourier spectrum');

%% start scanning
for jj=1:N_px
  for mm=1:N_py

     B=MB((jj-1)*spacing+1:(jj-1)*spacing+N,(mm-1)*spacing+1:(mm-1)*spacing+N); % the B field at the moved region 
     
%      pixel=1/1000;%pixel size=1000/diatance/NNN nm
%      pos_x=pixel:pixel:N/1000;
%      pos_y=pixel:pixel:N/1000;
%      figure
%      mesh(pos_x,pos_y,B);
%      view(2)
%      colorbar
%      xlabel('x/um');
%      ylabel('y/um');
%      title('input magnetic field ditribution');
     
     %% Ramsey sequence
     Kxmax=N;
     Kymax=Kxmax;
     Kx=1:1:Kxmax ; %x wave vector
     Ky=1:1:Kymax ; %y wave vector
     Fs = 1/Kx(1); %field of view
     [S,phi]=ksample(N,pos_NVx,pos_NVy,n_spin,B,T2,gamma,Kxmax,Kymax,noise,photon); %perform Ramsey sequence measurement

      %%  plot the K space spectrum  
%     ABS=abs(S);
%     Re=real(S);
%     deltak=conv2um/N;
%     fx=deltak:deltak:1000;
%     fy=fx;
%     figure
%     mesh(fx,fy,ABS);
%     view(2)
%     colorbar
%     xlabel('kx/um^{-1}');
%     ylabel('ky/um^{-1}');
%     title('F(kx,ky)');

    %% compressed sensing (by randomly tossing S points)
%     Tosspt=floor(N/2);
%     Tosspt_x=sort(randperm(N,Tosspt));
%     Tosspt_y=sort(randperm(N,Tosspt)); 
%     for ii=Tosspt:-1:1
%         for ll=Tosspt:-1:1
%             x_t=Tosspt_x(ii);
%             y_t=Tosspt_y(ll);
%             S(x_t,y_t)=0;
%         end
%     end
    
     %%  plot the K space spectrum of compressed sensing
%     ABS=abs(S);
%     deltak=conv2um/N;
%     fx=deltak:deltak:1000;
%     fy=fx;
%     figure
%     mesh(fx,fy,ABS);
%     view(2)
%     colorbar
%     xlabel('kx/um^{-1}');
%     ylabel('ky/um^{-1}');
%     title('compressed sensing');
    
     %% inverse Fourier transformation
     [G2]=invFourier_2D(S,N,N);
     ABS=abs(G2);
     phase=angle(G2);
     phase=phase./(2*pi*T2*gamma);
     
     %% plot the original inv Fourier pattern
%      pixel=1/1000;%pixel size=1000/diatance/NNN nm
%      pos_x=pixel:pixel:N/1000;
%      pos_y=pixel:pixel:N/1000;
%      figure
%      mesh(pos_x,pos_y,ABS);
%      view(2)
%      colorbar
%      xlabel('x/um');
%      ylabel('y/um');
%      title('reconstructed NV center ditribution');
%      
%      figure
%      mesh(pos_x,pos_y,phase);
%      view(2)
%      colorbar
%      xlabel('x/um');
%      ylabel('y/um');
%      title('reconstructed field ditribution');
     
     %% track the B distribution after locating the NV distribution
     
     [pos_Xr,pos_Yr,X_r,Y_r,phase_re,non_pha]=locating_2D(ABS,phase,n_spin,pos_x,pos_y);
     
     %% collect scanning points
     Recon(jj,mm,1:length(X_r))=non_pha;
     X_r=X_r+(jj-1)*spacing/conv2um;
     Y_r=Y_r+(mm-1)*spacing/conv2um;
     scanning_x(jj,mm,1:length(X_r))=X_r;
     scanning_y(jj,mm,1:length(Y_r))=Y_r;
  end
end

%% reshape real space scanning data
val=Recon(:);
XX=scanning_x(:);
YY=scanning_y(:);

% [XX,index]=unique(XX); %take out the repeated points
% yy=zeros(length(XX),1);
% val2=zeros(length(XX),1);
% for ii=1:length(XX)
%     yy(ii)=YY(index(ii));
%     val2(ii)=val(index(ii));
% end

%% generate the data form convenient for R language processing
import2R=[XX,YY,val];

% figure
% plot3(import2R(:,1),import2R(:,2),import2R(:,3),'.');
% xlabel('x/um');
% ylabel('y/um');
% title('scanned reconstruction field'); 

if (field==2)
    %% curve fitting for getting the info of dipolar kernal
    % find the suitable initial values for curve fitting
    [B0,index_c]=max(val);
    xc=XX(index_c);
    yc=YY(index_c);
    
    %% cluster all the points into one unit cell
    re_x=XX;re_y=YY;
    pd=period/conv2um;
    for ii=1:length(XX)
        deltax=XX(ii)-xc;
        deltay=YY(ii)-yc;
        re_x(ii)=rem(deltax,pd);
        re_y(ii)=rem(deltay,pd);
        if (re_x(ii)<-pd/2)
            re_x(ii)=re_x(ii)+pd;
        end
        if (re_x(ii)>pd/2)
            re_x(ii)=re_x(ii)-pd;
        end
        if (re_y(ii)<-pd/2)
            re_y(ii)=re_y(ii)+pd;
        end
        if (re_y(ii)>pd/2)
            re_y(ii)=re_y(ii)-pd;
        end
    end
    import2R_c=[re_x,re_y,val];
    
    
    figure
    plot3(import2R_c(:,1),import2R_c(:,2),import2R_c(:,3),'.');
    set(gca,'XLim',[-0.05 0.05],'YLim',[-0.05 0.05]);
    xlabel('x/um');
    ylabel('y/um');
    title('clusterred reconstruction field');
    
    %% cluster nearest points into one unit cell
    pd=period/conv2um;
    re_xx=0;
    re_yy=0;
    val2=0;
    to_be_x=0;
    to_be_y=0;
    to_be_val=0;
    for ii=1:length(XX)
        deltax=XX(ii)-xc;
        deltay=YY(ii)-yc;
        if (abs(deltax)<pd/2 && abs(deltay)<pd/2)
            re_xx(end+1)=deltax;
            re_yy(end+1)=deltay;
            val2(end+1)=val(ii);
        elseif (abs(deltax)<pd/2*3 && abs(deltay)<pd/2*3)
            to_be_x(end+1)=rem(deltax,pd);
            to_be_y(end+1)=rem(deltay,pd);
            to_be_val(end+1)=val(ii);
            if (to_be_x(end)<-pd/2)
                to_be_x(end)=to_be_x(end)+pd;
            end
            if (to_be_x(end)>pd/2)
                to_be_x(end)=to_be_x(end)-pd;
            end
            if (to_be_y(end)<-pd/2)
                to_be_y(end)=to_be_y(end)+pd;
            end
            if (to_be_y(end)>pd/2)
                to_be_y(end)=to_be_y(end)-pd;
            end
        end 
    end
    re_xx(1)=[];re_yy(1)=[];val2(1)=[];
    to_be_x(1)=[];to_be_y(1)=[]; to_be_val(1)=[];
    
    for ii=length(to_be_x):-1:1
        if (sqrt(to_be_x(ii)^2+to_be_y(ii)^2)<pd/3)
            to_be_x(ii)=[];
            to_be_y(ii)=[];
            to_be_val(ii)=[];
        end
    end
    re_xx=[re_xx,to_be_x];
    re_yy=[re_yy,to_be_y];
    val2=[val2,to_be_val];
    
    import2R_cluster=[re_xx;re_yy;val2];
    
    
    figure
    plot3(import2R_cluster(1,:),import2R_cluster(2,:),import2R_cluster(3,:),'.');
    set(gca,'XLim',[-0.05 0.05],'YLim',[-0.05 0.05]);
    xlabel('x/um');
    ylabel('y/um');
    title('clusterred reconstruction field');
    import2R_cluster=import2R_cluster';
end
 
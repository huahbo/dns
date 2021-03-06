%
%
% 4/5 ths law: time and angle averaged 
%
%
mu=0;
ke=0;
nx=1;
delx_over_eta=1;
eta = 1/(nx*delx_over_eta);
ext='.isostr';


%name='/ccs/scratch/taylorm/dns/iso12/iso12_512'
%nx=512; delx_over_eta=2.74; epsilon=3.89;  teddy=1.0
%pname='iso12_512';

%name='/home2/skurien/helicity_data/helical_forced/hel256_hpi2/hel256_hpi2_'
%nx=256; delx_over_eta=3.13; epsilon=2.72; teddy=1.05; % R_l=186
%pname = 'hel256\_hpi2\_'
%ext='.new.isostr';
%times = [4.2:0.2:10.2];

%name='/ccs/scratch/taylorm/dns/sc1024A/sc1024A'
%nx=2048; delx_over_eta=2.98; epsilon=3.74; teddy=1.024;
%ext='.new.isostr';
%pname='sc1024A';
%times=[1:.1:2.5];

%name = '/home2/skurien/helicity_data/isostr_1/check256_hq_';
%ext='.new.isostr';


name = '/nh/nest/u/skurien/projects/helicity_data/helical_forced/hel512_hpi2/diag/skhel512a';
ext='.new.isostr';
pname = 'skhel512a'
times = [2.0:0.2:9.8];
nx=512

[avg_eps, avg_heps, avg_delx_over_eta] = ensemble_avg_params(name,ext,times)
nx=512; delx_over_eta=avg_delx_over_eta; epsilon=avg_eps; h_epsilon=avg_heps;  

teddy=1.05;
%times=[0:1:30];

ndir_use=0;
%ndir_use=49;  disp('USING ONLY 49 DIRECTIONS')

% this type of averging is expensive:
time_and_angle_ave=1;

k=0;


xx=(1:.5:(nx./2.5)) / nx;
xx_plot=(1:.5:(nx./2.5)) *delx_over_eta;   % units of r/eta

y45_ave=zeros([length(xx),73]);
if (time_and_angle_ave==1) 
   y45_iso_ave=zeros([length(xx),1]);
end

times_plot=[];
for t=times
  tstr=sprintf('%10.4f',t+10000);
  fname=[name,tstr(2:10)];
  disp([fname,ext]);
  ppname = [pname,tstr(2:10),ext];
  fid=fopen([fname,ext]);
  if (fid<0) ;
    disp('error openining file, skipping...');
  else
    fclose(fid);
    times_plot=[times_plot,t];
    k=k+1;

    if (time_and_angle_ave==1) 
      klaws=1;                          % compute 4/5 laws
      plot_posneg=0;
      check_isotropy=0;
      
      [y45,y415,y43,eps,h_eps]=compisoave(fname,ext,xx,ndir_use,klaws,plot_posneg,check_isotropy,1);
      
      
      mx45_iso_localeps(k)=max(y45);
      mx45_iso(k)=max(y45)*eps/epsilon;
mn45_iso_localeps(k) = y45(1);
mn45_iso(k) = y45(1)*eps/epsilon;
      y45_iso_ave=y45_iso_ave+y45';
      
    end    


    [nx,ndelta,ndir,r_val,ke,eps_l,mu,D_ll,D_lll] ...
        = readisostr( [fname,ext] );
    
    eta_l = (mu^3 / eps_l)^.25;
    delx_over_eta_l=(1/nx)/eta_l;
    
    for dir=1:73;
      x=r_val(:,dir)/nx;                % box length
      y=-D_lll(:,dir)./(x*eps_l);
      
      y45 = spline(x,y,xx);
      
      mx45_localeps(k,dir)=max(y45);
      mx45(k,dir)=max(y45)*eps/epsilon;
      mn45_localeps(k,dir)=y45(1);
      mn45(k,dir)=y45(1)*eps/epsilon;

      y45_ave(:,dir)=y45_ave(:,dir)+y45';
    end
  end

end

times=times_plot;
y45_ave=y45_ave/length(times);
y45_iso_ave=y45_iso_ave/length(times);

if (0)

% averging starting at t=0:
save k45data_t0 teddy times mx45_localeps mx45_iso_localeps ...
      y45_ave y45_iso_ave xx_plot

% averging starting at t=1:
save k45data_t1 teddy times mx45_localeps mx45_iso_localeps ...
      y45_ave y45_iso_ave xx_plot

% load data from t=0 (averaged wrong!) for isoave paper:
load k45data_t0 

% load data from t=1 (for time averaged) for isoave paper:
load k45data_t1 
end


figure(8); clf; hold on;
scale = 1;  %scale = 4/5 is normalizing by prefactor as well 
for i=1:1:1 % directions
 plot(times/teddy,mx45_localeps(1:length(times),i)/scale,'g-','LineWidth',2.0);
end
plot(times/teddy,mx45_iso_localeps,'b-','LineWidth',2.0);
ax=axis;
axis( [ax(1),ax(2),.5,1.0] );
plot(times,(4/5)*times./times/scale,'k');
hold off;
%ylabel(' < (u(x+r)-u(x))^3 > / (\epsilon r)','FontSize',16);
xlabel('t/T','FontSize',18)
     set(gca,'fontsize',18);
%title(ppname);
%print('-dpsc', 'k45time.ps')
%print('-dtiff', 'k45time.jpg')


figure(9); clf
scale = 1; %scale = 4/5 if need to normalize out the 4/5th
for i=[1:20:73]
  semilogx(xx_plot,y45_ave(:,i),'k:','LineWidth',1.0); hold on %for paper
%  semilogx(xx_plot,y45_ave(:,i)/scale,'g-','LineWidth',1.0); hold on
end
%semilogx(xx_plot,y45_iso_ave/scale,'k','LineWidth',1.0); hold on
semilogx(xx_plot,y45_iso_ave/scale,'k','LineWidth',2.5); hold on %for paper
axis([1 1000 0 1.0])
x=1:1000; plot(x,(4/5)*x./x/scale,'k');
hold off;
title(ppname);
ylabel('< (u(x+r)-u(x))^3 > / (\epsilon r)','FontSize',18);
xlabel('r/\eta','FontSize',18);

print -dpsc k45mean.ps

return


% plot deviation from mean:
%figure(10); clf
%offset=y45_iso_ave;
%stdr=0*offset;
%scale = 4/5; % scale = 4/5 if need to factor out the 4/5 
%for i=[1:1:73]
%  i
%  semilogx(xx_plot,abs(y45_ave(:,i)-offset)/offset,'m-','LineWidth',1.0); hold on
%  stdr=stdr+(y45_ave(:,i)-offset).^2;
%end
%stdr=sqrt(stdr/15)./offset;
%title('Measure of anisotropy - 4/5 law; |D_{lll}(dir) - D_{lll}(ave)|/D_lll(ave)');
%ylabel(ppname);
%xlabel('r/\eta','FontSize',16);




starttime=1;
ln=find(times>=starttime);
ln=ln(1);
lnmax=length(times);

dir_use=1;
[mean(mx45(ln:lnmax,dir_use)),mean(mx45_iso(ln:lnmax))]
[std(mx45(ln:lnmax,dir_use)),std(mx45_iso(ln:lnmax)) ]


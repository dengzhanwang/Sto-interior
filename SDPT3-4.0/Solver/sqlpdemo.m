%%*****************************************************************
%% Examples of SQLP. 
%%
%% this is an illustration on how to use our SQLP solvers
%% coded in sqlp.m 
%% 
%% feas = 1 if want feasible initial iterate
%%      = 0 otherwise
%%*****************************************************************
%% SDPT3: version 4.0
%% Copyright (c) 1997 by
%% Kim-Chuan Toh, Michael J. Todd, Reha H. Tutuncu
%% Last Modified: 16 Sep 2004
%%*****************************************************************
  
   function  sqlpdemo; 
    rng(2)
%    randn('seed',0); rand('seed',0); 
%    feas = input('using feasible starting point? [yes = 1, no = 0] ');
    feas = 1;
   if (feas)
      fprintf('\n  using feasible starting point\n\n');
   else
      fprintf('\n  using infeasible starting point\n\n');
   end
   pause(1);

   ntrials = 1;
   iterm = zeros(2,6); infom = zeros(2,6); timem = zeros(2,6);

   sqlparameters; 

   for trials = [1:ntrials];
   for eg = [1]
       if (eg == 1);
          disp('******** random sdp **********')
          n = 10; m = 20; 
          [blk,At,C,b,X0,y0,Z0] = randsdp(n,[],[],m,feas); 
          text = 'random SDP';
       elseif (eg == 2);
          disp('******** Norm minimization problem. **********')
          n = 10; m = 5; B = []; 
          for k = 1:m+1; B{k} = randn(n); end;
          [blk,At,C,b,X0,y0,Z0] = norm_min(B,feas); 
          text = 'Norm min. pbm';
       elseif (eg == 3); 
          disp('******** Max-cut *********');
          N = 10;
          B = graph2(N); 
          [blk,At,C,b,X0,y0,Z0] = maxcut(B,feas); 
          text = 'Maxcut'; 
       elseif (eg == 4); 
          disp('********* ETP ***********')
          N = 10; 
          B = randn(N); B = B*B';
          [blk,At,C,b,X0,y0,Z0] = etp(B,feas); 
          text = 'ETP';
       elseif (eg == 5);
          disp('**** Lovasz theta function ****')  
          N = 10;
          B = graph2(N); 
          [blk,At,C,b,X0,y0,Z0] = thetaproblem(B,feas);
          text = 'Lovasz theta fn.';
       elseif (eg == 6); 
          disp('**** Logarithmic Chebyshev approx. pbm. ****')  
          N = 20; m = 5; 
          B = rand(N,m); f = rand(N,1); 
          [blk,At,C,b,X0,y0,Z0] = logcheby(B,f,feas);
          text = 'Log. Chebyshev approx. pbm';
       end;     
%%
       m = length(b);
       nn = 0;
       for p = 1:size(blk,1),
           nn = nn + sum(blk{p,2});
       end
%%
       Gap = []; Feas = []; legendtext = []; 
       for vers = [1 2];
           OPTIONS.vers = vers;
%            profile on
           [obj,X,y,Z,infoall,runhist] = ...
                      sqlp(blk,At,C,b,OPTIONS,X0,y0,Z0);
%            profile viewer
%            profile off
           gaphist = runhist.gap; 
           infeashist = max([runhist.pinfeas; runhist.dinfeas]); 
           eval(['Gap(',num2str(vers),',1:length(gaphist)) = gaphist;']); 
           eval(['Feas(',num2str(vers),',1:length(infeashist))=infeashist;']);
           if (vers==1); legendtext = [legendtext, ' ,''HKM'' '];
           elseif (vers==2); legendtext = [legendtext, ' ,''NT''  ']; 
           end;                
       end;
       h = plotgap(Gap,Feas);      
       xlabel(text);        
       eval(['legend(h(h>0)' ,legendtext, ')']);
       fprintf('\n**** press enter to continue ****\n'); pause
   end 
   end
%%
%%======================================================================
%% plotgap: plot the convergence curve of 
%%          duality gap and infeasibility measure.
%%
%%         h = plotgap(Gap,Feas); 
%%
%% Input:  Gap  = each row of Gap corresponds to a convergence curve
%%                of the duality gap for an SDP.
%%         Feas = each row of Feas corresponds to a convergence curve
%%                of the infeasibility measure for an SDP.
%%
%% Output: h = figure handle. 
%%
%% SDPT3: version 3.0 
%% Copyright (c) 1997 by
%% K.C. Toh, M.J. Todd, R.H. Tutuncu
%% Last modified: 7 Jul 99
%%********************************************************************

    function  h = plotgap(Gap,Feas) 

    clf; 
    set(0,'defaultaxesfontsize',12);
    set(0,'defaultlinemarkersize',2);
    set(0,'defaulttextfontsize',12);
%%
%% get axis scale for plotting duality gap
%%
    tmp = []; 
    for k = 1:size(Gap,1);
        gg = Gap(k,:); 
        if ~isempty(gg); 
           idx = find(gg > 5*eps); gg = gg(idx);
           tmp = [tmp abs(gg)];
           iter(k) = length(gg); 
        else 
           iter(k) = 0; 
        end;
    end;
    ymax = exp(log(10)*(round(log10(max(tmp)))+0.5));  
    ymin = exp(log(10)*min(floor(log10(tmp)))-0.5);  
    xmax = 5*ceil(max(iter)/5);
%%
%% plot duality gap
%%
    color = '-r --b--m-c '; 
    if nargin == 2; subplot('position',[0.05 0.3 0.45 0.45]); end;
    for k = 1:size(Gap,1);
        gg = Gap(k,:); 
        if ~isempty(gg); 
           idx = find(gg > 5*eps); 
           if ~isempty(idx); gg = gg(idx); len = length(gg); 
              semilogy(len-1,gg(len),'.b','markersize',12); hold on;
              h(k) = semilogy(idx-1,gg,color([3*(k-1)+1:3*k]),'linewidth',2); 
           end; 
        end;
    end;
    title('duality gap');  axis('square'); 
    if nargin == 1;  axis([0 xmax ymin ymax]); end; 
    hold off;
%%
%% get axis scale for plotting infeasibility
%%
    if nargin == 2; 
       tmp = []; 
       for k = 1:size(Feas,1);  
           ff = Feas(k,:);
           if ~isempty(ff); 
              idx = find(ff > 0); ff = ff(idx);
              tmp = [tmp abs(ff)];
              iter(k) = length(ff);
           else 
              iter(k) = 0; 
           end;
       end;
       fymax = exp(log(10)*(round(log10(max(tmp)))+0.5));  
       fymin = exp(log(10)*(min(floor(log10(tmp)))-0.5));  
       ymax = max(ymax,fymax); ymin = min(ymin,fymin); 
       xmax = 5*ceil(max(iter)/5);
       axis([0 xmax ymin ymax]);
%%
%% plot infeasibility
%%
       subplot('position',[0.5 0.3 0.45 0.45]);
       for k = 1:size(Feas,1); 
           ff = Feas(k,:);
           ff(1) = max(ff(1),eps); 
           if ~isempty(ff); 
              idx = find(ff > 1e-20); 
              if ~isempty(idx); ff = ff(idx); len = length(ff); 
                 semilogy(len-1,ff(len),'.b','markersize',12); hold on;
                 h(k) = semilogy(idx-1,ff,color([3*(k-1)+1:3*k]),'linewidth',2);
              end; 
           end;
       end;
       title('infeasibility measure'); 
       axis('square');  axis([0 xmax ymin max(1,ymax)]);
       hold off; 
    end;  
%%====================================================================



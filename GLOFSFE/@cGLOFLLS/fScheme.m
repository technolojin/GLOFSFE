function [ Mave,Mc2f,SumFlux,Msigma,Diff_x,Diff_t ] = fScheme( ni,nj,Scell )
%% scheme
% tau vector follows face ni*nj
% flux follows face ni*nj
% residual unit around node (ni-1)*(nj-1)
nM=ni*nj;
nP=(ni-1)*(nj-1);

% time average
Mave=[spdiags(ones(nM,1),0,nM,nM),spdiags(ones(nM,1),0,nM,nM)]/2;

% cell to flux
f_c2f=rot90([1,1;0,0]/2,2);
Mc2f=[convmtx2_mod(f_c2f ,ni,nj,'same');convmtx2_mod(f_c2f',ni,nj,'same')];

% spatial differential scheme, 
% summarize 2 Directions into one residual unit 
f_diff=rot90([-1,0;1,0],2);
Diff_x=[convmtx2_mod(f_diff ,ni,nj,'valid'),sparse(nP,nM);...
            sparse(nP,nM),convmtx2_mod(f_diff',ni,nj,'valid')];
SumFlux=[spdiags(ones(nP,1),0,nP,nP),spdiags(ones(nP,1),0,nP,nP)];

% time differential scheme, average on one cell 
Mc2n=convmtx2_mod(ones(2)/4,ni,nj,'valid');
Diff_t=[-Mc2n,Mc2n];

% cell to residual integral matrix
Msigma=convmtx2_mod(rot90(Scell,2),ni-1,nj-1,'valid');

end


function T = convmtx2_mod(H,M,N,varargin)

% size options 
% 'full'(default), 'same', or 'valid'

if size(varargin,1)==1
    output = varargin;
else
    output='full';
end
if strcmp(output,'full')
    sizeidx=0;
elseif strcmp(output,'same')
    sizeidx=1;
elseif strcmp(output,'valid')
    sizeidx=2;
else
    sizeidx=0;
end

T = convmtx2(H,M,N);


if sizeidx~=0
    [P, Q] = size(H);
    Mresize=zeros(M+P-1,N+Q-1);
    if sizeidx==1
        Mresize(P:end,Q:end)=1;
    elseif sizeidx==2
        Mresize(P:M,Q:N)=1;
    end
    
    n=size(Mresize(:),1);
    pj=find(Mresize(:));
    j=size(pj,1);
    pi=1:j;
    Mresize=sparse(pi,pj,ones(j,1),j,n);
    
    T=Mresize*T;
end

end



  

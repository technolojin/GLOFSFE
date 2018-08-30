function M = rdmtx( list )
%RDMTX
%reduce matrix  
%list: selected list [logical]
%M :sparse matrix

n=size(list(:),1);

pj=find(list(:));
j=size(pj,1);
pi=1:j;

M=sparse(pi,pj,ones(j,1),j,n);

end


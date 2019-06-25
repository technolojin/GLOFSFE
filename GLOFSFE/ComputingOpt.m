function use_gpu = ComputingOpt( varargin )
% Checking Parallel Computing Toolbox version
% Sparse Arrays on a GPU is required
% which supported from R2016a

narginchk(0,1);
% set default
if nargin==0
    use_gpu=false;
    return
end

% read option
option=varargin{1};
if strcmpi(option,'gpu')
    use_gpu=true;
elseif strcmpi(option,'cpu')
    use_gpu=false;
else
    error('Invalid computing option');
end

% check software and hardware
if verLessThan('distcomp','6.8') && use_gpu
    PCTver=ver('distcomp');
    fprintf(1,['%s %s %s does not support sparse arrays on GPU\n',...
               'Computing option is changed to CPU\n'],...
               PCTver.Name,PCTver.Version,PCTver.Release);
    use_gpu=false;
elseif gpuDeviceCount==0 && use_gpu
    fprintf(1,['Current hardware does not support GPU computing\n',...
        'Computing option is changed to CPU\n']);
    use_gpu=false;
end


end


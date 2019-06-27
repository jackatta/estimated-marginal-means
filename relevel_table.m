function [emm] = relevel_table(emm, var2relevel, varargin)
% Re-level categorical variables in the estimated marginal means table
% Copyright 2019, J. Hartman, Cornell University
% written using Matlab version R2016a 
% 
% INPUTS:
% emm is output from emmeans.m
% var2relevel is 1 x N cell array of strings corresponding to N variables 
% % in emm.table that you wish to relevel.
% varargin has N inputs where each is a cell array of strings corresponding 
% % to the desired order of levels in var2relevel.
% 
% example:
% emm = emmeans(mdl,{'Smoker'});
% emm = relevel_table(emm, {'Smoker'}, {'No', 'Yes'});
% h = emmip(emm, '~ Smoker');
% 
% emm = emmeans(mdl,{'Smoker','Sex'};
% emm = relevel_table(emm, {'Smoker','Sex'}, {'No','Yes'}, {'Male','Female'});
% h = emmip(emm, 'Sex~Smoker');

new_levels = checkInputs(emm,var2relevel,varargin);

if length(var2relevel)==1
    old_levels = checkInnerInputs(emm, var2relevel, new_levels);
    new_levels = strcat(num2str((1:length(old_levels))'),old_levels);
    for ii=1:length(old_levels)
        ind = ismember(emm.table.(var2relevel{:}), old_levels{ii});
        emm.table.(var2relevel{:})(ind) = repmat(new_levels(ii),sum(ind),1);
    end
    emm.table = sortrows(emm.table,var2relevel{:});
    nchars = floor(log10(length(old_levels))+1); % number characters or spaces in front of original level
    emm.table.(var2relevel{:}) = cellfun(@(x) x(1+nchars:end), emm.table.(var2relevel{:}), 'uni', 0);
else
    for jj=1:length(var2relevel)
        emm = relevel_table(emm, var2relevel(jj), new_levels{jj});
    end
end

end

function [lvls] = checkInputs(emm,v2lvl,lvls)

if length(v2lvl)~=length(lvls)
    error('There must be input levels for each variable to be re-leveled');
end
allvars = emm.table.Properties.VariableNames(1:end-3);
if any(~ismember(v2lvl,allvars))
    error('Oops. Variable is not in table. Check spelling.');
end
alllvls = unique(emm.table{:,v2lvl});
if any(~ismember([lvls{:}],alllvls))
    error('Oops. Levels are not in table. Check spelling.');
end

end

function [chklvls] = checkInnerInputs(emm,v2lvl,chklvls)

chklvls = chklvls{:};
chklvls = chklvls';
truelvls = unique(emm.table.(v2lvl{:}));
if any(~ismember(chklvls,truelvls))
    error('Input levels do not correspond to input variables.');
end

end
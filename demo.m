% Demo for emmeans

clear all

% load data
load carbig
t = table(Acceleration, Cylinders, Displacement, Horsepower, cellstr(Mfg), Model_Year, MPG, cellstr(Origin), Weight,...
    'VariableNames',{'acc','cyl','disp','hp','mfg','year','mpg','orig','wgt'});
% predict MPG but interested in Origin differences so make fixed effect
mdl = fitglme(t,'mpg~orig + acc + cyl + disp + hp + wgt + (1|mfg) + (1|year)', 'DummyVarCoding', 'effects');

% analyze and update model to be parsimonious
% % NOTE: emmeans does not yet work with continutous variable interactions!
anova(mdl); % shows 'acc' not significant
mdl = fitglme(t,'mpg~orig + cyl + disp + hp + wgt + (1|mfg) + (1|year)', 'DummyVarCoding', 'effects');
anova(mdl); % shows 'cyl' not significant
mdl = fitglme(t,'mpg~orig + disp + hp + wgt + (1|mfg) + (1|year)', 'DummyVarCoding', 'effects');

% use emmeans
emm = emmeans(mdl, {'orig'}, 'effects');
h = emmip(emm,'orig');

% change plot order
emm_relvl = relevel_table(emm,{'orig'}, {'USA','Sweden','Germany','England','Japan','France','Italy'});
h = emmip(emm_relvl,'orig');

% hypothesis testing (use emm that has not been releveled)
% joint test that USA is different 
L_usa = [ strcmp(emm.table.orig,'USA')' - strcmp(emm.table.orig,'France')';
          strcmp(emm.table.orig,'France')' - strcmp(emm.table.orig,'Japan')';
          strcmp(emm.table.orig,'Japan')' - strcmp(emm.table.orig,'Germany')';
          strcmp(emm.table.orig,'Germany')' - strcmp(emm.table.orig,'Sweden')';
          strcmp(emm.table.orig,'Sweden')' - strcmp(emm.table.orig,'Italy')';
          strcmp(emm.table.orig,'Italy')' - strcmp(emm.table.orig,'England')';
          strcmp(emm.table.orig,'England')' - strcmp(emm.table.orig,'USA')';]; % double centered
H0_usa = contrasts_wald(mdl,emm,L_usa);
% specific test that USA and Sweden are different 
L_swede = strcmp(emm.table.orig,'USA')' - strcmp(emm.table.orig,'Sweden')';
H0_swede = contrasts_wald(mdl,emm,L_swede);


% this cell file plots figures

%%
load bubble_figure_data.mat

%% 
save bubble_figure_data.mat

%%
folder='/Users/xs1/Documents/ORNL/Bubble growth/Supporting figures/';
%% electron dose figure
f=figure;
f.PaperPosition=[1 1 4 3.5];
hold all
step=2;
plot(1,slope_40K,'ks');
plot(4,slope_80K,'rd');
plot(16,slope_160K,'ob');
box on
ax=gca;
ax.XLabel.String='Electron dose (nm)';
ax.XLabel.FontSize=10;
ax.YLabel.String='Growth rate nm^2/s';
ax.YLabel.FontSize=10;
xlim([0.5 16.5]);
ylim([0 450]);
print(f,'-dpng','-r300',[folder 'growth_rate.png']);

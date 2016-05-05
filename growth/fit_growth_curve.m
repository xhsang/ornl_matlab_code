function param=fit_growth_curve(time_axis,y,verbose)

[xData, yData] = prepareCurveData( time_axis(1:end), y(1:end) );

% Set up fittype and options.
ft = fittype( 'power1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [31.1414058606188 0.411768938900138];

% Fit model to data.
[fitresult1, gof] = fit( xData, yData, ft, opts );
fit_coeff=coeffvalues(fitresult1);


% % use a customized function
% ft = fittype( 'a*(x-d)^b', 'independent', 'x', 'dependent', 'y' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [fit_coeff(1) fit_coeff(2) 0];
% opts.Lower = [fit_coeff(1)-20 fit_coeff(2)-0.1 -10];
% opts.Upper = [fit_coeff(1)+20 fit_coeff(2)+0.1 10];
% % Fit model to data.
% [fitresult, gof] = fit( xData, yData, ft, opts );
% Plot fit with data.

if verbose == 1
    figure( 'Name', 'untitled fit 1' );
    h = plot( fitresult1, xData, yData );
    legend( h, 'y vs. time_axis', 'untitled fit 1', 'Location', 'NorthEast' );
    % Label axes
    xlabel time_axis
    ylabel y
    grid on
end
param=coeffvalues(fitresult1);
end



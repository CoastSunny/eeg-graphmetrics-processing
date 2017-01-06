% resultStrs = {'wpli_debiased_alpha','wpli_debiased_beta', ...
%     'wpli_debiased_broadband','wpli_debiased_theta'};

resultStrs = {'coh_alpha_neighbRemoved', ...
    'coh_broadband_neighbRemoved', 'coh_theta_neighbRemoved', ...
    'coh_alpha', 'coh_broadband', ...
    'coh_theta', 'pli_alpha', 'pli_beta', 'pli_broadband', ...
    'pli_theta',  'wpli_debiased_alpha','wpli_debiased_beta', ...
    'wpli_debiased_broadband','wpli_debiased_theta'};

cd('/Users/Bauke/_Research/EEG_10MndPilot_TestRetest/results')
resultStrs = {'pli_alpha'};

for i = 1:length(resultStrs)
    calculateGraphMetrics(resultStrs{i}, 0, 'proportional')
end

graphMetricsStr = resultStrs;

for i = 1:length(graphMetricsStr)
    calculateICC(graphMetricsStr{i})
end
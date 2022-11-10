function [behData] = K1_getBehavioural(expData, behData)

% Totals for participant

orange_total = length(find(expData.blackOrange == 1));
orange_SPresponse = length(find(strcmp(expData.RecodingOL, 'orangeResponse_SPkey')));
orange_AWresponse = length(find(strcmp(expData.RecodingOL, 'orangeResponse_AWkey')));
selfPaced_SP = length(find(strcmp(expData.RecodingOL, 'selfPaced_SPkey')));

behData = [behData; orange_total, orange_SPresponse, orange_AWresponse, selfPaced_SP];


end

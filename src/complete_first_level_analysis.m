function [] = complete_first_level_analysis(subject)
    param_smooth = [5;8];
    param_reg = [0,6,24];
    param_der = [0,1];
    for i=1:length(param_smooth)
        preprocessing(subject,param_smooth(i))
        for j=1:length(param_reg)
            for k=1:length(param_der)
                first_level_analysis(subject,param_smooth(i),param_reg(j),param_der(k))
            end
        end
    end    
end
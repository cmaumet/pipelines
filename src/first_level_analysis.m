function [] = first_level_analysis(subject,smooth_value,reg,der)


    % We carry out the first-level analysis for the smooth, regressors and
    % derivatives parameters entered as input. The subject variable is the
    % 6-digit subject id. smooth_value can either be equal to 5 or to 8.
    % reg can be equal to 0, 6 or 24, depending on whether one wants to
    % include no motion regressors, 6 motion regressors or 24 (motion regressors +
    % derivatives, squares and squares of derivatives) in the GLM model.
    % der is worth 1 if the temporal derivatives of the main regressors
    % have to be included, 0 otherwise.
    
    
    data_path = fileparts(mfilename('fullpath'));
    if isempty(data_path), data_path = pwd; end   

    spm('Defaults','fMRI');
    spm_jobman('initcfg');
    
    subject = char(string(subject));
    smooth_value = char(string(smooth_value));
    reg = char(string(reg));
    der = char(string(der));
    f = spm_select('FPList', fullfile(data_path,'data',subject,'unprocessed','3T','tfMRI_MOTOR_LR'), strcat('^',subject,'_3T_tfMRI_MOTOR_LR.nii$'));

    clear matlabbatch
    
    
    
    
    % Since the preprocessed data is needed for the first-level analysis,
    % we do the preprocessing if it has not already been done for the
    % smoothing value which has been entered.
    
    if not(isfile(fullfile('data',subject,'unprocessed','3T','tfMRI_MOTOR_LR',['s',smooth_value,'wr',subject,'_3T_tfMRI_MOTOR_LR.nii']))) 
        preprocessing(subject, smooth_value);
    end
    
    
    
    % The EVs duration and amplitude are always equals to 12 and 1, according
    % to the description of the motor paradigm on the HCP protocol details
    % web page. THe onsets are stored in FSL format, so we build an ev.mat
    % file within the subject directory if it has not already been done in
    % order to indicate the onset times, thanks to an auxiliary function
    % extract_ev.

    if not(isfile(fullfile('data',subject,'ev.mat')))
        ev = extract_ev(subject);
        save(fullfile('data',subject,'ev.mat'),'ev')
    end
    
    onsets    = load(fullfile(data_path,'data',subject,'ev.mat'));

    
    
    
    % We run the first-level analysis if it has not already been done for
    % the parameters which have been entered as input. The resulting design
    % matrix SPM.mat is stored in the directory
    % {subject}/analysis/smooth_i/reg_j/der_k/, as well as the estimated
    % parameters Beta_i.
    
    if not(isfile(fullfile(data_path,'data',subject,'analysis',['smooth_',smooth_value],['reg_',reg],['der_',der],'SPM.mat')))
        matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(data_path,'data',subject,'analysis',['smooth_',smooth_value],['reg_',reg],['der_',der])};
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.753521126760563;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

        if der == '1'
            matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
        elseif der == '0'
            matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        end

        if reg == '6'
            matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {fullfile(data_path,'data',subject,'unprocessed','3T','tfMRI_MOTOR_LR',['rp_',subject,'_3T_tfMRI_MOTOR_LR.txt'])};
        elseif reg == '24'
            matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {fullfile(data_path,'data',subject,'unprocessed','3T','tfMRI_MOTOR_LR',['rp24_',subject,'_3T_tfMRI_MOTOR_LR.txt'])};
        end    
        matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

        %%
        matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_file(f,'prefix',['s',smooth_value,'wr']));

        %%
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'lf';
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = onsets.ev(1,:);
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 12;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'lh';
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = onsets.ev(2,:);
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 12;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'rf';
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = onsets.ev(3,:);
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 12;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'rh';
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = onsets.ev(4,:);
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = 12;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).orth = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 't';
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = onsets.ev(5,:);
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = 12;


        matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(data_path,'data',subject,'analysis',['smooth_',smooth_value],['reg_',reg],['der_',der],'SPM.mat'));

        
        nparam = (5 * str2num(der)) + str2num(reg);

     	matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(data_path,'data',subject,'analysis',['smooth_',smooth_value],['reg_',reg],['der_',der],'SPM.mat'));
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'LF';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1,zeros(1,nparam)];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 0;

        spm_jobman('run',matlabbatch);
        clear matlabbatch;
    end
end

function [] = preprocessing(sujet,smooth)

    data_path = fileparts(mfilename('fullpath'));
    if isempty(data_path), data_path = pwd; end    
    % chemin du dossier

    
    spm('Defaults','fMRI');
    spm_jobman('initcfg');

    clear matlabbatch;
    
    
    
    
    % On convertit le numéro de sujet en char pour construire les noms de
    % dossiers et de fichiers par la suite

    sujet = char(string(sujet))
    
    
    
    
    % On dezippe les fichiers téléchargés si ce n'est pas déjà fait

    if not(isdir(strcat(sujet,'/unprocessed/3T/T1w_MPR1')))
        unzip(strcat(sujet,'_3T_Structural_unproc.zip'));
    end    

    if not(isfile(strcat(sujet,'/unprocessed/3T/T1w_MPR1/',sujet,'_3T_T1w_MPR1.nii')))
        gunzip(strcat(sujet,'/unprocessed/3T/T1w_MPR1/',sujet,'_3T_T1w_MPR1.nii.gz'));
    end
 
    if not(isdir(strcat(sujet,'/unprocessed/3T/tfMRI_MOTOR_LR')))
        unzip(strcat(sujet,'_3T_tfMRI_MOTOR_unproc.zip'));
    end    

    if not(isfile(strcat(sujet,'/unprocessed/3T/tfMRI_MOTOR_LR/',sujet,'_3T_tfMRI_MOTOR_LR.nii')))
        gunzip(strcat(sujet,'/unprocessed/3T/tfMRI_MOTOR_LR/',sujet,'_3T_tfMRI_MOTOR_LR.nii.gz'));
    end
    
    
    % On construit des variables qui contiennent les chemins complets des 
    % fichiers fonctionnels et anatomiques
    
    f = spm_select('FPList', fullfile(data_path,sujet,'unprocessed/3T/tfMRI_MOTOR_LR'), strcat('^',sujet,'_3T_tfMRI_MOTOR_LR.nii$'));
    a = spm_select('FPList', fullfile(data_path,sujet,'unprocessed/3T/T1w_MPR1'), strcat('^',sujet,'_3T_T1w_MPR1.nii$'));
    
    
    
    
    % On effectue le recalage des images fonctionnelles si celui-là n'a pas
    % déjà été fait        

    if not(isfile(strcat(sujet,'/unprocessed/3T/tfMRI_MOTOR_LR/r',sujet,'_3T_tfMRI_MOTOR_LR.nii')))
        matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = cellstr(f);
        spm_jobman('run',matlabbatch);
        clear matlabbatch;
    end
    
    system(['bash mp_diffpow24.sh ',sujet,'/unprocessed/3T/tfMRI_MOTOR_LR/rp_',sujet,'_3T_tfMRI_MOTOR_LR.txt ',sujet,'/unprocessed/3T/tfMRI_MOTOR_LR/rp24_',sujet,'_3T_tfMRI_MOTOR_LR.txt']);
    
    % idem avec la normalisation
        
    if not(isfile(strcat(sujet,'/unprocessed/3T/tfMRI_MOTOR_LR/wr',sujet,'_3T_tfMRI_MOTOR_LR.nii')))
        matlabbatch{1}.spm.spatial.coreg.estimate.ref    = cellstr(spm_file(f,'prefix','mean'));
        matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(a);

        matlabbatch{2}.spm.spatial.preproc.channel.vols  = cellstr(a);
        matlabbatch{2}.spm.spatial.preproc.channel.write = [0 1];
        matlabbatch{2}.spm.spatial.preproc.warp.write    = [0 1];

        defo = cellstr(spm_file(a,'prefix','y_','ext','nii'));

        matlabbatch{3}.spm.spatial.normalise.write.subj.def      = cellstr(defo);
        matlabbatch{3}.spm.spatial.normalise.write.subj.resample = cellstr(char(spm_file(f,'prefix','r'),spm_file(f,'prefix','mean')));
        matlabbatch{3}.spm.spatial.normalise.write.woptions.vox  = [3 3 3];

        matlabbatch{4}.spm.spatial.normalise.write.subj.def      = cellstr(defo);
        matlabbatch{4}.spm.spatial.normalise.write.subj.resample = cellstr(char(spm_file(a,'prefix','m','ext','nii')));
        matlabbatch{4}.spm.spatial.normalise.write.woptions.vox  = [1 1 1.5];

        spm_jobman('run',matlabbatch);
        clear matlabbatch;    
    end
    
    
    
    
    % on effectue le lissage en fonction de la valeur de smooth, si
    % celui-ci n'a pas déjà été fait ; on a la séquence pré-traitée
    % complète dans le fichier avec le préfixe sXwr, X étant le paramètre
    % de lissage
    
    if smooth == 8
        if not(isfile(strcat(sujet,'/unprocessed/3T/tfMRI_MOTOR_LR/s8wr',sujet,'_3T_tfMRI_MOTOR_LR.nii')))            
            matlabbatch{1}.spm.spatial.smooth.data = cellstr(spm_file(f,'prefix','wr'));
            matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
            matlabbatch{1}.spm.spatial.smooth.prefix = 's8';
            spm_jobman('run',matlabbatch);
            clear matlabbatch;    
        end
    elseif smooth == 5
        if not(isfile(strcat(sujet,'/unprocessed/3T/tfMRI_MOTOR_LR/s5wr',sujet,'_3T_tfMRI_MOTOR_LR.nii')))            
            matlabbatch{1}.spm.spatial.smooth.data = cellstr(spm_file(f,'prefix','wr'));
            matlabbatch{1}.spm.spatial.smooth.fwhm = [5 5 5];
            matlabbatch{1}.spm.spatial.smooth.prefix = 's5';
            spm_jobman('run',matlabbatch);
            clear matlabbatch;    
        end    
    end
    
    clean(sujet)
    
end

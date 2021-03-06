function [ c_struct ] = VoxelStatsPairedT( imageType, data_file, contrastColumnId1, contrastColumnId2, includeString, mask_file )
    mainDataTable = readtable(data_file, 'delimiter', ',', 'readVariableNames', true);
    
    if length(includeString) > 0
        incStr = strrep(includeString, 'mdt.', 'mainDataTable.');
        eval(['mainDataTable_rows = ' incStr ';']);
        mainDataTable = mainDataTable(mainDataTable_rows, :);
    end
    
    %%Get Mask data
    [slices, image_height, image_width, mask_slices, voxel_dims, slices_data] = readMaskSlices(imageType, mask_file);
    image_elements = image_height * image_width;
    
    switch imageType
        case {'mnc','MNC', 'minc', 'MINC'}
            eval(['group1data = readmultiValuedMincData(mainDataTable.' contrastColumnId1 ',' num2str(slices) ', mask_slices);']);
            eval(['group2data = readmultiValuedMincData(mainDataTable.' contrastColumnId2 ',' num2str(slices) ', mask_slices);']);
        case {'nii','NII', 'nifti', 'NIFTI'}
            eval(['group1data = readmultiValuedNiftiData(mainDataTable.' contrastColumnId1 ',' num2str(slices) ', mask_slices);']);
            eval(['group2data = readmultiValuedNiftiData(mainDataTable.' contrastColumnId2 ',' num2str(slices) ', mask_slices);']);
        otherwise
            fprintf('Unknown Image type')
            exit
    end
    [h, p, ci, t] = ttest(group1data, group2data);
    
    result_h = zeros(image_elements, slices);
    result_h(mask_slices) = h;
    
    result_p = zeros(image_elements, slices);
    result_p(mask_slices) = p;
    
    result_t = zeros(image_elements, slices);
    result_t(mask_slices) = t.tstat;
    
    c_struct = struct('hValues', result_h, 'pValues', result_p, 'tValues', result_t);

end

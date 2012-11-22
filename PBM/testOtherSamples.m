%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('../helpfun');
addpath('../kdes');
addpath('../emk');
addpath('../myfun');
%addpath('../demo_rgbd/predictProcess');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FULL, LEFT, RIGHT, TOP, BOTTOM
USE_PART_MODEL = 4;
%model{1} = full;
model{1} = left;
model{2} = right;
model{3} = top;
model{4} = bottom;
imdir = '../images/Model/full/';
disp( imdir );

imsubdir = dir_bo(imdir);
impath = [];
rgbdclabel = [];
rgbdilabel = [];
rgbdvlabel = [];
subsample = 5;
disp(['subsample is ' num2str(subsample)]);
label_num = 0;

other = 1;
if other
for i = 1:length(imsubdir)
    [rgbdilabel_tmp, impath_tmp] = get_im_label([imdir imsubdir(i).name '/'], '_crop.png');
    for j = 1:length(impath_tmp)
        ind = find(impath_tmp{j} == '_');
        rgbdvlabel_tmp(1,j) = str2num(impath_tmp{j}(ind(end-2)+1));
    end

    it = 0;
    for j = 1:1:length(impath_tmp)
        if mod(j-1, subsample) == 0
            continue;
        end
        it = it + 1;
        impath_tmp_sub{it} = impath_tmp{j};
        rgbdvlabel_tmp2(1,it) = rgbdvlabel_tmp(1,j);
        rgbdilabel_tmp2(1,it) = rgbdilabel_tmp(1,j);
    end
    impath = [impath impath_tmp_sub];
    rgbdclabel = [rgbdclabel i*ones(1,length(impath_tmp_sub))];
    rgbdilabel = [rgbdilabel rgbdilabel_tmp2(1:1:end)+label_num];
    rgbdvlabel = [rgbdvlabel rgbdvlabel_tmp2(1:1:end)];
    label_num = label_num + length(unique(rgbdilabel_tmp2));
    clear impath_tmp_sub rgbdvlabel_tmp;
    clear rgbdvlabel_tmp2 rgbdilabel_tmp2 rgbdvlabel_tmp rgbdilabel_tmp;
end
end

same = 0;
if same
for i = 1:length(imsubdir)
    [rgbdilabel_tmp, impath_tmp] = get_im_label([imdir imsubdir(i).name '/'], '_depthcrop.png');
    for j = 1:length(impath_tmp)
        ind = find(impath_tmp{j} == '_');
        rgbdvlabel_tmp(1,j) = str2num(impath_tmp{j}(ind(end-2)+1));
    end

    it = 0;
    for j = 1:subsample:length(impath_tmp)
        it = it + 1;
        impath_tmp_sub{it} = impath_tmp{j};
    end
    impath = [impath impath_tmp_sub];
    rgbdclabel = [rgbdclabel i*ones(1,length(impath_tmp_sub))];
    rgbdilabel = [rgbdilabel rgbdilabel_tmp(1:subsample:end)+label_num];
    rgbdvlabel = [rgbdvlabel rgbdvlabel_tmp(1:subsample:end)];
    label_num = label_num + length(unique(rgbdilabel_tmp));
    clear impath_tmp_sub rgbdvlabel_tmp;
end
end

cnt_correct = 0;
cnt_wrong = 0;
for i = 1:length(impath)
    disp( ['Image No.' num2str(i) ' ClassLabel:' num2str(rgbdclabel(1,i)) ' ' impath{i}] );
    rgb = imread( impath{i} );
    dep = imread([impath{i}(1:end-8) 'depthcrop.png']);
    loc = fliplr(load([impath{i}(1:end-8) 'loc.txt']));
    
    %% Part-based ModelProcess 
    for j = 1:USE_PART_MODEL
        disp('  ');
    
        [dec, lab, features, name] = process_PartBasedModel( 'rgb', rgb, model{j} );

        part_decvalue{j} = dec;
        part_label{j} = lab;
    end
    
    [ finaldecvalue, finallabel ] = combineModel( part_decvalue, part_label, combinemodel, minvalue, maxvalue );
    disp( [ 'Detected Object is ' name{finallabel} ] );
    
    store_name{i,1} = i; 
    store_name{i,2} = rgbdclabel(1,i); 
    store_name{i,3} = impath{i};
    store_fd{i} = finaldecvalue;
    store_fl(i) = finallabel;
    
    if finallabel == rgbdclabel(1,i)
        cnt_correct = cnt_correct + 1;
        disp('###############Correct###############');
    else
        cnt_wrong = cnt_wrong + 1;
        disp('#############Not Correct#############');
    end
    %%    
end
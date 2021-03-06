function pca_sh_error_pcws()

dbs = {'cipic'};

for db=1:length(dbs)

 	% Load Error File
    error_data = sprintf('../matlabdata/test_pca_sh/variance_error_pca_sh_%s_new_reg.mat',dbs{db});
    load(error_data,'conf','error');
    
    % Disp conf
    conf
    clearvars Y
   
    data_weight = error.weight_model.weight_error;
    %data_shape = error.weight_model.shape_error;
    angles = conf.database.angles;
    
    % Load Angles from database  
    az_unique = unique(angles(:,1));
    el_unique = unique(angles(:,2));
    
    
        % do through all parameters and create/save diagrams
        for im = 1:length(conf.input_modes)
            for is = 1:length(conf.input_structures)
                for sm = 1:length(conf.smoothing)
                    for em = 1:length(conf.ear_modes)
                        for ear = 1:length(conf.ears)
                            for sh = 1:length(conf.sh_orders)
                                for reg = 1:length(conf.regularize)
                                    for pc=1:length(conf.pc_numbers)
                                    X = squeeze(data_weight(1,1,1,ear,im,is,em,sm,pc,sh,reg,:,:,:,:));    
                                    
                                    X = squeeze(mean(X,3)); % mean over bins
                                    X = squeeze(mean(X,1)); % mean over sub
                                        for el=1:length(el_unique)
                                            for az=1:length(az_unique)
                                            Y(az,el) = 0; 

                                            answ = 0;
                                            offset = 0;
                                                while true 

                                                    [Y,answ] = SearchNextPos(Y,X,conf,az,el,az_unique,el_unique,offset);
                                                    if (answ == 1)
                                                    break
                                                    end
                                                    offset = offset +2.5;
                                                end  

                                            end
                                        end                            


                                        figure(11)
                                        clf;
                                        surface(el_unique,az_unique,abs(Y),'EdgeColor', 'none');
                                        colorbar
                                        xlim([-45 ])
                                        
                                        % Save as EPS
                                        set(11,'paperunits','centimeters','paperposition',[1 1 17 12])
                                        saveas(11,sprintf('../thesis/images/test_pca_sh/weight_error/%s_sh_order%i_pc%i_reg%i',dbs{db},conf.sh_orders(sh),conf.pc_numbers(pc),conf.regularize(reg)),'epsc');

                                    end

                                end
                            end
                                 
                        end
                    end
                end
            end
        end
  
end
end


function [Y,answ] = SearchNextPos(Y,Z,conf,az,el,az_unique,el_unique,offset)

pos_ind = find(conf.database.angles(:,2) == el_unique(el) & (conf.database.angles(:,1) >= az_unique(az)-offset)  &  (conf.database.angles(:,1) <= az_unique(az)+offset) );


if (isempty(pos_ind)) 
   Y(az,el) = 0;
   answ = 0;
else
   Y(az,el) = squeeze(Z(:,pos_ind(1)));
   answ = 1;
end

end

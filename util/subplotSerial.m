function fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,header,str,math,option) 
    narginchk(7,8)

    if(nargin==8)
        if(strcmp(option,'largeFont'))
            font_size = 27;
            xlabel_offset = 5;
            vspan = 0.11;
        elseif(strcmp(option,'smallGraph'))
            font_size = 27;
            xlabel_offset = 1;
            vspan = 0.11;
        elseif(strcmp(option,'smallGraph2'))
            font_size = 12;
            xlabel_offset = 9;
            vspan = 0.07;
        end
    else
        font_size = 10;
        xlabel_offset = 15;
        vspan = 0.1;
    end

    nl = sprintf('\n');
    [c,r] = ind2sub([img_cols img_rows],fig_idx);
    hspan = 0.005;

    subplot('Position',[(c-1)/img_cols+hspan/2, 1-(r)/img_rows+vspan/1.5, 1/img_cols-hspan, 1/img_rows-vspan])
%     subplot(img_rows,img_cols,fig_idx);
    imshow(I,'border','tight')
    if(~isempty(header))
        title(header)
    end
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    fig_idx = fig_idx + 1;
end


function logError( ME )
    fprintf('%s\n',ME.getReport('extended'));
    fid = fopen('errorLog.txt','a+');
    fprintf(fid, '\n\n==============================\n\n%s', ME.getReport('extended', 'hyperlinks','off'));
    fclose(fid);
end


%% Leer archivos sísmicos
% *************************************************************************
% Autor: Santiago Quiñones Cuenca
% Creative Commons License: CC BY-NC-ND 3.0
% lsquinones@gmail.com
% 25/06/2016
%*************************************************************************


function [matrizDeSismos, arrTiempo, arrCantidadElementos] = leerSismos(directory_name)
%LEERSISMOS read files of earquakes
%
% SYNOPSIS: [a, b, c]=leerSismos(b)
% INPUT b: directory name
% OUTPUT a: matrix of eartquakes
%        b: matrix of time
%        c: matrix - number of data for file

    % ruta del archivo con los datos formateados (sin tabuladores, sin
    % espacios en blanco)
    fileFormat = strcat(directory_name, '\file.temp');
    
    % factores de tiempo
    arrTiempo = [];
    arrCantidadElementos = [];
    
    if exist(fileFormat, 'file')==2
       delete(fileFormat);
    end
    
    % convierte en un dato de tipo directorio
    files = dir(directory_name);
    
    % indexa todos los archivos que se encuentran en la carpeta
    fileIndex = find(~[files.isdir]);
    
    % matriz donde se almacenara los registros sismicos
    matrizDeSismos = {};

    try
        for i = 1:length(fileIndex)
            % obtiene el nombre del archivo
            fileName = files(fileIndex(i)).name;

            % captura la ruta completa del archivo
            pathfile = strcat(directory_name, '\', fileName); 

            % genera el archivo temporal sin espacios ni tabuladores
            % y devuelve el número de líneas de la cabecera y el factor de
            % tiempo
            [factorTiempo, nroLineasExcluir] = prepararRegistros(pathfile, fileFormat);

            %almacena el factor de tiempo
            arrTiempo(end+1) = factorTiempo;

            % el espacio es el separador entre valores, y el 4 indica 
            % las líneas a excluir
            
            matrizDeSismos(end + 1) = {dlmread(fileFormat,' ',nroLineasExcluir,0)}; 

            % determina la cantidad de elementos
            [x y] = size(matrizDeSismos{end});
            aux = matrizDeSismos{end};
            arrCantidadElementos(end+1) = (x * y) - sum(aux(end,:)==0);

            % si el archivo es de PEER se ajusta los datos multiplicando por
            % 980
            if nroLineasExcluir == 1
                matrizDeSismos{end} = matrizDeSismos{end} .* 981;
            end

        end
    catch
        disp('Error al cargar los datos a las matrices');
    end
    
    % borra el archivo temporal
    delete(fileFormat);
end

% recibe los archivos sísmicos y los convierte a un formato general donde 
% los separadores son espacios
function[factorTiempo, nroLineasEncabezado] = prepararRegistros(pathFileInput, pathFileFormat)
    factorTiempo = 0.015;
    nroLineasEncabezado = 1;

    finput = fopen(pathFileInput, 'r');
    ftemp = fopen(pathFileFormat, 'w' );
    
    
    try
        % lee la primera línea del archivo 
        tline = fgetl(finput);

        buscar = findstr('RENAC', tline);

        %disp(strcat('Procesando archivo >> ', pathFileInput))
        if buscar > 0 % si existe algun archivo RENAC
            tline = fgetl(finput);
            tline = fgetl(finput);
            tline = fgetl(finput);
            tline = fgetl(finput);
            tline = fgetl(finput);
            tline = fgetl(finput);
            tline = fgetl(finput);
            
            % obtiene el factor de tiempo de los archivos RENAC
            aux  = tline;
            aux = strtrim(aux);
            aux = regexprep(aux, '\s+', ' ');
            datos = strread(aux, '%s');
            factorTiempo = 1 / str2double(datos(5));
            nroLineasEncabezado = 3;
        else
            tline = fgetl(finput);
            tline = fgetl(finput);
            tline = fgetl(finput);

            % obtiene el factor de tiempo de los archivos PEER
            aux  = tline;
            aux = strtrim(aux);
            aux = regexprep(aux, '\s+', ' ');
            datos = strread(aux, '%s');
            factorTiempo = str2double(datos(4));
        end

        while ischar(tline)
          tline = strtrim(tline);
          tline = regexprep(tline, '\s+', ' ');
          fprintf( ftemp, '%s\n', tline);
          tline = fgetl(finput);
        end
    
    catch
        disp('Error al preparar archivos.');
    end
    
    fclose(ftemp);
    fclose(finput);
end

classdef filtros_trab1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        CancelarFiltroButton      matlab.ui.control.Button
        EditField3                matlab.ui.control.NumericEditField
        EditField3Label           matlab.ui.control.Label
        EditField2                matlab.ui.control.NumericEditField
        EditField2Label           matlab.ui.control.Label
        EditField                 matlab.ui.control.NumericEditField
        EditFieldLabel            matlab.ui.control.Label
        EscolhaumaOpoButtonGroup  matlab.ui.container.ButtonGroup
        Op4Button                 matlab.ui.control.RadioButton
        Op3Button                 matlab.ui.control.RadioButton
        Op2Button                 matlab.ui.control.RadioButton
        Op1Button                 matlab.ui.control.RadioButton
        EscolhaumaimagemPanel     matlab.ui.container.Panel
        Image2                    matlab.ui.control.Image
        FiltrosDropDown           matlab.ui.control.DropDown
        FiltrosDropDownLabel      matlab.ui.control.Label
        umaimageumfiltroumsonhoandCUTIELabel  matlab.ui.control.Label
        ImagemButton              matlab.ui.control.Button
        AplicarFiltroButton       matlab.ui.control.Button
    end

  
    properties (Access = private) %criando as variaveis do sistema
         folderPath = "";
         imageName = "";
         indice = 0;
         tam_vet = 0;
         vetorImg = {};
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ImagemButton
        function ImagemButtonPushed(app, event)
            %pego o nome da imagem e o caminho pela funcao q abre a janelinha
            [filename, pathname] = uigetfile('*', "Escolha uma Imagem"); 
            app.imageName = filename;

            filename = strcat (pathname, filename);
            if(filename ~= "")
                app.Image2.ImageSource = filename;                

                app.indice = app.indice + 1;
                app.tam_vet = app.tam_vet + 1;
                app.vetorImg{app.indice} = filename;

            end 
            
        end

        % Button pushed function: AplicarFiltroButton
        function AplicarFiltroButtonPushed(app, event)
            valor = app.EditField.Value;
            %disp(valor);
            imgPath = app.Image2.ImageSource;

            if imgPath ~= ""
                img = imread(imgPath);
                %disp(app.FiltrosDropDown.Value);

                switch app.FiltrosDropDown.Value
                    case "Threshold"
                       if valor > 0 && valor < 1
                           try
                               img = im2gray (img);
                                BW = imbinarize(img, valor);
                                %imshow(BW);

                                savedFileName = "Imagem_Binarizada_" + app.imageName + ".png"; %cria o nome da imagem alterada para salvar
                                savedPathImg = fullfile(app.folderPath, savedFileName); %caminho da iamgem
                                imwrite(BW, savedPathImg); %salva a imagem no camigo do matlab
                                app.Image2.ImageSource = savedPathImg; %atualiza a imagem na tela da interface

                                app.indice = app.indice + 1;
                                app.tam_vet = app.tam_vet + 1;
                                app.vetorImg{app.indice} = savedPathImg;
                           catch ME
                               disp('Erro ao aplicar filtro:');
                               disp(ME.message);
                           end
                       else
                            disp('Erro ao aplicar filtro: o valor tem que esta entre 0 e 1');
                       end

                    case "Escala de Cinza"
                        try
                            cinza = rgb2gray(img);
                            
                            savedFileName = "Escala_de_Cinza_" + app.imageName + ".png"; 
                            savedPathImg = fullfile (app.folderPath, savedFileName); 
                            imwrite(cinza, savedPathImg);
                            app.Image2.ImageSource = savedPathImg;

                            app.indice = app.indice + 1;
                            app.tam_vet = app.tam_vet + 1;
                            app.vetorImg{app.indice} = savedPathImg;
                        catch ME
                            disp('Erro ao aplicar filtro:');
                            disp(ME.message);
                        end

                    case "Passa-Alta"
                        img = im2gray(img); %se a imgem nao eh cinza, tranforma em cinza
                        selectedOption = app.EscolhaumaOpoButtonGroup.SelectedObject;
                        switch selectedOption
                            case app.Op1Button
                                try
                                    kernal = app.EditField.Value;
                                    kernelPassaAlta = [-1, -1, -1; -1, kernal, -1; -1, -1, -1];
                                    imgBasica = imfilter(img, kernelPassaAlta, 'replicate');
        
                                    savedFileName = "PassaAlta_Basico_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite (imgBasica, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end
                            case app.Op2Button
                                a = app.EditField.Value;
                                if a > 1
                                    try
                                        img = imread(app.Image2.ImageSource);
                                        h = fspecial('gaussian', 5, 2.5);
                                        imgSuavizada = imfilter(img, h);
                                        % Calcular o filtro passa-alta
                                        imgPassaAlta = img - imgSuavizada;
                                        % Aplicar o filtro de alto reforço
                                        imgAltoReforco = a * img + imgPassaAlta;
    
                                        savedFileName = "PassaAlta_AltoReforco" + app.imageName + ".png";
                                        savedPathImg = fullfile(app.folderPath, savedFileName);
                                        imwrite(imgAltoReforco, savedPathImg);
                                        app.Image2.ImageSource = savedPathImg;

                                        app.indice = app.indice + 1;
                                        app.tam_vet = app.tam_vet + 1;
                                        app.vetorImg{app.indice} = savedPathImg;
                                    catch ME
                                        disp('Erro ao aplicar filtro:');
                                        disp(ME.message);
                                    end
                                else
                                    disp('Erro ao aplicar filtro: o valor eh menor que 1');
                                end
                        end

                    case "Passa-Baixa"
                        selectedOption = app.EscolhaumaOpoButtonGroup.SelectedObject;
                        switch selectedOption
                            case app.Op1Button
                                if valor > 0
                                    try
                                        img = im2gray(img);
                                        filtroMedia = fspecial('average', valor);%Cria um filtro de média valorxvalor                                   
                                        imagemSuavisada = imfilter(img, filtroMedia, 'replicate'); % Aplica o filtro à imagem

                                        savedFileName = "PassaBaixa_Medio_" + app.imageName + ".png";
                                        savedPathImg = fullfile(app.folderPath, savedFileName);
                                        imwrite(imagemSuavisada, savedPathImg);
                                        app.Image2.ImageSource = savedPathImg;

                                        app.indice = app.indice + 1;
                                        app.tam_vet = app.tam_vet + 1;
                                        app.vetorImg{app.indice} = savedPathImg;                                    
                                    catch ME
                                        disp('Erro ao aplicar filtro:');
                                        disp(ME.message);
                                    end
                                else
                                    disp('Erro ao aplicar filtro: o valor eh maior que 0');
                                end
                            case app.Op2Button
                                try
                                    linha = app.EditField.Value;
                                    coluna = app.EditField2.Value;
                                    
                                    imag = im2gray(img);
                                    tamanhoJanela = [linha, coluna];
                                    imgFiltrada = medfilt2(imag,tamanhoJanela);

                                    savedFileName = "PassaBaixa_Mediana_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(imgFiltrada, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg; 
                                     
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end
                        end

                    case "Roberts"                        
                        try
                            img = im2gray(img);
                            BW1 = edge(img,'roberts');

                            savedFileName = "Roberts_" + app.imageName + ".png";
                            savedPathImg = fullfile(app.folderPath, savedFileName);
                            imwrite(BW1, savedPathImg);
                            app.Image2.ImageSource = savedPathImg;

                            app.indice = app.indice + 1;
                            app.tam_vet = app.tam_vet + 1;
                            app.vetorImg{app.indice} = savedPathImg;
                        catch ME
                            disp('Erro ao aplicar filtro:');
                            disp(ME.message);
                        end

                    case "Prewitt"
                        img = im2gray(img);                        
                        selectedOption = app.EscolhaumaOpoButtonGroup.SelectedObject;

                        switch selectedOption
                            case app.Op1Button
                                try
                                    h = fspecial('prewitt');
                                    kph = imfilter(img, h);

                                    savedFileName = "Prewitt_Horizontal_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(kph, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end

                            case app.Op2Button
                                try
                                    h = fspecial('prewitt');
                                    kpv = imfilter(img, h');

                                    savedFileName = "Prewitt_Vertical_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(kpv, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end

                            case app.Op3Button
                                try
                                    h = fspecial('prewitt');
                                    ph = imfilter(img, h);
                                    pv = imfilter(img, h');
                                    hv = ph + pv;

                                    savedFileName = "Prewitt_Horizontal_Vertical_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(hv, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;

                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end

                            case app.Op4Button
                                try
                                    pedge = edge(img, 'Prewitt');

                                    savedFileName = "Prewitt_Edge_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(pedge, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end                        
                        end
                    case "Sobel"
                        img = im2gray(img);
                        h = fspecial('sobel');
                        selectedOption = app.EscolhaumaOpoButtonGroup.SelectedObject;

                        switch selectedOption
                            case app.Op1Button
                                try
                                    sh = imfilter(img, h);

                                    savedFileName = "Sobel_Horizontal_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(sh, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end 

                            case app.Op2Button
                                try
                                    sv = imfilter(img, h');
    
                                    savedFileName = "Sobel_Vertical_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(sv, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end 

                            case app.Op3Button
                                try
                                    sv = imfilter(img, h');
                                    sh = imfilter(img, h);
                                    shv = sh + sv;
    
                                    savedFileName = "Sobel_Horizontal_Vertical_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(shv, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end 

                            case app.Op4Button
                                try
                                    sedge = edge(img, 'sobel');
    
                                    savedFileName = "Sobel_Edge_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(sedge, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end 

                        end
                    case "Log"                        
                        img = im2gray(img);
                        try
                            sigma = app.EditField.Value;
                            tamMatrix = app.EditField2.Value;                               
                            %h = fspecial('log', tamMatrix, sigma);  
                            %k = imfilter(img, h); 
                            bw = edge(img, 'log', tamMatrix, sigma);


                            savedFileName = "Log_" + app.imageName + ".png";
                            savedPathImg = fullfile(app.folderPath, savedFileName);
                            imwrite(bw, savedPathImg);
                            app.Image2.ImageSource = savedPathImg;

                            app.indice = app.indice + 1;
                            app.tam_vet = app.tam_vet + 1;
                            app.vetorImg{app.indice} = savedPathImg;
                        catch ME
                            disp('Erro ao aplicar filtro:');
                            disp(ME.message);
                        end                        

                    case "Zerocross"
                        try
                            img = im2gray(img);
                            %threshold = app.EditField2.Value;
                            
                            h = fspecial('laplacian', 0.2);
                            BW = edge(img, 'zerocross', 0, h); %deteccao de edges usando o metodo zerocross

                            savedFileName = "Zerocross_" + app.imageName + ".png";
                            savedPathImg = fullfile(app.folderPath, savedFileName);
                            imwrite(BW, savedPathImg);
                            app.Image2.ImageSource = savedPathImg;

                            app.indice = app.indice + 1;
                            app.tam_vet = app.tam_vet + 1;
                            app.vetorImg{app.indice} = savedPathImg;
                        catch ME
                            disp('Erro ao aplicar filtro:');
                            disp(ME.message);
                        end

                    case "Canny"
                        img = im2gray(img);
                        try
                            BW = edge(img, 'canny');

                            savedFileName = "CAANNYYYYYYYYY_" + app.imageName + ".png";
                            savedPathImg = fullfile(app.folderPath, savedFileName);
                            imwrite(BW, savedPathImg);
                            app.Image2.ImageSource = savedPathImg;

                            app.indice = app.indice + 1;
                            app.tam_vet = app.tam_vet + 1;
                            app.vetorImg{app.indice} = savedPathImg;
                        catch ME
                            disp('Erro ao aplicar filtro:');
                            disp(ME.message);
                        end


                    case "Ruídos"
                        selectedOption = app.EscolhaumaOpoButtonGroup.SelectedObject;
                        switch selectedOption                         
                            case app.Op1Button
                                try
                                    var = app.EditField.Value;
                                    imgSpeckle = imnoise(img, 'speckle', var);

                                    savedFileName = "Ruido_Speckle_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(imgSpeckle, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end   
                            case app.Op2Button                                
                                  try 
                                     gauss = imnoise(img, 'gaussian');
    
                                     savedFileName = "Ruido_Gaussina_" + app.imageName + ".png";
                                     savedPathImg = fullfile(app.folderPath, savedFileName);
                                     imwrite(gauss, savedPathImg);
                                     app.Image2.ImageSource = savedPathImg;
    
                                     app.indice = app.indice + 1;
                                     app.tam_vet = app.tam_vet + 1;
                                     app.vetorImg{app.indice} = savedPathImg;
                                 catch ME
                                     disp('Erro ao aplicar filtro:');
                                     disp(ME.message);
                                  end 
                            case app.Op3Button
                                valor = app.EditField.Value;
                                if valor < 1
                                    try
                                        imgSaltPaper = imnoise(img, 'salt & pepper', valor);

                                        savedFileName = "Ruido_Salt_Paper_" + app.imageName + ".png";
                                        savedPathImg = fullfile(app.folderPath, savedFileName);
                                        imwrite(imgSaltPaper, savedPathImg);
                                        app.Image2.ImageSource = savedPathImg;

                                        app.indice = app.indice + 1;
                                        app.tam_vet = app.tam_vet + 1;
                                        app.vetorImg{app.indice} = savedPathImg;
                                    catch ME
                                        disp('Erro ao aplicar filtro:');
                                        disp(ME.message);
                                    end 
                                else
                                    disp('Erro ao aplicar filtro: o valor da densidade eh maior que 1');
                                end
                            case app.Op4Button
                                try
                                    imgPoisson = imnoise(img, 'poisson');

                                    savedFileName = "Ruido_Possion_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(imgPoisson, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;

                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end
                        end

                    case "Watershed"
                        selectedOption = app.EscolhaumaOpoButtonGroup.SelectedObject;
                        app.EditField.Visible = "off";
                        app.EditFieldLabel.Visible = "off";

                        img = im2gray(img);

                        switch selectedOption
                            case app.Op1Button
                                try
                                    gmag = imgradient(img);
                                    L = watershed(gmag);
                                    Lrgb = label2rgb(L);
                                    se = strel("disk",20);
                                    Io = imopen(img,se);    
                                    Ie = imerode(img,se);
                                    Iobr = imreconstruct(Ie,img);
                                    Ioc = imclose(Io,se);
                                    Iobrd = imdilate(Iobr,se);
                                    Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
                                    Iobrcbr = imcomplement(Iobrcbr);
                                    fgm = imregionalmax(Iobrcbr);
                                    I2 = labeloverlay(img,fgm);
                                    se2 = strel(ones(5,5));
                                    fgm2 = imclose(fgm,se2);
                                    fgm3 = imerode(fgm2,se2);
                                    fgm4 = bwareaopen(fgm3,20);
                                    I3 = labeloverlay(img,fgm4);
                                    bw = imbinarize(Iobrcbr);
                                    D = bwdist(bw);
                                    DL = watershed(D);
                                    bgm = DL == 0;
                                    gmag2 = imimposemin(gmag, bgm | fgm4);
                                    L = watershed(gmag2);
                                    labels = imdilate(L==0,ones(3,3)) + 2*bgm + 3*fgm4;
                                    I4 = labeloverlay(img,labels);
                                    Lrgb = label2rgb(L,"jet","w","shuffle");
                                    imshow(Lrgb);
                                    title("Colored Watershed Label Matrix");

                                    savedFileName = "Watershed_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(I4, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;
        
                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end

                            case app.Op2Button
                                try                            
                                    bw = imbinarize(img);                           
                                    ms = bwdist(~bw);
                                    ms = 255 - uint8(ms);
                                    hs = watershed(ms);
                                    ws = hs == 0;
                                    label = label2rgb(hs);
        
                                    img_result = (bw | ws);
                                    figure, imshow(label)
                                 
                                    savedFileName = "Watershed_" + app.imageName + ".png";
                                    savedPathImg = fullfile(app.folderPath, savedFileName);
                                    imwrite(img_result, savedPathImg);
                                    app.Image2.ImageSource = savedPathImg;
        
                                    app.indice = app.indice + 1;
                                    app.tam_vet = app.tam_vet + 1;
                                    app.vetorImg{app.indice} = savedPathImg;
                                catch ME
                                    disp('Erro ao aplicar filtro:');
                                    disp(ME.message);
                                end

                        end                                        
                        
                    case "Histograma"
                        app.EditField.Visible = "off";
                        app.EditFieldLabel.Visible = "off";

                        img = im2gray(img);
                        selectedOption = app.EscolhaumaOpoButtonGroup.SelectedObject;
                        switch selectedOption
                            case app.Op1Button
                                imhist(img);

                                %savedFileName = "Histograma" + app.imageName + ".png";
                                %savedPathImg = fullfile(app.folderPath, savedFileName);
                                %imwrite(img, savedPathImg);
                                %app.Image2.ImageSource = savedPathImg;

                            case app.Op2Button
                                imgEq = histeq(img);
                                figure, imhist(imgEq, 64);
                                title("Histograma Equalizado");

                                savedFileName = "Histograma_Equalizado_" + app.imageName + ".png";
                                savedPathImg = fullfile(app.folderPath, savedFileName);
                                imwrite(imgEq, savedPathImg);
                                app.Image2.ImageSource = savedPathImg; 

                                app.indice = app.indice + 1;
                                app.tam_vet = app.tam_vet + 1;
                                app.vetorImg{app.indice} = savedPathImg;

                            case app.Op3Button
                                imgAdEq = adapthisteq(img);
                                figure, imhist(imgAdEq, 64);
                                title("Histograma Adaptativo Equalizado");


                                savedFileName = "Histograma_Adap_Equalizado_" + app.imageName + ".png";
                                savedPathImg = fullfile(app.folderPath, savedFileName);
                                imwrite(imgAdEq, savedPathImg);
                                app.Image2.ImageSource = savedPathImg; 

                                app.indice = app.indice + 1;
                                app.tam_vet = app.tam_vet + 1;
                                app.vetorImg{app.indice} = savedPathImg;
                        end

                    case "Contagem simples"
                        try
                            %img = imread('img.jpg');
                            %figure, imshow(img);
                            
                            i = rgb2gray(img);
                            %figure, imshow(i);
                            
                            limiar = 255-i;
                            
                            bw = imbinarize(limiar);
                            %figure, imshow(bw);
                            
                            bw2 = imfill(bw, 'holes');
                            %figure, imshow(bw2);
                            
                            L = logical(bw2);
                            s = regionprops(L, 'Centroid');
                            figure, imshow(bw2), title('Objetos contados');

                            hold on
                                % Circular as regiões
                                boundaries = bwboundaries(L);
                                for k = 1:length(boundaries)
                                    boundary = boundaries{k};
                                    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
                                end
                                
                                % Marcar os centróides das regiões
                                for k = 1:numel(s)
                                    c = s(k).Centroid;
                                    text(c(1), c(2), sprintf('%d', k), ...
                                        'HorizontalAlignment', 'center', ...
                                        'VerticalAlignment', 'middle', ...
                                        'Color', 'black');
                                end 
                                % Contar o número total de objetos
                                numObjects = numel(s);
                                
                                % Exibir o valor total da contagem na imagem
                                text(size(bw2, 2) - 10, 10, sprintf('Total: %d', numObjects), ...
                                    'HorizontalAlignment', 'right', ...
                                    'VerticalAlignment', 'top', ...
                                    'Color', 'green', ...
                                    'FontSize', 12, ...
                                    'FontWeight', 'bold');
                                hold off;
                        catch ME
                            disp('Erro ao aplicar filtro:'); 
                            disp(ME.message);
                        end
                        

                end
            end                             
        end

        % Value changed function: FiltrosDropDown
        function FiltrosDropDownValueChanged(app, event)
            valor = app.FiltrosDropDown.Value;
            
            app.EscolhaumaOpoButtonGroup.Visible = "off";
            app.Op4Button.Visible = "off";
            app.Op3Button.Visible = "off";
            app.Op2Button.Visible = "off";
            app.Op1Button.Visible = "off";

            app.EditField.Visible = "off"; 
            app.EditFieldLabel.Visible = "off";

            app.EditField2.Visible = "off";
            app.EditField2Label.Visible = "off";
             
            app.EditField3.Visible = "off";
            app.EditField3Label.Visible = "off";

            switch valor

                 case "Escala de Cinza"
                     app.EditField.Visible = "off"; 
                     app.EditFieldLabel.Visible = "off";

                     app.EditField2.Visible = "off";
                     app.EditField2Label.Visible = "off";
                         
                     app.EditField3.Visible = "off";
                     app.EditField3Label.Visible = "off";


                 case "Threshold"
                     app.EditField.Visible = "on"; 
                     app.EditFieldLabel.Visible = "on";
                     app.EditFieldLabel.Text = "Valor do Limar (0-1]";

                     app.EditField2.Visible = "off";
                     app.EditField2Label.Visible = "off";

                     app.EditField3.Visible = "off";
                     app.EditField3Label.Visible = "off";

                 case "Passa-Alta"
                     app.EscolhaumaOpoButtonGroup.Visible = "on";
                     app.Op1Button.Visible = "on";
                     app.Op2Button.Visible = "on";

                     app.Op1Button.Text = "Básico";
                     app.Op2Button.Text = "Alto Reforço";

                 case "Passa-Baixa"
                     app.EscolhaumaOpoButtonGroup.Visible = "on";
                     app.Op1Button.Visible = "on";
                     app.Op2Button.Visible = "on";

                     app.Op1Button.Text = "Média (Básico)";
                     app.Op2Button.Text = "Mediana";

                 case "Roberts"
                     app.EditField.Visible = "off"; 
                     app.EditFieldLabel.Visible = "off";

                     app.EditField2.Visible = "off";
                     app.EditField2Label.Visible = "off";

                     app.EditField3.Visible = "off";
                     app.EditField3Label.Visible = "off";

                 case "Prewitt"
                     app.EscolhaumaOpoButtonGroup.Visible = "on";
                     app.Op4Button.Visible = "on";
                     app.Op2Button.Visible = "on";
                     app.Op3Button.Visible = "on";
                     app.Op1Button.Visible = "on";

                     app.Op1Button.Text = "Prewitt Horizontal";
                     app.Op2Button.Text = "Prewwit Vertical";
                     app.Op3Button.Text = "Horizontal + Vertical";
                     app.Op4Button.Text = "Prewitt Edge";

                 case "Sobel"
                     app.EscolhaumaOpoButtonGroup.Visible = "on";
                     app.Op4Button.Visible = "on";
                     app.Op2Button.Visible = "on";
                     app.Op3Button.Visible = "on";
                     app.Op1Button.Visible = "on";

                     app.Op1Button.Text = "Sobel Horizontal";
                     app.Op2Button.Text = "Sobel Vertical";
                     app.Op3Button.Text = "Horizontal + Vertical";
                     app.Op4Button.Text = "Sobel Edge";

                 case "Log"
                     app.EditField.Visible = "on";
                     app.EditFieldLabel.Visible = "on";

                     app.EditField2.Visible = "on";
                     app.EditField2Label.Visible = "on";

                     app.EditFieldLabel.Text = "Sigma (Padrao 2)";
                     app.EditField2Label.Text = "Threshold (Padrao 0)";

                 case "Zerocross"
                     app.EditField.Visible = "off"; 
                     app.EditFieldLabel.Visible = "off";

                     app.EditField2.Visible = "off";
                     app.EditField2Label.Visible = "off";
                     
                     app.EditField3.Visible = "off";
                     app.EditField3Label.Visible = "off";

                 case "Canny"
                     app.EditField.Visible = "off"; 
                     app.EditFieldLabel.Visible = "off";

                     app.EditField2.Visible = "off";
                     app.EditField2Label.Visible = "off";
                     
                     app.EditField3.Visible = "off";
                     app.EditField3Label.Visible = "off";
                   
                 case "Ruídos"
                     app.EscolhaumaOpoButtonGroup.Visible = "on";
                     app.Op1Button.Visible = "on";
                     app.Op2Button.Visible = "on";
                     app.Op3Button.Visible = "on";
                     app.Op4Button.Visible = "on";
    
                     app.Op1Button.Text = "Speckle";
                     app.Op2Button.Text = "Guasiana";
                     app.Op3Button.Text = "Salt & Papper";
                     app.Op4Button.Text = "Poissen";

                 case "Watershed"
                     app.EscolhaumaOpoButtonGroup.Visible = "on";
                     app.Op1Button.Visible = "on";
                     app.Op2Button.Visible = "on";

                     app.Op1Button.Text = "Marker-Controlled Watershed Segmentation";
                     app.Op2Button.Text = "Watershed Segmentation";

                     app.EditField.Visible = "off"; 
                     app.EditFieldLabel.Visible = "off";

                     app.EditField2.Visible = "off";
                     app.EditField2Label.Visible = "off";
                     
                     app.EditField3.Visible = "off";
                     app.EditField3Label.Visible = "off";

                 case "Histograma"
                     app.EscolhaumaOpoButtonGroup.Visible = "on";
                     app.Op1Button.Visible = "on";
                     app.Op2Button.Visible = "on";
                     app.Op3Button.Visible = "on";

                     app.Op1Button.Text = "Escala Cinza";
                     app.Op2Button.Text = "Ajuste Equalizado";
                     app.Op3Button.Text = "Ajuste Adaptativo";

                     app.EditField.Visible = "off"; 
                     app.EditFieldLabel.Visible = "off";

                     app.EditField2.Visible = "off";
                     app.EditField2Label.Visible = "off";
                     
                     app.EditField3.Visible = "off";
                     app.EditField3Label.Visible = "off";
             end

        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            value = app.EditField.Value;
            
        end

        % Selection changed function: EscolhaumaOpoButtonGroup
        function EscolhaumaOpoButtonGroupSelectionChanged(app, event)
            selectedButton = app.EscolhaumaOpoButtonGroup.SelectedObject;
            app.EditField.Visible = "off"; 
            app.EditFieldLabel.Visible = "off";

            app.EditField2.Visible = "off";
            app.EditField2Label.Visible = "off";
         
            app.EditField3.Visible = "off";
            app.EditField3Label.Visible = "off";
            
            if (app.FiltrosDropDown.Value == "Passa-Alta")
                switch selectedButton
                    case app.Op1Button
                        app.EditField.Visible = "on"; 
                        app.EditFieldLabel.Visible = "on";
                        app.EditFieldLabel.Text = "Kernel (Padrao 9)";
                    case app.Op2Button
                        app.EditField.Visible = "on"; 
                        app.EditFieldLabel.Visible = "on";
                        app.EditFieldLabel.Text = "Reforço (Padrao 1.5)";
                end
            end

            if (app.FiltrosDropDown.Value == "Passa-Baixa")
                  switch selectedButton 
                    case app.Op1Button  
                        app.EditField.Visible = "on";
                        app.EditFieldLabel.Visible = "on";
                        app.EditFieldLabel.Text = "Nivel";

                        app.EditField2.Visible = "off";
                        app.EditField2Label.Visible = "off";
                  
                    case app.Op2Button
                        app.EditField.Visible = "on";
                        app.EditFieldLabel.Visible = "on";
                        app.EditFieldLabel.Text = "Linhas";

                        app.EditField2.Visible = "on";
                        app.EditField2Label.Visible = "on";
                        app.EditField2Label.Text = "Coluna";
                 end
            end

            if(app.FiltrosDropDown.Value == "Ruídos")
                switch selectedButton
                    case app.Op1Button
                         app.EditField.Visible = "on";
                         app.EditFieldLabel.Visible = "on";
                         app.EditFieldLabel.Text = "Padrao 0.05";

                         app.EditField2.Visible = "off";
                         app.EditField2Label.Visible = "off";

                         app.EditField3.Visible = "off";
                         app.EditField3Label.Visible = "off";


                    case app.Op2Button
                         app.EditField2.Visible = "off";
                         app.EditField2Label.Visible = "off";
 
                         app.EditField.Visible = "off";
                         app.EditFieldLabel.Visible = "off";


                    case app.Op3Button
                         app.EditField.Visible = "on";
                         app.EditFieldLabel.Visible = "on";
                         app.EditFieldLabel.Text = "Padrao 0.05";

                    case app.Op4Button
                         app.EditField2.Visible = "off";
                         app.EditField2Label.Visible = "off";
 
                         app.EditField.Visible = "off";
                         app.EditFieldLabel.Visible = "off";
                     
                end
            end

            

            
        end

        % Button pushed function: CancelarFiltroButton
        function CancelarFiltroButtonPushed(app, event)
            cancelar_filtro = app.indice - 1;
            if(cancelar_filtro >= 1 && cancelar_filtro <= app.tam_vet)
                new = app.vetorImg{cancelar_filtro};
                if(new ~="")
                    app.Image2.ImageSource = new;
                    app.indice = cancelar_filtro;
                end
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9216 0.7804 0.9059];
            app.UIFigure.Position = [100 100 819 554];
            app.UIFigure.Name = 'MATLAB App';

            % Create AplicarFiltroButton
            app.AplicarFiltroButton = uibutton(app.UIFigure, 'push');
            app.AplicarFiltroButton.ButtonPushedFcn = createCallbackFcn(app, @AplicarFiltroButtonPushed, true);
            app.AplicarFiltroButton.BackgroundColor = [0.902 0.6392 0.8];
            app.AplicarFiltroButton.Position = [35 61 510 23];
            app.AplicarFiltroButton.Text = 'Aplicar Filtro';

            % Create ImagemButton
            app.ImagemButton = uibutton(app.UIFigure, 'push');
            app.ImagemButton.ButtonPushedFcn = createCallbackFcn(app, @ImagemButtonPushed, true);
            app.ImagemButton.IconAlignment = 'right';
            app.ImagemButton.BackgroundColor = [0.902 0.6392 0.8];
            app.ImagemButton.Position = [35 94 510 23];
            app.ImagemButton.Text = 'Imagem';

            % Create umaimageumfiltroumsonhoandCUTIELabel
            app.umaimageumfiltroumsonhoandCUTIELabel = uilabel(app.UIFigure);
            app.umaimageumfiltroumsonhoandCUTIELabel.FontWeight = 'bold';
            app.umaimageumfiltroumsonhoandCUTIELabel.Position = [152 502 327 37];
            app.umaimageumfiltroumsonhoandCUTIELabel.Text = 'uma image, um filtro, um sonho and CUTIE';

            % Create FiltrosDropDownLabel
            app.FiltrosDropDownLabel = uilabel(app.UIFigure);
            app.FiltrosDropDownLabel.HorizontalAlignment = 'right';
            app.FiltrosDropDownLabel.Position = [588 473 38 22];
            app.FiltrosDropDownLabel.Text = 'Filtros';

            % Create FiltrosDropDown
            app.FiltrosDropDown = uidropdown(app.UIFigure);
            app.FiltrosDropDown.Items = {'Escala de Cinza', 'Threshold', 'Passa-Alta', 'Passa-Baixa', 'Roberts', 'Prewitt', 'Sobel', 'Log', 'Zerocross', 'Canny', 'Ruídos', 'Watershed', 'Histograma', 'Contagem simples'};
            app.FiltrosDropDown.ValueChangedFcn = createCallbackFcn(app, @FiltrosDropDownValueChanged, true);
            app.FiltrosDropDown.Position = [638 473 129 22];
            app.FiltrosDropDown.Value = 'Escala de Cinza';

            % Create EscolhaumaimagemPanel
            app.EscolhaumaimagemPanel = uipanel(app.UIFigure);
            app.EscolhaumaimagemPanel.Title = 'Escolha uma imagem';
            app.EscolhaumaimagemPanel.BackgroundColor = [0.902 0.902 0.902];
            app.EscolhaumaimagemPanel.Position = [35 134 509 361];

            % Create Image2
            app.Image2 = uiimage(app.EscolhaumaimagemPanel);
            app.Image2.Position = [35 17 441 311];

            % Create EscolhaumaOpoButtonGroup
            app.EscolhaumaOpoButtonGroup = uibuttongroup(app.UIFigure);
            app.EscolhaumaOpoButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @EscolhaumaOpoButtonGroupSelectionChanged, true);
            app.EscolhaumaOpoButtonGroup.Title = 'Escolha uma Opção';
            app.EscolhaumaOpoButtonGroup.Visible = 'off';
            app.EscolhaumaOpoButtonGroup.Position = [602 134 180 143];

            % Create Op1Button
            app.Op1Button = uiradiobutton(app.EscolhaumaOpoButtonGroup);
            app.Op1Button.Text = 'Op1';
            app.Op1Button.Position = [12 96 168 22];
            app.Op1Button.Value = true;

            % Create Op2Button
            app.Op2Button = uiradiobutton(app.EscolhaumaOpoButtonGroup);
            app.Op2Button.Text = 'Op2';
            app.Op2Button.Position = [11 75 168 22];

            % Create Op3Button
            app.Op3Button = uiradiobutton(app.EscolhaumaOpoButtonGroup);
            app.Op3Button.Text = 'Op3';
            app.Op3Button.Position = [11 53 168 22];

            % Create Op4Button
            app.Op4Button = uiradiobutton(app.EscolhaumaOpoButtonGroup);
            app.Op4Button.Text = 'Op4';
            app.Op4Button.Position = [11 30 168 22];

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.UIFigure);
            app.EditFieldLabel.Visible = 'off';
            app.EditFieldLabel.Position = [593 419 122 22];
            app.EditFieldLabel.Text = 'Edit Field';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'numeric');
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.HorizontalAlignment = 'center';
            app.EditField.Visible = 'off';
            app.EditField.Position = [714 418 54 24];

            % Create EditField2Label
            app.EditField2Label = uilabel(app.UIFigure);
            app.EditField2Label.Visible = 'off';
            app.EditField2Label.Position = [593 375 122 22];
            app.EditField2Label.Text = 'Edit Field2';

            % Create EditField2
            app.EditField2 = uieditfield(app.UIFigure, 'numeric');
            app.EditField2.HorizontalAlignment = 'center';
            app.EditField2.Visible = 'off';
            app.EditField2.Position = [714 374 55 24];

            % Create EditField3Label
            app.EditField3Label = uilabel(app.UIFigure);
            app.EditField3Label.Visible = 'off';
            app.EditField3Label.Position = [593 334 62 22];
            app.EditField3Label.Text = 'Edit Field3';

            % Create EditField3
            app.EditField3 = uieditfield(app.UIFigure, 'numeric');
            app.EditField3.HorizontalAlignment = 'center';
            app.EditField3.Visible = 'off';
            app.EditField3.Position = [715 334 55 22];

            % Create CancelarFiltroButton
            app.CancelarFiltroButton = uibutton(app.UIFigure, 'push');
            app.CancelarFiltroButton.ButtonPushedFcn = createCallbackFcn(app, @CancelarFiltroButtonPushed, true);
            app.CancelarFiltroButton.BackgroundColor = [0.902 0.6392 0.8];
            app.CancelarFiltroButton.Position = [37 26 509 23];
            app.CancelarFiltroButton.Text = 'Cancelar Filtro';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = filtros_trab1

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
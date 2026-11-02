%% Automação Completa: Processamento e Salvamento de Figuras do Dataset (TG Samuel)
clear all; close all; clc;

% =========================================================================
% 1. CONFIGURAÇÕES DE DIRETÓRIOS E PARÂMETROS
% =========================================================================
pasta_raiz = 'D:\Users\samue\Desktop\Materiais\TG\PMIs'; % Substitua pelo caminho real
pasta_saida = 'D:\Users\samue\Desktop\Materiais\TG\PMIs\Resultados_Figuras'; % Onde as imagens serão salvas

if ~exist(pasta_saida, 'dir')
    mkdir(pasta_saida);
end

porcos = 18:29; % Lista de animais do dataset
Fs = 50;        % Frequência de amostragem
f_v = 0.50;     % Frequência de corte da ventilação
f_p = 0.17;     % Frequência de corte da perfusão

% Inicialização da Tabela Global de Excel
tabela_logs = table();

fprintf('Iniciando processamento em lote (Batch Processing)...\n');

% =========================================================================
% 2. LOOP PRINCIPAL DE VARREDURA
% =========================================================================
for p = 1:length(porcos)
    id_porco = porcos(p);
    caminho_porco = fullfile(pasta_raiz, sprintf('PMI_%d', id_porco));
    
    if ~isfolder(caminho_porco)
        continue;
    end
    
    subpastas = dir(fullfile(caminho_porco, 'FB_Isol_*'));
    
    for s = 1:length(subpastas)
        if subpastas(s).isdir
            caminho_exame = fullfile(caminho_porco, subpastas(s).name);
            nome_exame = subpastas(s).name;
            
            % Busca os arquivos
            arq_bruto = dir(fullfile(caminho_exame, 'PIG *FB*.mat'));
            arq_ref   = dir(fullfile(caminho_exame, 'data_fb_*.mat'));
            
            if ~isempty(arq_bruto) && ~isempty(arq_ref)
                caminho_arquivo_bruto = fullfile(caminho_exame, arq_bruto(1).name);
                caminho_arquivo_ref = fullfile(caminho_exame, arq_ref(1).name);
                
                fprintf('Processando: PMI %d | %s...\n', id_porco, nome_exame);
                
                % Cria a subpasta de saída para este exame
                pasta_exame_saida = fullfile(pasta_saida, sprintf('PMI_%d', id_porco), nome_exame);
                if ~exist(pasta_exame_saida, 'dir')
                    mkdir(pasta_exame_saida);
                end
                
                % =========================================================
                % 3. CARREGAMENTO DOS DADOS
                % =========================================================
                try
                    dados_brutos = load(caminho_arquivo_bruto);
                    pletis_ventilacao_3d = dados_brutos.data.img_frames;
                    
                    dados_ref = load(caminho_arquivo_ref);
                    if isfield(dados_ref, 'data_fb')
                        pletis_ref_3d = dados_ref.data_fb.img_frames;
                    else
                        pletis_ref_3d = dados_ref.data.img_frames;
                    end
                    
                    % LIMPEZA DE TRANSIENTES (CROP): Se o arquivo apresentar artefatos espúrios iniciais
                    if contains(arq_bruto(1).name, 'PIG 19 (FB) 53690 54906') % Exemplo: Cortar PIG 19
                         amostras_a_descartar = 45;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 19 (FB) 56067 57284') % Exemplo: Cortar PIG 19
                         amostras_a_descartar = 60;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 19 (FB) 56712 58067') % Exemplo: Cortar PIG 19 Isol 7
                         amostras_a_descartar = 70;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 19 (FB) 66025 67375') % Exemplo: Cortar PIG 19 Isol 10
                         amostras_a_descartar = 50;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 19 (FB) 135491 137055') % Exemplo: Cortar PIG 19 Isol 15
                         amostras_a_descartar = 20;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 19 (FB) 139939 141290') % Exemplo: Cortar PIG 19 Isol 16
                         amostras_a_descartar = 20;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 19 (FB) 146318 147668') % Exemplo: Cortar PIG 19 Isol 18
                         amostras_a_descartar = 40;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 19 (FB) 152803 154154') % Exemplo: Cortar PIG 19 Isol 19
                         amostras_a_descartar = 35;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 20 (FB) 30553 32064') % Exemplo: Cortar PIG 20 Isol 3
                         amostras_a_descartar = 65;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 20 (FB) 76567 77961') % Exemplo: Cortar PIG 20 Isol 4
                         amostras_a_descartar = 15;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 20 (FB) 125757 127171') % Exemplo: Cortar PIG 20 Isol 6
                         amostras_a_descartar = 90;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 20 (FB) 159966 162180') % Exemplo: Cortar PIG 20 Isol 7
                         amostras_a_descartar = 50;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 21 (FB) 17253 18901') % Exemplo: Cortar PIG 21 Isol 1
                         amostras_a_descartar = 180;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 21 (FB) 159424 161289') % Exemplo: Cortar PIG 21 Isol 8
                         amostras_a_descartar = 150;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 22 (FB) 46190 47719') % Exemplo: Cortar PIG 22 Isol 2
                         amostras_a_descartar = 50;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 22 (FB) 55095 56565') % Exemplo: Cortar PIG 22 Isol 3
                         amostras_a_descartar = 90;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 22 (FB) 84133 85735') % Exemplo: Cortar PIG 22 Isol 4
                         amostras_a_descartar = 25;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 22 (FB) 139598 141121') % Exemplo: Cortar PIG 22 Isol 7
                         amostras_a_descartar = 60;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 24 (FB) 65504 66884') % Exemplo: Cortar PIG 24 Isol 2
                         amostras_a_descartar = 30;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 24 (FB) 94743 96244') % Exemplo: Cortar PIG 24 Isol 4
                         amostras_a_descartar = 50;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 24 (FB) 106263 107709') % Exemplo: Cortar PIG 24 Isol 5
                         amostras_a_descartar = 20;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 24 (FB) 118999 120560') % Exemplo: Cortar PIG 24 Isol 6
                         amostras_a_descartar = 130;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 24 (FB) 136050 137671') % Exemplo: Cortar PIG 24 Isol 7
                         amostras_a_descartar = 40;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 25 (FB) 18348 19914') % Exemplo: Cortar PIG 25 Isol 1
                         amostras_a_descartar = 125;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 25 (FB) 22251 23894') % Exemplo: Cortar PIG 25 Isol 2
                         amostras_a_descartar = 45;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 25 (FB) 37471 39126') % Exemplo: Cortar PIG 25 Isol 3
                         amostras_a_descartar = 110;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 25 (FB) 55804 57195') % Exemplo: Cortar PIG 25 Isol 4
                         amostras_a_descartar = 50;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 25 (FB) 72029 73507') % Exemplo: Cortar PIG 25 Isol 6
                         amostras_a_descartar = 95;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 25 (FB) 92463 93821') % Exemplo: Cortar PIG 25 Isol 7
                         amostras_a_descartar = 40;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 25 (FB) 112516 113780') % Exemplo: Cortar PIG 25 Isol 8
                         amostras_a_descartar = 60;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    if contains(arq_bruto(1).name, 'PIG 26 (FB) 40563 41676') % Exemplo: Cortar PIG 26 Isol 3
                         amostras_a_descartar = 40;
                         
                         % Corta a matriz 3D bruta
                         pletis_ventilacao_3d = pletis_ventilacao_3d(:, :, amostras_a_descartar+1:end);
                         
                         % Corta a matriz 3D de referência
                         pletis_ref_3d = pletis_ref_3d(:, :, amostras_a_descartar+1:end);
                         
                         fprintf('    -> Aviso: %d amostras iniciais removidas para estabilizar linha de base do arquivo %s.\n', amostras_a_descartar, arq_bruto(1).name);
                    end
                    
                    

                catch
                    warning('Erro ao carregar os arquivos. Pulando...');
                    continue;
                end
                
                % =========================================================
                % 4. PROCESSAMENTO MATEMÁTICO (SINAIS 1D E ROI)
                % =========================================================
                % Mapa TIV e Localização do ROI
                z_max = max(pletis_ventilacao_3d, [], 3);
                z_min = min(pletis_ventilacao_3d, [], 3);
                mapa_tiv = z_max - z_min;
                
                mask_dorsal_direito = false(32, 32);
                mask_dorsal_direito(17:32, 17:32) = true; 
                tiv_mascarado = mapa_tiv;
                tiv_mascarado(~mask_dorsal_direito) = 0; 
                
                [~, idx_max_tiv] = max(tiv_mascarado(:));
                [linha_max, coluna_max] = ind2sub(size(tiv_mascarado), idx_max_tiv);
                
                % Sinais 1D Brutos e Ancoragem
                pletis_global = squeeze(sum(pletis_ventilacao_3d, [1 2]));
                linha_base_global = mean(pletis_global(1:50));
                pletis_global_zero = pletis_global - linha_base_global;
                
                pletis_ROI = squeeze(pletis_ventilacao_3d(linha_max, coluna_max, :));
                linha_base_ROI = mean(pletis_ROI(1:50));
                pletis_ROI_zero = pletis_ROI - linha_base_ROI;
                
                pletis_ref_global = squeeze(sum(pletis_ref_3d, [1 2]));
                linha_base_ref = mean(pletis_ref_global(1:50));
                pletis_ref_zero = pletis_ref_global - linha_base_ref;
                
                % Filtragem 1D
                [pletis_perf, ~] = passa_baixa_sos(pletis_global_zero, f_p, Fs);
                [pletis_ROI_perf, ~] = passa_baixa_sos(pletis_ROI_zero, f_p, Fs);
                
                % Determinação da Janela Temporal
                margem_seguranca = 100; 
                if length(pletis_ROI_perf) <= margem_seguranca
                    continue;
                end
                
                [~, idx_fim_relativo] = min(pletis_ROI_perf(margem_seguranca:end));
                idx_fim = idx_fim_relativo + margem_seguranca - 1; 
                
                janela_estavel = 200:round(idx_fim / 1.5);
                if isempty(janela_estavel), janela_estavel = 1:50; end
                linha_EELI = mean(pletis_ROI_perf(janela_estavel));
                
                idx_inicio = idx_fim;
                while idx_inicio > margem_seguranca && pletis_ROI_perf(idx_inicio) < linha_EELI
                    idx_inicio = idx_inicio - 1;
                end
                
                % Preparação para Análise Espectral (FFT)
                if length(janela_estavel) >= 9
                    pletis_ROI_fft = detrend(pletis_ROI(janela_estavel), 'constant');
                else
                    pletis_ROI_fft = detrend(pletis_ROI(1:min(length(pletis_ROI), 500)), 'constant');
                end
                
                % =========================================================
                % 5. PROCESSAMENTO ESPACIAL (MAPAS 2D E V/Q)
                % =========================================================
                limiar_relativo = 0.10 * max(mapa_tiv(:));
                mascara_pulmao = mapa_tiv > limiar_relativo;
                
                [linhas, colunas, frames] = size(pletis_ventilacao_3d);
                matriz_perf_3d = zeros(linhas, colunas, frames);
                matriz_vent_3d = zeros(linhas, colunas, frames);
                
                for i = 1:linhas
                    for j = 1:colunas
                        if mascara_pulmao(i, j)
                            pixel_sinal = squeeze(pletis_ventilacao_3d(i, j, :));
                            linha_base_pixel = mean(pixel_sinal(1:50));
                            pixel_sinal_zero = pixel_sinal - linha_base_pixel;
                            matriz_perf_3d(i, j, :) = passa_baixa_sos(pixel_sinal_zero, f_p, Fs);
                            matriz_vent_3d(i, j, :) = passa_baixa_sos(pixel_sinal_zero, f_v, Fs);
                        end
                    end
                end
                
                % Extração dos Mapas 2D (Perfusão, Referência e Ventilação)
                mapa_perfusao_2d = zeros(linhas, colunas);
                mapa_ref_2d = zeros(linhas, colunas);
                mapa_vent_2d = zeros(linhas, colunas);
                t_janela = (1:(idx_fim - idx_inicio + 1))'; 
                
                for i = 1:linhas
                    for j = 1:colunas
                        if mascara_pulmao(i, j)
                            % Nosso Perfusão (Polyfit / Xu et al.)
                            sinal_janela = squeeze(matriz_perf_3d(i, j, idx_inicio:idx_fim));
                            coeficientes = polyfit(t_janela, sinal_janela(:), 1);
                            if -coeficientes(1) > 0, mapa_perfusao_2d(i, j) = -coeficientes(1); end
                            
                            % Perfusão Referência Dataset (Polyfit)
                            sinal_janela_ref = squeeze(pletis_ref_3d(i, j, idx_inicio:idx_fim));
                            coeficientes_ref = polyfit(t_janela, sinal_janela_ref(:), 1);
                            if -coeficientes_ref(1) > 0, mapa_ref_2d(i, j) = -coeficientes_ref(1); end
                            
                            % Ventilação (TIV)
                            sinal_vent_pixel = squeeze(matriz_vent_3d(i, j, :));
                            amplitude_vent = max(sinal_vent_pixel) - min(sinal_vent_pixel);
                            if amplitude_vent > 0, mapa_vent_2d(i, j) = amplitude_vent; end
                        end
                    end
                end
                
                % Classificação V/Q
                limiar_V = 0.20 * max(mapa_vent_2d(:));
                limiar_Q = 0.20 * max(mapa_perfusao_2d(:));
                R_V  = (mapa_vent_2d > limiar_V) & ~(mapa_perfusao_2d > limiar_Q); 
                R_P  = (mapa_perfusao_2d > limiar_Q) & ~(mapa_vent_2d > limiar_V); 
                R_VP = (mapa_vent_2d > limiar_V) & (mapa_perfusao_2d > limiar_Q);  
                
                total_ativos = sum(R_V(:)) + sum(R_P(:)) + sum(R_VP(:));
                if total_ativos > 0
                    DeadSpace_pct = (sum(R_V(:)) / total_ativos) * 100;
                    Shunt_pct     = (sum(R_P(:)) / total_ativos) * 100;
                    VQMatch_pct   = (sum(R_VP(:)) / total_ativos) * 100;
                else
                    DeadSpace_pct = NaN; Shunt_pct = NaN; VQMatch_pct = NaN;
                end
                
                linhas_meio = round(linhas / 2);
                shunt_dorsal_pixels = sum(sum(R_P(linhas_meio+1:end, :)));
                if sum(R_P(:)) > 0
                    Shunt_dorsal_prop = (shunt_dorsal_pixels / sum(R_P(:))) * 100;
                else
                    Shunt_dorsal_prop = 0;
                end
                
                % =========================================================
                % 6. CÁLCULO DAS ESTATÍSTICAS E MÉTRICAS
                % =========================================================
                % Métricas 1D (NRMSE e Pearson)
                tam_min = min(length(pletis_perf), length(pletis_ref_zero));
                sig_est = pletis_perf(1:tam_min); sig_est = sig_est(:);
                sig_ref = pletis_ref_zero(1:tam_min); sig_ref = sig_ref(:);
                
                media_ref = mean(sig_ref);
                den_nrmse = sqrt(sum((sig_ref - media_ref).^2));
                if den_nrmse ~= 0
                    nrmse_valor = sqrt(sum((sig_est - sig_ref).^2)) / den_nrmse;
                else
                    nrmse_valor = NaN;
                end
                
                matriz_r = corrcoef(sig_ref, sig_est);
                r_pearson_1d = matriz_r(1, 2);
                
                % Bland-Altman e preparação da estatística 2D
                soma_nosso = sum(mapa_perfusao_2d(:));
                soma_ref = sum(mapa_ref_2d(:));
                if soma_nosso > 0 && soma_ref > 0
                    mapa_nosso_norm = (mapa_perfusao_2d / soma_nosso) * 100;
                    mapa_ref_norm = (mapa_ref_2d / soma_ref) * 100;
                    pixels_nosso = mapa_nosso_norm(mascara_pulmao);
                    pixels_ref = mapa_ref_norm(mascara_pulmao);
                    
                    diferencas = pixels_nosso - pixels_ref;
                    medias = (pixels_ref + pixels_nosso) / 2; 
                    vies = mean(diferencas);
                    desvio_padrao = std(diferencas);
                    limite_sup = vies + 1.96 * desvio_padrao;
                    limite_inf = vies - 1.96 * desvio_padrao;
                    
                    r_spearman = corr(pixels_ref, pixels_nosso, 'Type', 'Spearman');
                    r_pearson_2d = corr(pixels_ref, pixels_nosso, 'Type', 'Pearson');
                    
                    % Extração dos 4 Quadrantes Regionais
                    RV_nosso = sum(sum(mapa_nosso_norm(1:16, 1:16) .* mascara_pulmao(1:16, 1:16)));
                    LV_nosso = sum(sum(mapa_nosso_norm(1:16, 17:32) .* mascara_pulmao(1:16, 17:32)));
                    RD_nosso = sum(sum(mapa_nosso_norm(17:32, 1:16) .* mascara_pulmao(17:32, 1:16)));
                    LD_nosso = sum(sum(mapa_nosso_norm(17:32, 17:32) .* mascara_pulmao(17:32, 17:32)));

                    RV_ref = sum(sum(mapa_ref_norm(1:16, 1:16) .* mascara_pulmao(1:16, 1:16)));
                    LV_ref = sum(sum(mapa_ref_norm(1:16, 17:32) .* mascara_pulmao(1:16, 17:32)));
                    RD_ref = sum(sum(mapa_ref_norm(17:32, 1:16) .* mascara_pulmao(17:32, 1:16)));
                    LD_ref = sum(sum(mapa_ref_norm(17:32, 17:32) .* mascara_pulmao(17:32, 17:32)));
                    
                    % Diferenças Absolutas Regionais
                    Diff_RV = abs(RV_ref - RV_nosso);
                    Diff_LV = abs(LV_ref - LV_nosso);
                    Diff_RD = abs(RD_ref - RD_nosso);
                    Diff_LD = abs(LD_ref - LD_nosso);
                else
                    r_spearman = NaN; r_pearson_2d = NaN; vies = NaN; limite_sup = NaN; limite_inf = NaN; 
                    pixels_nosso = []; pixels_ref = []; medias = []; diferencas = [];
                    RV_nosso = NaN; LV_nosso = NaN; RD_nosso = NaN; LD_nosso = NaN;
                    RV_ref = NaN; LV_ref = NaN; RD_ref = NaN; LD_ref = NaN;
                    Diff_RV = NaN; Diff_LV = NaN; Diff_RD = NaN; Diff_LD = NaN;
                end
                
                % =========================================================
                % 7. ARMAZENAMENTO DE LOGS (.txt e .xlsx)
                % =========================================================
                caminho_txt = fullfile(pasta_exame_saida, 'log_resultados.txt');
                fid = fopen(caminho_txt, 'w');
                fprintf(fid, '==== RESULTADOS DO EXAME ====\n');
                fprintf(fid, 'Porco: %d | Exame: %s\n', id_porco, nome_exame);
                fprintf(fid, '-----------------------------------------------------\n');
                fprintf(fid, 'MÉTRICAS 1D:\n');
                fprintf(fid, 'NRMSE:                 %5.4f\n', nrmse_valor);
                fprintf(fid, 'Correlação de Pearson: %5.4f\n', r_pearson_1d);
                fprintf(fid, '-----------------------------------------------------\n');
                fprintf(fid, 'MÉTRICAS 2D (MÉTODO XU/GAO):\n');
                fprintf(fid, 'V/Q Match Global:      %5.2f%%\n', VQMatch_pct);
                fprintf(fid, 'Shunt Global:          %5.2f%%\n', Shunt_pct);
                fprintf(fid, 'Deadspace Global:      %5.2f%%\n', DeadSpace_pct);
                fprintf(fid, 'Shunt Dorsal (Grav.):  %5.2f%%\n', Shunt_dorsal_prop);
                fprintf(fid, '-----------------------------------------------------\n');
                fprintf(fid, 'BLAND-ALTMAN E CORRELAÇÃO 2D:\n');
                fprintf(fid, 'Correlação Spearman:   %5.4f\n', r_spearman);
                fprintf(fid, 'Correlação Pearson:    %5.4f\n', r_pearson_2d);
                fprintf(fid, 'Viés Médio:            %5.2f%%\n', vies);
                fprintf(fid, 'Limites 95%%:           %5.2f%% a %5.2f%%\n', limite_inf, limite_sup);
                fprintf(fid, '-----------------------------------------------------\n');
                fprintf(fid, 'COMPARAÇÃO REGIONAL (4 QUADRANTES):\n');
                fprintf(fid, 'Região           | Modelo Dataset | Nosso Filtro | Diferença\n');
                fprintf(fid, 'Ventral Direito  |     %5.2f%%    |    %5.2f%%   |   %5.2f%%\n', RV_ref, RV_nosso, Diff_RV);
                fprintf(fid, 'Ventral Esquerdo |     %5.2f%%    |    %5.2f%%   |   %5.2f%%\n', LV_ref, LV_nosso, Diff_LV);
                fprintf(fid, 'Dorsal Direito   |     %5.2f%%    |    %5.2f%%   |   %5.2f%%\n', RD_ref, RD_nosso, Diff_RD);
                fprintf(fid, 'Dorsal Esquerdo  |     %5.2f%%    |    %5.2f%%   |   %5.2f%%\n', LD_ref, LD_nosso, Diff_LD);
                fclose(fid);
                
                % Construção limpa da linha para a Tabela Global do Excel (Sem Warnings)
                nova_linha = table(id_porco, string(nome_exame), r_spearman, r_pearson_2d, nrmse_valor, vies, ...
                    VQMatch_pct, Shunt_pct, Shunt_dorsal_prop, Diff_RV, Diff_LV, Diff_RD, Diff_LD, ...
                    'VariableNames', {'Porco', 'Exame', 'R_Spearman', 'R_Pearson_2D', 'NRMSE', 'Vies', ...
                    'VQ_Match', 'Shunt_Global', 'Shunt_Dorsal', 'Diff_VD', 'Diff_VE', 'Diff_DD', 'Diff_DE'});
                
                % Anexa a nova linha à tabela global 
                tabela_logs = [tabela_logs; nova_linha];

                % =========================================================
                % 8. SALVAMENTO AUTOMÁTICO DAS FIGURAS (Visibilidade: OFF)
                % =========================================================
                
                % FIG 1: Mapa TIV e Identificação do ROI
                fig1 = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.3 0.3 0.4 0.5]);
                imagesc(mapa_tiv);
                cor_fundo = [0 0 0]; cor_pulmao = [0.2 0.4 1];
                cmap_azul = zeros(256, 3);
                cmap_azul(:,1) = linspace(cor_fundo(1), cor_pulmao(1), 256)';
                cmap_azul(:,2) = linspace(cor_fundo(2), cor_pulmao(2), 256)';
                cmap_azul(:,3) = linspace(cor_fundo(3), cor_pulmao(3), 256)';
                colormap(gca, cmap_azul); axis square off; hold on;
                plot(coluna_max, linha_max, 's', 'MarkerEdgeColor', [0.8 0.8 0.8], 'MarkerSize', 12, 'LineWidth', 1.5);
                text(coluna_max + 1.5, linha_max, '1', 'Color', 'white', 'FontSize', 12, 'FontWeight', 'bold');
                title('Time frame selection (Mapa TIV e ROI)');
                exportgraphics(fig1, fullfile(pasta_exame_saida, '1_Mapa_TIV_ROI.png'), 'Resolution', 300); close(fig1);

                % FIG 2: Identificação da Janela (Método Gao - Pletis e ROI)
                [~, ~, fig2] = Samuel_visualizar_dados_Gao_Auto(pletis_global_zero, pletis_perf, pletis_ROI_zero, pletis_ROI_perf, linha_max, coluna_max, idx_inicio, idx_fim);
                exportgraphics(fig2, fullfile(pasta_exame_saida, '2_Janela_Perfusao_Gao.png'), 'Resolution', 300); close(fig2);

                % FIG 3: Espectro de Frequências (FFT)
                [~, ~, fig3] = FFT_Samuel_Auto(pletis_ROI_fft);
                exportgraphics(fig3, fullfile(pasta_exame_saida, '3_Espectro_FFT.png'), 'Resolution', 300); close(fig3);

                % FIG 4: ROI Pulmonar (Máscara) + Mapa de Perfusão 2D
                fig4 = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.2 0.2 0.6 0.4]);
                subplot(1,2,1); imagesc(mascara_pulmao); title('ROI Pulmonar (Variância)'); colormap(gca, gray); axis off;
                subplot(1,2,2); imagesc(mapa_perfusao_2d); colorbar; title('Mapa 2D de Perfusão (Polyfit)'); colormap(gca, jet); axis off;
                exportgraphics(fig4, fullfile(pasta_exame_saida, '4_Mascara_e_Perfusao2D.png'), 'Resolution', 300); close(fig4);

                % FIG 5: Dinâmica Espaço-Temporal e Extração dos 'frames_marcados'
                frames_marcados = plot_frames_Samuel_Auto(matriz_perf_3d, mascara_pulmao, idx_inicio, idx_fim, pasta_exame_saida);
                
                % FIG 6: Comparação Temporal 1D (Validação com Modelo do Dataset)
                fig6 = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.4]);
                plot(pletis_global_zero, 'Color', [0.8 0.8 0.8], 'LineWidth', 1); hold on;
                plot(pletis_ref_zero, 'Color', [0.2 0.6 0.2], 'LineWidth', 2); 
                plot(pletis_perf, 'Color', [0.2 0.2 0.8], 'LineWidth', 2.5); 
                
                for i = 1:length(frames_marcados)
                    xline(frames_marcados(i), 'k:', 'LineWidth', 1); 
                end
                
                xline(idx_inicio, 'r--', 'Início', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right', 'LineWidth', 1.5);
                xline(idx_fim, 'r-', 'Mínimo', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
                title('Pletismogramas com Frames Demarcados'); xlabel('Amostras'); ylabel('Impedância');
                legend('Sinal Bruto', 'Referência (Dataset)', 'Filtro (Butterworth)', 'Location', 'best');
                grid on; xlim([max(1, idx_inicio - 300), min(length(pletis_perf), idx_fim + 300)]);
                exportgraphics(fig6, fullfile(pasta_exame_saida, '6_Comparacao_Temporal_1D.png'), 'Resolution', 300); close(fig6);
                
                % FIG 6B: Pletismograma Global - Separação dos 3 Sinais
                pletis_apenas_vent = pletis_global_zero - pletis_perf;
                fig6b = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.4]);
                plot(pletis_global_zero, 'Color', [0.8 0.8 0.8], 'LineWidth', 1); hold on;
                plot(pletis_apenas_vent, 'Color', [0.2 0.8 0.2], 'LineWidth', 1.5); 
                plot(pletis_perf, 'Color', [0.2 0.2 0.8], 'LineWidth', 2.5); 
                xline(idx_inicio, 'r--', 'Início', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right', 'LineWidth', 1.5);
                xline(idx_fim, 'r-', 'Mínimo', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
                title('Decomposição do Sinal: Bruto, Ventilação Isolada e Perfusão Estimada'); 
                xlabel('Amostras'); ylabel('Variação de Impedância (u.a.)');
                legend('Sinal Bruto (Misto)', 'Componente Ventilatório (Subtração)', 'Componente Perfusional (Filtro)', 'Location', 'best');
                grid on; xlim([max(1, idx_inicio - 300), min(length(pletis_perf), idx_fim + 300)]);
                exportgraphics(fig6b, fullfile(pasta_exame_saida, '6B_Decomposicao_dos_3_Sinais.png'), 'Resolution', 300); close(fig6b);

                % FIG 7: V/Q Categórico
                mapa_classificacao = zeros(linhas, colunas);
                mapa_classificacao(R_VP) = 3; mapa_classificacao(R_P) = 2; mapa_classificacao(R_V) = 1; 
                mapa_classificacao(~mascara_pulmao) = 0; 
                cmap_vq = [0 0 0; 0.6 0.6 0.6; 1 0 0; 1 1 0]; 
                fig7 = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.2 0.2 0.5 0.5]);
                imagesc(mapa_classificacao); colormap(gca, cmap_vq); axis square off;
                title('V/Q: Match (Amarelo), Shunt (Vermelho), Deadspace (Cinza)');
                exportgraphics(fig7, fullfile(pasta_exame_saida, '7_Mapa_VQ_Categorico.png'), 'Resolution', 300); close(fig7);
                
                % FIG 8: Estatísticas e Bland-Altman
                if soma_nosso > 0 && soma_ref > 0
                    fig8 = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.1 0.1 0.7 0.4]);
                    
                    subplot(1,2,1);
                    scatter(pixels_ref, pixels_nosso, 25, 'filled', 'MarkerFaceColor', [0.2 0.6 0.8], 'MarkerFaceAlpha', 0.7); hold on;
                    plot([0 max(pixels_ref)], [0 max(pixels_ref)], '--k', 'LineWidth', 1.5);
                    title(['Correlação (r = ' num2str(r_spearman, '%.3f') ')']); xlabel('Perfusão Referência (%)'); ylabel('Perfusão Filtro (%)'); grid on;
                    
                    subplot(1,2,2);
                    scatter(medias, diferencas, 25, 'filled', 'MarkerFaceColor', [0.8 0.3 0.3], 'MarkerFaceAlpha', 0.7); hold on;
                    yline(vies, '-b', ['Viés: ' num2str(vies, '%.2f')], 'LineWidth', 2, 'LabelHorizontalAlignment', 'left');
                    yline(limite_sup, '--k', ['+1.96 SD: ' num2str(limite_sup, '%.2f')]);
                    yline(limite_inf, '--k', ['-1.96 SD: ' num2str(limite_inf, '%.2f')]);
                    title('Bland-Altman: Filtro vs Referência'); xlabel('Média (%)'); ylabel('Diferença (%)'); grid on;
                    
                    exportgraphics(fig8, fullfile(pasta_exame_saida, '8_Estatisticas_BlandAltman.png'), 'Resolution', 300); close(fig8);
                end
                
            end
        end
    end
end

% Salva a Planilha Geral de todos os Exames
caminho_excel = fullfile(pasta_saida, 'Resumo_Geral_Estatisticas.xlsx');
writetable(tabela_logs, caminho_excel);

fprintf('\nProcessamento em lote finalizado com sucesso! Planilha geral salva em: %s\n', caminho_excel);

%% ================= FUNÇÕES LOCAIS ================= %%
function [sinal_filtrado, fc] = passa_baixa_sos(sinal_bruto, fc, Fs)
    Wn = fc / (Fs / 2);
    [z, p, k] = butter(9, Wn, 'low');
    [sos, g] = zp2sos(z, p, k);
    sinal_filtrado = filtfilt(sos, g, sinal_bruto);
end

function [pletis_global_out, pletis_ROI_out, fig_out] = Samuel_visualizar_dados_Gao_Auto(pletis_global_zero, pletis_perf, pletis_ROI_zero, pletis_ROI_perf, linha_max, coluna_max, idx_inicio, idx_fim)
    pletis_global_out = []; pletis_ROI_out = [];
    fig_out = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.2 0.2 0.6 0.6]);
    
    subplot(2,1,1);
    plot(pletis_global_zero, 'Color', [0.7 0.7 0.7], 'LineWidth', 1); hold on;
    plot(pletis_perf, 'Color', [0 0.4470 0.7410], 'LineWidth', 2);
    xline(idx_inicio, 'r--', 'Início Queda', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right', 'LineWidth', 1.5);
    xline(idx_fim, 'r-', 'Pico Salina', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
    title('Pletismograma Global (Filtro Passa-Baixa 0.17 Hz)'); xlabel('Amostras'); ylabel('Impedância'); grid on; xlim([0 length(pletis_global_zero)]);
    
    subplot(2,1,2);
    plot(pletis_ROI_zero, 'Color', [0.7 0.7 0.7], 'LineWidth', 1); hold on;
    plot(pletis_ROI_perf, 'Color', [0 0.4470 0.7410], 'LineWidth', 2.5);
    xline(idx_inicio, 'r--', 'Início Queda', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right', 'LineWidth', 1.5);
    xline(idx_fim, 'r-', 'Pico Salina', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
    title(sprintf('Sinal de Impedância Local do Pixel ROI (%d, %d)', linha_max, coluna_max)); xlabel('Amostras'); ylabel('Impedância'); grid on; xlim([0 length(pletis_ROI_zero)]);
end

function [P1, f, fig_out] = FFT_Samuel_Auto(pletis_ROI)
    fs = 50; L = 8192*4;
    pletis_Interpolado = interp(pletis_ROI, 1);
    Y = fft(pletis_Interpolado, L);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1); P1(2:end-1) = 2*P1(2:end-1);
    f = fs * (0:(floor(L/2)))/L; P1 = P1/max(P1);
    
    fig_out = figure('Visible', 'off');
    plot(f, P1, 'LineWidth', 1.5); title('Espectro de Magnitude Unilateral de ROI1');
    xlabel('Frequência (Hz)'); ylabel('|P1(f)| Normalizada'); grid on; xlim([0, 2.5]);
end

function frame_nums = plot_frames_Samuel_Auto(img_frames_f, mask, idx_inicio, idx_fim, pasta_saida)
    dim_frame = size(img_frames_f, 1);
    movien = 8; 
    moviet = round(linspace(idx_inicio, idx_fim, movien));
    
    [~, ~, img_frames_deriv] = gradient(-img_frames_f);
    img_diff = zeros(dim_frame, dim_frame, movien);
    
    for i = 1:movien
        img_diff(:,:,i) = img_frames_deriv(:,:,moviet(i)) .* mask;
        img_diff(img_diff < 0) = 0; 
    end
    
    movierawmax = max(img_diff(:));
    if movierawmax == 0, movierawmax = 1; end 
    img_diff_norm = img_diff ./ movierawmax;

    colorperfraw1 = [0 0.4 0.6 1]';
    colorperfraw2 = 1/255 * [0 0 0; 200 29 0; 255 0 0; 255 241 89];
    colorperf0 = linspace(0, 1, 256)';
    colorperf = zeros(256, 3);
    for c = 1:3
        colorperf(:, c) = interp1(colorperfraw1, colorperfraw2(:, c), colorperf0);
    end

    fig5 = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.1 0.3 0.8 0.3]);
    for i = 1:movien
        subplot(1, movien, i);
        imagesc(img_diff_norm(:, :, i), [0 1]);
        axis square off;
        title(['Frame ', num2str(moviet(i))]);
    end
    colormap(colorperf);
    exportgraphics(fig5, fullfile(pasta_saida, '5_Frames_Dinamica_Derivada.png'), 'Resolution', 300);
    close(fig5);
    
    frame_nums = moviet; 
end
%% Varredura Individual para Identificação da Maior Correlação
clear all; close all; clc;

% Diretório raiz do dataset
pasta_raiz = 'D:\Users\samue\Desktop\Materiais\TG\PMIs'; 

% O dataset inclui 12 porcos, numerados do 18 ao 29
porcos = 19:26; 

% Frequências fixadas a partir da sua descoberta ótima
f_p_otima = 0.17; 
f_v_otima = 0.50; 

% Inicialização da Tabela para organizar os resultados
resultados_individuais = table();
contador = 1;

fprintf('Iniciando varredura para identificar o melhor caso individual...\n');

for p = 1:length(porcos)
    id_porco = porcos(p);
    caminho_porco = fullfile(pasta_raiz, sprintf('PMI_%d', id_porco));
    
    if ~isfolder(caminho_porco)
        continue;
    end
    
    % Busca iterativa nas subpastas
    subpastas = dir(fullfile(caminho_porco, 'FB_Isol_*'));
    
    for s = 1:length(subpastas)
        if subpastas(s).isdir
            caminho_exame = fullfile(caminho_porco, subpastas(s).name);
            
            % Localiza os arquivos correspondentes
            arq_bruto = dir(fullfile(caminho_exame, 'PIG *FB*.mat'));
            arq_ref   = dir(fullfile(caminho_exame, 'data_fb_*.mat'));
            
            if ~isempty(arq_bruto) && ~isempty(arq_ref)
                caminho_arquivo_bruto = fullfile(caminho_exame, arq_bruto(1).name);
                caminho_arquivo_ref = fullfile(caminho_exame, arq_ref(1).name);
                
                % Executa o processamento com o filtro parametrizado
                [r_spearman, p_wilcoxon, vies, limite_inf, limite_sup] = Processa_TIE_Samuel(caminho_arquivo_bruto, caminho_arquivo_ref, f_p_otima, f_v_otima);
                
                % Armazena os dados de forma estruturada na tabela
                resultados_individuais.Porco(contador) = id_porco;
                resultados_individuais.Exame{contador} = subpastas(s).name;
                resultados_individuais.R_Spearman(contador) = r_spearman;
                resultados_individuais.Vies(contador) = vies;
                resultados_individuais.Wilcoxon(contador) = p_wilcoxon;
                
                contador = contador + 1;
            end
        end
    end
end

%% Pós-Processamento e Ordenação da Tabela
% 1. Remove exames que falharam ou retornaram erro (NaN)
resultados_individuais(isnan(resultados_individuais.R_Spearman), :) = [];

% 2. Ordena a tabela inteira pela correlação, de forma decrescente
tabela_ordenada = sortrows(resultados_individuais, 'R_Spearman', 'descend');

% 3. Exibe o Top 5 no Command Window
fprintf('\n==== TOP 50 CASOS COM MAIOR CORRELAÇÃO INDIVIDUAL ====\n');
disp(tabela_ordenada(1:min(50, height(tabela_ordenada)), :));

% 4. Isola e destaca o melhor caso absoluto
melhor_caso = tabela_ordenada(1, :);
fprintf('\nO caso com a maior correlação individual foi o exame %s do Porco %d, atingindo r = %.4f.\n', ...
    melhor_caso.Exame{1}, melhor_caso.Porco, melhor_caso.R_Spearman);

% Opcional: Salvar a tabela em Excel para incluir no relatório do TG
writetable(tabela_ordenada, 'Ranking_Correlacao_TG.xlsx');
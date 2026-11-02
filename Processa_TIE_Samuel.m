function [r_spearman, p_wilcoxon, vies, limite_inf, limite_sup] = Processa_TIE_Samuel(caminho_arquivo_bruto, caminho_arquivo_ref, f_p, f_v)
    % 1. Carregamento Seguro dos Dados
    try
        dados_brutos = load(caminho_arquivo_bruto);
        pletis_ventilacao_3d = dados_brutos.data.img_frames;
        
        dados_ref = load(caminho_arquivo_ref);
        if isfield(dados_ref, 'data_fb')
            pletis_ref_3d = dados_ref.data_fb.img_frames;
        else
            pletis_ref_3d = dados_ref.data.img_frames;
        end
    catch
        warning('Erro ao carregar os arquivos: %s', caminho_arquivo_bruto);
        r_spearman = NaN; p_wilcoxon = NaN; vies = NaN; limite_inf = NaN; limite_sup = NaN; return;
    end
    
    Fs = 50; 
    
    % 2. Identificação do ROI (Quadrante Dorsal Direito) via TIV
    z_max = max(pletis_ventilacao_3d, [], 3);
    z_min = min(pletis_ventilacao_3d, [], 3);
    mapa_tiv = z_max - z_min;
    
    mask_dorsal_direito = false(32, 32);
    mask_dorsal_direito(17:32, 17:32) = true; 
    
    tiv_mascarado = mapa_tiv;
    tiv_mascarado(~mask_dorsal_direito) = 0; 
    
    [~, idx_max_tiv] = max(tiv_mascarado(:));
    [linha_max, coluna_max] = ind2sub(size(tiv_mascarado), idx_max_tiv);
    
    % Extrai e ancora o sinal do pixel ROI
    pletis_ROI = squeeze(pletis_ventilacao_3d(linha_max, coluna_max, :));
    linha_base_ROI = mean(pletis_ROI(1:50));
    pletis_ROI_zero = pletis_ROI - linha_base_ROI;
    
    % 3. Filtragem Prévia (Apenas do ROI para Rastreio do Tempo)
    [pletis_ROI_perf, ~] = passa_baixa_sos(pletis_ROI_zero, f_p, Fs);
    
    % 4. Determinação Automática do Intervalo de Salina (BASEADO NO ROI COMO EM GAO)
    margem_seguranca = 100;
    
    if length(pletis_ROI_perf) <= margem_seguranca
        warning('Sinal muito curto no arquivo: %s', caminho_arquivo_bruto);
        r_spearman = NaN; p_wilcoxon = NaN; vies = NaN; limite_inf = NaN; limite_sup = NaN; return;
    end
    
    [~, idx_fim_relativo] = min(pletis_ROI_perf(margem_seguranca:end));
    idx_fim = idx_fim_relativo + margem_seguranca - 1; 
    
    fim_janela = round(idx_fim / 1.5);
    if fim_janela < 200, fim_janela = 200; end
    
    janela_estavel = 200:fim_janela; 
    if isempty(janela_estavel) || max(janela_estavel) > length(pletis_ROI_perf)
        janela_estavel = 1:50; 
    end
    
    linha_EELI = mean(pletis_ROI_perf(janela_estavel));
    
    idx_inicio = idx_fim;
    while idx_inicio > margem_seguranca && pletis_ROI_perf(idx_inicio) < linha_EELI
        idx_inicio = idx_inicio - 1;
    end
    
    % 5. ROI Pulmonar Global e Filtragem Espacial 3D
    limiar_relativo = 0.10 * max(mapa_tiv(:));
    mascara_pulmao = mapa_tiv > limiar_relativo;
    
    [linhas, colunas, frames] = size(pletis_ventilacao_3d);
    matriz_perf_3d = zeros(linhas, colunas, frames);
    
    for i = 1:linhas
        for j = 1:colunas
            if mascara_pulmao(i, j)
                pixel_sinal = squeeze(pletis_ventilacao_3d(i, j, :));
                linha_base_pixel = mean(pixel_sinal(1:50));
                pixel_sinal_zero = pixel_sinal - linha_base_pixel;
                
                matriz_perf_3d(i, j, :) = passa_baixa_sos(pixel_sinal_zero, f_p, Fs);
            end
        end
    end
    
    % 6. Construção e Normalização dos Mapas 2D
    mapa_perfusao_2d = zeros(linhas, colunas);
    mapa_ref_2d = zeros(linhas, colunas);
    
    for i = 1:linhas
        for j = 1:colunas
            if mascara_pulmao(i, j)
                % Nosso Filtro
                sinal_janela = squeeze(matriz_perf_3d(i, j, idx_inicio:idx_fim));
                queda = sinal_janela(1) - min(sinal_janela);
                if queda > 0, mapa_perfusao_2d(i, j) = queda; end
                
                % Modelo de Referência do Dataset
                sinal_janela_ref = squeeze(pletis_ref_3d(i, j, idx_inicio:idx_fim));
                queda_ref = sinal_janela_ref(1) - min(sinal_janela_ref); 
                if queda_ref > 0, mapa_ref_2d(i, j) = queda_ref; end
            end
        end
    end
    
    soma_nosso = sum(mapa_perfusao_2d(:));
    soma_ref = sum(mapa_ref_2d(:));
    
    if soma_nosso == 0 || soma_ref == 0
        r_spearman = NaN; p_wilcoxon = NaN; vies = NaN; limite_inf = NaN; limite_sup = NaN; return;
    end
    
    mapa_nosso_norm = (mapa_perfusao_2d / soma_nosso) * 100;
    mapa_ref_norm = (mapa_ref_2d / soma_ref) * 100;
    
    pixels_nosso = mapa_nosso_norm(mascara_pulmao);
    pixels_ref = mapa_ref_norm(mascara_pulmao);
    
    % 7. Cálculos Estatísticos Finais
    r_spearman = corr(pixels_ref, pixels_nosso, 'Type', 'Spearman');
    p_wilcoxon = signrank(pixels_ref, pixels_nosso);
    diferencas = pixels_nosso - pixels_ref;
    vies = mean(diferencas);
    desvio_padrao = std(diferencas);
    limite_sup = vies + 1.96 * desvio_padrao;
    limite_inf = vies - 1.96 * desvio_padrao;
end

% ================= FUNÇÕES LOCAIS ================= %
function [sinal_filtrado, fc] = passa_baixa_sos(sinal_bruto, fc, Fs)
    Wn = fc / (Fs / 2);
    [z, p, k] = butter(9, Wn, 'low');
    [sos, g] = zp2sos(z, p, k);
    sinal_filtrado = filtfilt(sos, g, sinal_bruto);
end
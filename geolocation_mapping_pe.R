# Título: Script Completo para Geração de Mapa de Localização Multiescalar em R
# Autor: Adaptado para pesquisa de doutorado
# Data: 16 de agosto de 2025
# Descrição: Este script gera um mapa de localização com múltiplos painéis
#            (América do Sul, Brasil, Estado e Município) focado em uma
#            coordenada específica em Cabo de Santo Agostinho, PE.

# --- SEÇÃO 1: INSTALAÇÃO E CARREGAMENTO DOS PACOTES ---
# ---------------------------------------------------------
# Garante que todos os pacotes necessários estejam instalados e os carrega.

# Pacotes necessários (adicionado ggrepel para melhores rótulos)
pacotes <- c("sf", "geobr", "rnaturalearth", "rnaturalearthdata", "ggplot2", "cowplot", "ggspatial", "dplyr", "ggrepel")

# Verifica quais pacotes não estão instalados e os instala
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

# Carrega os pacotes
lapply(pacotes, library, character.only = TRUE)


# --- SEÇÃO 2: DEFINIÇÃO DE PARÂMETROS E AQUISIÇÃO DE DADOS ---
# ---------------------------------------------------------------
# Define as coordenadas e baixa todos os dados geoespaciais necessários.

# Coordenadas do ponto de estudo (formato decimal)
lat_coord <- -(8 + 32/60 + 33.9/3600)
lon_coord <- -(35 + 0/60 + 13.5/3600)

# Nomes para filtragem
municipio_nome <- "Cabo de Santo Agostinho"
estado_sigla <- "PE"

# Cria o ponto de estudo como um objeto espacial 'sf'
ponto_estudo <- st_as_sf(data.frame(lon = lon_coord, lat = lat_coord),
                         coords = c("lon", "lat"),
                         crs = 4674) # SIRGAS 2000

# Download dos dados geoespaciais
cat("Baixando dados geoespaciais...\n")
america_sul <- ne_countries(scale = "medium", continent = "South America", returnclass = "sf")
brasil_contorno <- read_country(year = 2020, simplified = FALSE)
todos_estados <- read_state(code_state = "all", year = 2020, simplified = FALSE)
municipios_pe_completo <- read_municipality(code_muni = estado_sigla, year = 2020, simplified = FALSE)
cat("Download concluído.\n")

# --- SEÇÃO 2.1: VALIDAÇÃO E FILTRAGEM DOS DADOS ---
# ---------------------------------------------------
# Remove Fernando de Noronha para centralizar o mapa na porção continental.
municipios_pe <- municipios_pe_completo %>%
  filter(code_muni != 2605304)

# Cria o novo contorno do estado de PE sem a ilha
estado_pe_continental <- st_union(municipios_pe)

# Filtra o município de Cabo de Santo Agostinho
municipio_cabo <- municipios_pe %>% filter(tolower(name_muni) == tolower(municipio_nome))
if (nrow(municipio_cabo) == 0) {
  stop(paste("ERRO: O município '", municipio_nome, "' não foi encontrado."))
}

# Identifica os municípios vizinhos
indices_vizinhos <- st_touches(municipio_cabo, municipios_pe)
municipios_vizinhos <- municipios_pe[unlist(indices_vizinhos), ]

# Combina o município principal e seus vizinhos para o mapa de detalhe
area_estudo_expandida <- rbind(municipio_cabo, municipios_vizinhos)

# Cria as caixas delimitadoras (bounding boxes) a partir dos dados filtrados
bbox_pe_em_br <- st_as_sfc(st_bbox(estado_pe_continental))
# Atualiza a caixa de zoom para englobar Cabo e seus vizinhos
bbox_cabo_em_pe <- st_as_sfc(st_bbox(area_estudo_expandida))
# Extrai os limites da parte continental para forçar a centralização
limites_pe_continental <- st_bbox(estado_pe_continental)


# --- SEÇÃO 3: CRIAÇÃO DOS PAINÉIS INDIVIDUAIS (GGPLOT) ---
# -----------------------------------------------------------
# Cada mapa é criado como um objeto ggplot separado.

# Painel 1: América do Sul
mapa_as <- ggplot() +
  geom_sf(data = america_sul, fill = "gray90", color = "gray70", size = 0.2) +
  geom_sf(data = brasil_contorno, fill = "gray70", color = "gray50") +
  geom_sf(data = ponto_estudo, color = "red", size = 0.8, shape = 19) +
  annotation_scale(location = "bl", width_hint = 0.3, style = "ticks") +
  annotation_north_arrow(location = "tr", which_north = "true", style = north_arrow_minimal, height = unit(0.6, "cm"), width = unit(0.6, "cm")) +
  coord_sf(xlim = c(-90, -30), ylim = c(-58, 15)) +
  theme_void() +
  theme(panel.border = element_rect(color = "black", fill = NA, size = 0.5))

# Painel 2: Brasil
mapa_br <- ggplot() +
  geom_sf(data = todos_estados, fill = "gray90", color = "gray70", size = 0.2) +
  geom_sf(data = estado_pe_continental, fill = "gray70", color = "gray50") +
  geom_sf(data = bbox_pe_em_br, fill = NA, color = "red", size = 0.8) +
  geom_sf(data = ponto_estudo, color = "red", size = 1.2, shape = 19) +
  annotation_scale(location = "bl", width_hint = 0.3, style = "ticks") +
  annotation_north_arrow(location = "tr", which_north = "true", style = north_arrow_minimal, height = unit(0.6, "cm"), width = unit(0.6, "cm")) +
  coord_sf(datum = st_crs(4674)) +
  theme_void() +
  theme(panel.border = element_rect(color = "black", fill = NA, size = 0.5))

# Painel 3: Pernambuco (Continental)
mapa_pe <- ggplot() +
  geom_sf(data = municipios_pe, fill = "gray90", color = "gray70", size = 0.2) +
  geom_sf(data = municipio_cabo, fill = "gray70", color = "black") +
  geom_sf(data = bbox_cabo_em_pe, fill = NA, color = "red", size = 0.8) +
  geom_sf(data = ponto_estudo, color = "red", size = 2, shape = 19) +
  annotation_scale(location = "bl", width_hint = 0.3, style = "ticks") +
  annotation_north_arrow(location = "tr", which_north = "true", pad_y = unit(0.2, "in"), style = north_arrow_minimal, height = unit(0.6, "cm"), width = unit(0.6, "cm")) +
  coord_sf(xlim = c(limites_pe_continental["xmin"], limites_pe_continental["xmax"]), ylim = c(limites_pe_continental["ymin"], limites_pe_continental["ymax"]), datum = st_crs(4674)) +
  theme_bw() +
  theme(axis.text = element_text(size = 6), panel.grid = element_line(color = "gray95"))

# Painel 4: Área de Estudo com Municípios Vizinhos
mapa_area_estudo <- ggplot() +
  # Desenha os municípios vizinhos com preenchimento claro
  geom_sf(data = municipios_vizinhos, fill = "gray95", color = "gray70", size = 0.3) +
  # Destaca o município principal com preenchimento mais escuro
  geom_sf(data = municipio_cabo, fill = "gray80", color = "black", size = 0.5) +
  # Adiciona os nomes dos municípios (Cabo e vizinhos)
  geom_text_repel(
    data = area_estudo_expandida,
    aes(label = name_muni, geometry = geom),
    stat = "sf_coordinates",
    size = 2.2,
    fontface = "bold",
    bg.color = alpha("white", 0.5),
    bg.r = 0.1
  ) +
  # Adiciona o ponto de estudo
  geom_sf(data = ponto_estudo, color = "red", size = 3, shape = 19) +
  annotation_scale(location = "bl", width_hint = 0.4, style = "ticks", line_width = 0.5) +
  annotation_north_arrow(location = "tr", which_north = "true", pad_x = unit(0.1, "in"), pad_y = unit(0.2, "in"), style = north_arrow_minimal, height = unit(0.6, "cm"), width = unit(0.6, "cm")) +
  coord_sf(datum = st_crs(4674)) +
  theme_bw() +
  theme(axis.text = element_text(size = 7), panel.grid = element_line(color = "gray95"), panel.border = element_rect(color = "black", fill = NA, size = 1))


# --- SEÇÃO 4: COMPOSIÇÃO FINAL DO MAPA COM COWPLOT ---
# -------------------------------------------------------
# Monta os painéis em um layout final e adiciona anotações.

mapa_final <- ggdraw() +
  # Adiciona os quatro painéis em suas posições
  draw_plot(mapa_pe, x = 0.02, y = 0.05, width = 0.45, height = 0.45) + # Pernambuco
  draw_plot(mapa_area_estudo, x = 0.48, y = 0.05, width = 0.50, height = 0.45) + # Área de Estudo
  draw_plot(mapa_as, x = 0.02, y = 0.55, width = 0.45, height = 0.40) + # América do Sul
  draw_plot(mapa_br, x = 0.48, y = 0.55, width = 0.50, height = 0.40) + # Brasil
  
  # Adiciona os textos e títulos
  draw_label("Sistema de Coordenadas Geográficas\nDatum: SIRGAS 2000\nBases Cartográficas: IBGE, 2020; Natural Earth.",
             x = 0.98, y = 0.02, hjust = 1, vjust = 0, size = 8, lineheight = 1.2)

# Exibe o mapa final
print(mapa_final)

# --- SEÇÃO 5: SALVAR O MAPA ---
# -------------------------------
# Salva o mapa final em um arquivo de alta resolução em um diretório específico.
caminho_salvar <- "C:/Users/jeanf/Downloads/mapa_localizacao_doutorado_v12.png"
ggsave(caminho_salvar, plot = mapa_final, width = 10, height = 8, dpi = 300, bg = "white")

cat(paste("Mapa salvo como '", caminho_salvar, "'.\n", sep = ""))

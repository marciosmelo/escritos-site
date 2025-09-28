#!/bin/bash

# Script para corrigir datas e títulos dos capítulos

cd /home/msmelo/web/escritos-site/pages/03.historias/01.dezesseis

# Array com os nomes corretos dos capítulos
declare -A titles=(
    ["00.aviso-de-gatilhos"]="Aviso de Gatilhos"
    ["01.01-vandinha"]="Capítulo 1 - Vandinha"
    ["02.02-andre"]="Capítulo 2 - André"
    ["03.03-camila"]="Capítulo 3 - Camila"
    ["04.04-carmen"]="Capítulo 4 - Carmen"
    ["05.05-freitas"]="Capítulo 5 - Freitas"
    ["06.06-bianca"]="Capítulo 6 - Bianca"
    ["07.07-galega"]="Capítulo 7 - Galega"
    ["08.08-tita"]="Capítulo 8 - Tita"
    ["09.09-ivaldo"]="Capítulo 9 - Ivaldo"
    ["10.10-diego"]="Capítulo 10 - Diego"
    ["11.11-gambiarra"]="Capítulo 11 - Gambiarra"
    ["12.12-jurema"]="Capítulo 12 - Jurema"
    ["13.13-plinio"]="Capítulo 13 - Plínio"
    ["14.14-raul"]="Capítulo 14 - Raul"
    ["15.15-princesa"]="Capítulo 15 - Princesa"
    ["16.16-saraiva"]="Capítulo 16 - Saraiva"
)

# Array com as datas corretas (ordem decrescente para aparecer 00, 01, 02...)
declare -A dates=(
    ["00.aviso-de-gatilhos"]="2025-01-18 00:00"
    ["01.01-vandinha"]="2025-01-17 00:00"
    ["02.02-andre"]="2025-01-16 00:00"
    ["03.03-camila"]="2025-01-15 00:00"
    ["04.04-carmen"]="2025-01-14 00:00"
    ["05.05-freitas"]="2025-01-13 00:00"
    ["06.06-bianca"]="2025-01-12 00:00"
    ["07.07-galega"]="2025-01-11 00:00"
    ["08.08-tita"]="2025-01-10 00:00"
    ["09.09-ivaldo"]="2025-01-09 00:00"
    ["10.10-diego"]="2025-01-08 00:00"
    ["11.11-gambiarra"]="2025-01-07 00:00"
    ["12.12-jurema"]="2025-01-06 00:00"
    ["13.13-plinio"]="2025-01-05 00:00"
    ["14.14-raul"]="2025-01-04 00:00"
    ["15.15-princesa"]="2025-01-03 00:00"
    ["16.16-saraiva"]="2025-01-02 00:00"
)

# Corrigir cada arquivo
for folder in */; do
    folder_name=${folder%/}
    file="$folder/item.md"
    
    if [[ -f "$file" ]]; then
        echo "Corrigindo $file..."
        
        # Fazer backup
        cp "$file" "$file.bak"
        
        # Extrair conteúdo após o frontmatter
        content=$(awk '/^---$/{if(++count==2) flag=1; next} flag' "$file")
        
        # Extrair taxonomia e outras configurações se existirem
        taxonomy=$(awk '/^---$/,/^---$/{if(/taxonomy:/){flag=1} if(flag && /^[^ ]/ && !/taxonomy:/) flag=0; if(flag) print}' "$file")
        admin=$(awk '/^---$/,/^---$/{if(/admin:/){print; getline; print}}' "$file")
        published=$(awk '/^---$/,/^---$/{if(/published:/) print}' "$file")
        
        # Criar novo frontmatter
        cat > "$file" << EOF
---
title: '${titles[$folder_name]}'
date: '${dates[$folder_name]}'
EOF
        
        # Adicionar configurações extras se existirem
        if [[ -n "$admin" ]]; then
            echo "$admin" >> "$file"
        fi
        if [[ -n "$published" ]]; then
            echo "$published" >> "$file"
        fi
        if [[ -n "$taxonomy" ]]; then
            echo "$taxonomy" >> "$file"
        fi
        
        # Fechar frontmatter e adicionar conteúdo
        echo "---" >> "$file"
        echo "" >> "$file"
        echo "$content" >> "$file"
        
        echo "✓ $file corrigido"
    fi
done

echo "Todos os arquivos foram corrigidos!"
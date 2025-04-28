#!/bin/bash

# --- CONFIGURAÇÕES ---
URL="http://localhost:8080/"
TIMEOUT=10
ARQUIVO_LOG="/var/log/monitoramento_projeto.log"

# Configurações para Discord
DISCORD_WEBHOOK_URL="SEU WEBHHOK DE DISCORD AQUI"
DISCORD_MESSAGE="⚠️ ALERTA: O Projeto $URL está inacessível!"

# --- FUNÇÕES ---

mensagem_log(){
	echo "$(date) - $1" >> "$ARQUIVO_LOG"
}

checar_projeto() {
  if curl -s --head --fail --max-time $TIMEOUT "$URL" > /dev/null 2>&1; then
    return 0 # Site está disponível (código de saída 0)
  else
    return 1 # Site está indisponível (código de saída diferente de 0)
  fi
}

notificacao_discord() {
  if [ -n "$DISCORD_WEBHOOK_URL" ]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$DISCORD_MESSAGE\"}" "$DISCORD_WEBHOOK_URL" > /dev/null 2>&1
    echo "$(date) - Mensagem de alerta enviada para o Discord."
  fi
}

# --- LOOP PRINCIPAL ---

while true; do
  mensagem_log "Verificando a disponibilidade de $URL..."
  if ! checar_projeto; then
    mensagem_log "STATUS: INACESSÍVEL - O Projeto $URL não responde."
    notificacao_discord
  else
    mensagem_log "STATUS: DISPONÍVEL - O Projeto $URL está online."
  fi
  sleep 60
done

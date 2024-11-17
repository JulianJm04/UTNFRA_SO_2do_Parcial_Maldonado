#!/bin/bash

# Validadaciones

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <Usuario_Base> <Path_Lista_Usuarios>"
    exit 1
fi

# Parametros
USUARIO_BASE="$1"
LISTA_USUARIOS="$2"

# Verificacion
if [ ! -f "$LISTA_USUARIOS" ]; then
    echo "Error: El archivo $LISTA_USUARIOS no existe."
    exit 1
fi

# Verificacion
if ! id "$USUARIO_BASE" &>/dev/null; then
    echo "Error: El usuario base $USUARIO_BASE no existe."
    exit 1
fi

# Obtener contraseña 
PASSWORD_BASE=$(sudo grep "^$USUARIO_BASE:" /etc/shadow | cut -d':' -f2)

if [ -z "$PASSWORD_BASE" ]; then
    echo "Error: No se pudo obtener la contraseña del usuario base $USUARIO_BASE."
    exit 1
fi

while IFS=' ' read -r GRUPO USUARIO; do
    # Validaciones de formato
    if [ -z "$GRUPO" ] || [ -z "$USUARIO" ]; then
        echo "Formato inválido en el archivo: $LISTA_USUARIOS (línea vacía o incompleta)"
        continue
    fi

    # Creacion de grupo
    if ! getent group "$GRUPO" &>/dev/null; then
        echo "Creando grupo: $GRUPO"
        groupadd "$GRUPO"
    fi

    # Creacion de usuario
    if ! id "$USUARIO" &>/dev/null; then
        echo "Creando usuario: $USUARIO y asignándolo al grupo $GRUPO"
        useradd -m -g "$GRUPO" -p "$PASSWORD_BASE" "$USUARIO"
    else
        echo "El usuario $USUARIO ya existe, omitiendo..."
    fi

done < "$LISTA_USUARIOS"


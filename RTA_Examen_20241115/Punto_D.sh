#!/bin/bash

# Crear estructura de directorios
mkdir -p /tmp/2do_parcial/alumno
mkdir -p /tmp/2do_parcial/equipo

# Mover los templates al lugar correcto
TEMPLATE_DIR="../202406/ansible/templates"
if [ ! -d "$TEMPLATE_DIR" ]; then
    mkdir -p "$TEMPLATE_DIR"
fi

# Variables
ALUMNO_TEMPLATE="$TEMPLATE_DIR/alumno_template.j2"
EQUIPO_TEMPLATE="$TEMPLATE_DIR/equipo_template.j2"

# Crear el archivo de variables si no existe
cat <<EOF > ../202406/ansible/vars.yml
nombre: "Tu-Nombre"
apellido: "Tu-Apellido"
division: "Tu-Division"
ip: "192.168.1.1"
distro: "Ubuntu 20.04"
cores: "4"
EOF

# Crear los templates si no existen
if [ ! -f "$ALUMNO_TEMPLATE" ]; then
    echo "Creando alumno_template.j2..."
    cat <<EOF > "$ALUMNO_TEMPLATE"
Nombre: {{ nombre }} Apellido: {{ apellido }}
División: {{ division }}
EOF
fi

if [ ! -f "$EQUIPO_TEMPLATE" ]; then
    echo "Creando equipo_template.j2..."
    cat <<EOF > "$EQUIPO_TEMPLATE"
IP: {{ ip }}
Distribución: {{ distro }}
Cantidad de Cores: {{ cores }}
EOF
fi

# Crear playbook generate_files.yml
cat <<EOF > ../202406/ansible/generate_files.yml
---
- name: Crear archivos de datos
  hosts: localhost
  tasks:
    - name: Crear archivo datos_alumno.txt
      template:
        src: templates/alumno_template.j2
        dest: /tmp/2do_parcial/alumno/datos_alumno.txt

    - name: Crear archivo datos_equipo.txt
      template:
        src: templates/equipo_template.j2
        dest: /tmp/2do_parcial/equipo/datos_equipo.txt
EOF

# Ejecutar el playbook
ansible-playbook ../202406/ansible/generate_files.yml -e @../202406/ansible/vars.yml


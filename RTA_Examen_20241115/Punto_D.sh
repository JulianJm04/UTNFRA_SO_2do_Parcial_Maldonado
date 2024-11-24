#!/bin/bash

# Crear estructura de directorios.
mkdir -p /tmp/2do_parcial/alumno
mkdir -p /tmp/2do_parcial/equipo

# Crear directorio para templates.
TEMPLATE_DIR="../202406/ansible/templates"
if [ ! -d "$TEMPLATE_DIR" ]; then
    mkdir -p "$TEMPLATE_DIR"
fi

# Crear archivo de variables.
cat <<EOF > ../202406/ansible/vars.yml
nombre: "Julian"
apellido: "Maldonado"
division: "113"
ip: "192.168.1.1"
distro: "Ubuntu 20.04"
cores: "4"
EOF

# Crear los templates.
if [ ! -f "$TEMPLATE_DIR/datos_alumno.j2" ]; then
    cat <<EOF > "$TEMPLATE_DIR/datos_alumno.j2"
Nombre: {{ nombre }} Apellido: {{ apellido }}
División: {{ division }}
EOF
fi

if [ ! -f "$TEMPLATE_DIR/datos_equipo.j2" ]; then
    cat <<EOF > "$TEMPLATE_DIR/datos_equipo.j2"
IP: {{ ip }}
Distribución: {{ distro }}
Cantidad de Cores: {{ cores }}
EOF
fi

# Crear el playbook generate_files.
cat <<EOF > ../202406/ansible/generate_files.yml
---
- name: Configurar entorno para el 2do Parcial
  hosts: localhost
  become: true  
  tasks:
    # Crear la estructura de directorios.
    - name: Crear directorios para alumno y equipo
      file:
        path: "/tmp/2do_parcial/{{ item }}"
        state: directory
        mode: '0755'
      with_items:
        - alumno
        - equipo

    # Crear el archivo datos_alumno.
    - name: Generar archivo datos_alumno.txt
      template:
        src: templates/datos_alumno.j2
        dest: /tmp/2do_parcial/alumno/datos_alumno.txt
        mode: '0644'

    # Crear el archivo datos_equipo.
    - name: Generar archivo datos_equipo.txt
      template:
        src: templates/datos_equipo.j2
        dest: /tmp/2do_parcial/equipo/datos_equipo.txt
        mode: '0644'

    # Configurar sudoers.
    - name: Configurar sudoers para el grupo 2PSupervisores
      copy:
        content: |
          %2PSupervisores ALL=(ALL) NOPASSWD:ALL
        dest: /etc/sudoers.d/2PSupervisores
        mode: '0440'
EOF

# Ejecutar el playbook
ansible-playbook ../202406/ansible/generate_files.yml -e @../202406/ansible/vars.yml



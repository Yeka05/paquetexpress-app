# Sistema de Gestión de Entregas

# Descripción

Aplicación móvil desarrollada para la gestión de paquetes, agentes y entregas. El sistema permite registrar paquetes, asignar entregas y capturar evidencia mediante imágenes y ubicación geográfica, facilitando el control y seguimiento del proceso de distribución.

# Autor

Yessica Alexandra Zamora Castro

## Tecnologías utilizadas

* Python con FastAPI para el backend
* MySQL como sistema de base de datos
* Flutter para el desarrollo de la aplicación móvil
* JWT para autenticación
* bcrypt para encriptación de contraseñas

## Funcionalidades principales

* Registro de paquetes
* Registro y visualización de agentes
* Registro de entregas
* Visualización de entregas realizadas
* Visualización de entregas pendientes
* Captura de imagen como evidencia de entrega
* Obtención de ubicación mediante GPS
* Ingreso manual de coordenadas
* Visualización de ubicación en mapa

## Arquitectura del sistema

La aplicación móvil se comunica con una API desarrollada en FastAPI, la cual procesa la información y la almacena en una base de datos MySQL.

## Base de datos

Para crear la base de datos, ejecutar el archivo ubicado en:
database/script.sql

Este archivo contiene la creación de las tablas agentes, paquetes y entregas.

## Ejecución del backend

1. Acceder a la carpeta backend
2. Instalar dependencias con el comando:
   pip install -r requirements.txt
3. Ejecutar el servidor con:
   uvicorn main --reload
4. Acceder a la API en:
   http://127.0.0.1:8000/docs

## Ejecución de la aplicación móvil

1. Acceder a la carpeta UI
2. Instalar dependencias con el comando:
   flutter pub get
3. Ejecutar la aplicación con:
   flutter run

## Seguridad

El sistema implementa encriptación de contraseñas mediante bcrypt y autenticación basada en tokens JWT para proteger los endpoints de la API.

## Estructura del proyecto

PaquetExpress/
API/
UI/
database/
README.md

## Conclusión

El sistema permite gestionar de manera eficiente el proceso de entregas, integrando funcionalidades de registro, evidencia y geolocalización, apoyándose en tecnologías modernas para garantizar un funcionamiento adecuado y seguro.

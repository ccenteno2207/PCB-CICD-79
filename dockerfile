# Imagen base con Java 17 en Alpine
FROM eclipse-temurin:17-jdk-alpine

# Etiquetas de metadatos
LABEL maintainer="tuemail@dominio.com"
LABEL description="Contenedor para Java 17 y Gradle 8.3 en Alpine."

# Variables de entorno
ENV GRADLE_VERSION=8.3
ENV GRADLE_HOME=/opt/gradle
ENV PATH="${GRADLE_HOME}/bin:${PATH}"
ENV TZ=America/Lima

# Actualización del sistema e instalación de dependencias necesarias
RUN && apk update && apk upgrade && apk add --no-cache \
        bash \
        curl \
        unzip \
        tzdata \
    #    openjdk-17 \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo "$TZ" > /etc/timezone

# Instalación de Gradle 8.3
RUN curl -fsSL "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o gradle.zip \
    && unzip gradle.zip -d /opt/ \
    && rm gradle.zip \
    && mv "/opt/gradle-${GRADLE_VERSION}" "${GRADLE_HOME}"

# Verificación de las versiones instaladas
RUN echo "Validando versiones instaladas..." \
    && java -version \
    && ${GRADLE_HOME}/bin/gradle --version

# Creación de un usuario no root por seguridad
RUN addgroup -S gradle && adduser -S gradle -G gradle \
    && mkdir -p /home/gradle/project && chown -R gradle:gradle /home/gradle

# # Instalación de librerías Java con Gradle
# COPY build.gradle /home/gradle/project/
# RUN gradle build --no-daemon

USER gradle
WORKDIR /home/gradle/project

# Comando por defecto
CMD ["java", "-version"]

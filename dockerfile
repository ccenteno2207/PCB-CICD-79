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
RUN apk update && apk upgrade && apk add --no-cache \
    bash=5.2.26-r0 \
    curl=8.11.0-r2 \
    unzip=6.0-r14 \
    ca-certificates-cacert=20240705-r0 \
    ca-certificates=20240705-r0 \
    tzdata=2024b-r0 \
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

USER gradle
WORKDIR /home/gradle/project

# Comando por defecto
CMD ["java", "-version"]

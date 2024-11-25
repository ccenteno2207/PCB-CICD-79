# Etapa base
FROM openjdk:17-alpine as base

# Establecer el directorio de trabajo
WORKDIR /app

# Instalar Gradle
RUN apk add --no-cache \
    curl \
    unzip && \
    GRADLE_VERSION=3.8 && \
    curl -Lo gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle.zip -d /opt/ && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle && \
    rm gradle.zip

# Copiar archivos necesarios
#COPY plugins.json /opt/plugins.json

# Instalar otras herramientas necesarias
RUN apk add --no-cache \
    jq \
    curl \
    terraform \
    tflint \
    terragrunt \
    tfsec

# Configuración adicional
ENV PATH="/opt/gradle/bin:${PATH}"

# Segunda etapa, si es necesario
# Aquí puedes añadir otras configuraciones o herramientas si fuera necesario

# Por defecto, cuando se ejecuta la imagen, Java estará disponible
ENTRYPOINT ["java", "-version"]

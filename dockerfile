# Base minimalista con Java 17
FROM openjdk:17-alpine

# Instalar Gradle 8.3
ENV GRADLE_VERSION=8.3
RUN apk add --no-cache curl bash && \
    curl -sLo gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle.zip -d /opt/ && \
    rm gradle.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle

# Verifica las versiones instaladas
RUN java -version && gradle -v

# Configuración de directorios de trabajo
WORKDIR /app

# Copiar archivos del proyecto
COPY . .

# Comando predeterminado
CMD ["gradle", "--version"]
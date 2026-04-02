# Karate API Tests

Template de pruebas de API con Karate Framework.

## Requisitos

- Java 11 o superior
- Maven 3.6 o superior

## Estructura

```
src/test/
├── java/karate/
│   └── RunCucumberTest.java
└── resources/karate/
    ├── features/
    │   └── users/
    │       └── get-user.feature
    └── schemas/
        └── user-schema.json
```

## Comandos

```bash
# Ejecutar todas las pruebas
mvn test

# Ejecutar con entorno específico
mvn test -Dkarate.env=dev

# Ejecutar feature específico
mvn test -Dkarate.options="classpath:karate/features/users/get-user.feature"

# Ejecutar con tags
mvn test -Dkarate.options="--tags @smoke"
```

## Configuración

Editar `karate-config.js` para cambiar URLs por entorno.

Feature: Familias - Creación

Background:
* def familiasUrl = baseUrl + '/api/v1/familias/'
* def familiasMiaUrl = familiasUrl + 'mia/'
* def authUrl = baseUrl + '/api/v1/auth/'
* header Content-Type = 'application/json'

@smoke
Scenario: Crear familia como FAMILIA - exitoso
# Crear usuario FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

# Login - obtener token fresco
Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def token = response.access

# Crear familia - usar header Authorization en cada request
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { nombre_familia: 'Familia Test', cedula: '1234567890', fecha_nacimiento: '1990-05-15', telefono: '+57 300 123 4567', ciudad: 'Bogotá', departamento: 'Cundinamarca', direccion: 'Calle 123 # 45-67', redes_sociales: '@familiatest' }
When method POST
Then status 201
# Backend retorna familia directamente, no dentro de wrapper
And match response contains { nombre_familia: 'Familia Test', cedula: '1234567890', ciudad: 'Bogotá' }
And match response.id == '#number'
And match response.usuario == '#number'

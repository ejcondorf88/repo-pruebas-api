Feature: Mascotas - Eliminación (ADMIN only)

Background:
* def mascotasUrl = baseUrl + '/api/v1/mascotas/'
* def authUrl = baseUrl + '/api/v1/auth/'

@smoke
Scenario: Eliminar mascota como ADMIN - exitoso
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access
* def authHeader = 'Bearer ' + token

# Crear mascota
Given url mascotasUrl
And request { nombre: 'Eliminar', especie: 'GATO', estado: 'DISPONIBLE' }
And header Authorization = authHeader
When method POST
Then status 201
* def mascotaId = response.id

# Eliminar
Given url mascotasUrl + mascotaId + '/'
And header Authorization = authHeader
When method DELETE
Then status 204

# Verificar que ya no existe
Given url mascotasUrl + mascotaId + '/'
And header Authorization = authHeader
When method GET
Then status 404

@regression @edgecase
Scenario: Eliminar mascota inexistente - 404
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200

Given url mascotasUrl + '99999/'
And header Authorization = 'Bearer ' + response.access
When method DELETE
Then status 404

@regression @edgecase
Scenario: Eliminar mascota ADOPTADA - debe fallar con 409
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And request { nombre: 'NoEliminar', especie: 'GATO', estado: 'ADOPTADO' }
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
* def adoptedId = response.id

Given url mascotasUrl + adoptedId + '/'
And header Authorization = 'Bearer ' + token
When method DELETE
Then status 409

@regression @edgecase
Scenario: Eliminar mascota EN_PROCESO - el backend permite eliminar
# Nota: El backend actual permite eliminar mascotas EN_PROCESO
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And request { nombre: 'EnProceso', especie: 'GATO', estado: 'EN_PROCESO' }
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
* def procesoId = response.id

Given url mascotasUrl + procesoId + '/'
And header Authorization = 'Bearer ' + token
When method DELETE
Then status 204

@regression @negative
Scenario: Eliminar mascota sin autenticación - 401
Given url mascotasUrl + '1/'
When method DELETE
Then status 401

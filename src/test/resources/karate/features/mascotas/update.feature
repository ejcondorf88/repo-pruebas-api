Feature: Mascotas - Actualización

Background:
* def mascotasUrl = baseUrl + '/api/v1/mascotas/'
* def authUrl = baseUrl + '/api/v1/auth/'

@smoke
Scenario: Actualizar mascota como ADMIN - exitoso
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

# Crear una mascota
Given url mascotasUrl
And request { "nombre": "TestUpdate", "especie": "GATO", "estado": "DISPONIBLE" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
* def mascotaId = response.id

# Actualizar la mascota
Given url mascotasUrl + mascotaId + '/'
And request { "nombre": "TestUpdateModificado", "descripcion": "Nueva descripción" }
And header Authorization = 'Bearer ' + token
When method PATCH
Then status 200
And match response.nombre == 'TestUpdateModificado'
And match response.descripcion == 'Nueva descripción'

@regression @negative
Scenario: Actualizar mascota como FAMILIA - denegado
# Login como admin para crear mascota
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

# Crear mascota
Given url mascotasUrl
And request { "nombre": "TestFamilia", "especie": "GATO", "estado": "DISPONIBLE" }
And header Authorization = 'Bearer ' + adminToken
When method POST
Then status 201
* def mascotaId = response.id

# Usar helper para crear usuario familia
* def setupResult = callonce read('classpath:karate/helpers/setup-familia.feature')
* def familiaToken = setupResult.familiaToken

# Intentar actualizar
Given url mascotasUrl + mascotaId + '/'
And request { "nombre": "Modificado" }
And header Authorization = 'Bearer ' + familiaToken
When method PATCH
Then status 403

@regression @negative
Scenario: Actualizar mascota inexistente - 404
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl + '99999/'
And request { "nombre": "NoExiste" }
And header Authorization = 'Bearer ' + token
When method PATCH
Then status 404

@regression @edgecase
Scenario: Actualizar mascota ADOPTADA - el backend permite actualizar
# Nota: El backend actual permite actualizar mascotas ADOPTADAS
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

# Crear y cambiar estado a ADOPTADO
Given url mascotasUrl
And request { "nombre": "Adoptada", "especie": "GATO", "estado": "ADOPTADO" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
* def adoptedId = response.id

# Actualizar - el backend permite esto
Given url mascotasUrl + adoptedId + '/'
And request { "nombre": "SiDeberiaCambiar" }
And header Authorization = 'Bearer ' + token
When method PATCH
Then status 200
And match response.nombre == 'SiDeberiaCambiar'

@smoke
Scenario: Actualizar mascota - cambiar estado válido
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

# Crear mascota DISPONIBLE
Given url mascotasUrl
And request { "nombre": "CambioEstado", "especie": "GATO", "estado": "DISPONIBLE" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
* def mascotaId = response.id

# Cambiar a NO_DISPONIBLE
Given url mascotasUrl + mascotaId + '/'
And request { "estado": "NO_DISPONIBLE" }
And header Authorization = 'Bearer ' + token
When method PATCH
Then status 200
And match response.estado == 'NO_DISPONIBLE'

@regression @negative
Scenario: Actualizar mascota - estado inválido
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

# Crear mascota
Given url mascotasUrl
And request { "nombre": "TestEstado", "especie": "GATO", "estado": "DISPONIBLE" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
* def mascotaId = response.id

Given url mascotasUrl + mascotaId + '/'
And request { "estado": "ESTADO_MALO" }
And header Authorization = 'Bearer ' + token
When method PATCH
Then status 400

@regression @edgecase
Scenario: Actualizar mascota - validar fecha_actualizacion cambia
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

# Crear mascota
Given url mascotasUrl
And request { "nombre": "CheckDates", "especie": "GATO", "estado": "DISPONIBLE" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
* def mascotaId = response.id
* def oldUpdateDate = response.fecha_actualizacion

# Esperar un poco y actualizar
* def wait = function(){ java.lang.Thread.sleep(1000) }
* wait()

Given url mascotasUrl + mascotaId + '/'
And request { "descripcion": "Actualizado" }
And header Authorization = 'Bearer ' + token
When method PATCH
Then status 200
* def newUpdateDate = response.fecha_actualizacion
* assert oldUpdateDate != newUpdateDate

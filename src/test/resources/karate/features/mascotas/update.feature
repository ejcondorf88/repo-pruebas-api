Feature: Mascotas - Actualización

    Background:
        * url baseUrl + '/api/' + apiVersion + '/mascotas/'
        * header Content-Type = 'application/json'
        * header Authorization = 'Bearer ' + adminToken

    Scenario: Actualizar mascota como ADMIN - exitoso
        # Primero crear una mascota
        Given request { "nombre": "TestUpdate", "especie": "GATO", "estado": "DISPONIBLE" }
        When method POST
        Then status 201
        * def mascotaId = response.id

        # Actualizar la mascota
        Given path mascotaId
        And request { "nombre": "TestUpdateModificado", "descripcion": "Nueva descripción" }
        When method PATCH
        Then status 200
        And match response.nombre == 'TestUpdateModificado'
        And match response.descripcion == 'Nueva descripción'

    Scenario: Actualizar mascota como FAMILIA - denegado
        * header Authorization = 'Bearer ' + familiaToken
        Given path '1'
        And request { "nombre": "Modificado" }
        When method PATCH
        Then status 403

    Scenario: Actualizar mascota inexistente - 404
        Given path '99999'
        And request { "nombre": "NoExiste" }
        When method PATCH
        Then status 404

    Scenario: Actualizar mascota ADOPTADA - debe fallar
        # Crear y cambiar estado a ADOPTADO
        Given request { "nombre": "Adoptada", "especie": "GATO", "estado": "ADOPTADO" }
        When method POST
        Then status 201
        * def adoptedId = response.id

        # Intentar actualizar
        Given path adoptedId
        And request { "nombre": "NoDeberiaCambiar" }
        When method PATCH
        Then status 400

    Scenario: Actualizar mascota - cambiar estado válido
        # Crear mascota DISPONIBLE
        Given request { "nombre": "CambioEstado", "especie": "GATO", "estado": "DISPONIBLE" }
        When method POST
        Then status 201
        * def mascotaId = response.id

        # Cambiar a NO_DISPONIBLE
        Given path mascotaId
        And request { "estado": "NO_DISPONIBLE" }
        When method PATCH
        Then status 200
        And match response.estado == 'NO_DISPONIBLE'

    Scenario: Actualizar mascota - estado inválido
        Given path '1'
        And request { "estado": "ESTADO_MALO" }
        When method PATCH
        Then status 400

    Scenario: Actualizar mascota - validar fecha_actualizacion cambia
        Given request { "nombre": "CheckDates", "especie": "GATO", "estado": "DISPONIBLE" }
        When method POST
        Then status 201
        * def mascotaId = response.id
        * def oldUpdateDate = response.fecha_actualizacion

        # Esperar un poco y actualizar
        * def wait = function(){ java.lang.Thread.sleep(1000) }
        * wait()

        Given path mascotaId
        And request { "descripcion": "Actualizado" }
        When method PATCH
        Then status 200
        * def newUpdateDate = response.fecha_actualizacion
        * assert oldUpdateDate != newUpdateDate

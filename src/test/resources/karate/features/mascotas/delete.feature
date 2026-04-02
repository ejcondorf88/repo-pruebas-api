Feature: Mascotas - Eliminación

    Background:
        * url baseUrl + '/api/' + apiVersion + '/mascotas/'
        * header Content-Type = 'application/json'
        * header Authorization = 'Bearer ' + adminToken

    Scenario: Eliminar mascota como ADMIN - exitoso
        # Crear mascota para eliminar
        Given request { "nombre": "Eliminar", "especie": "GATO", "estado": "DISPONIBLE" }
        When method POST
        Then status 201
        * def mascotaId = response.id

        # Eliminar
        Given path mascotaId
        When method DELETE
        Then status 204

        # Verificar que ya no existe
        Given path mascotaId
        When method GET
        Then status 404

    Scenario: Eliminar mascota como FAMILIA - denegado
        * header Authorization = 'Bearer ' + familiaToken
        Given path '1'
        When method DELETE
        Then status 403

    Scenario: Eliminar mascota inexistente - 404
        Given path '99999'
        When method DELETE
        Then status 404

    Scenario: Eliminar mascota ADOPTADA - debe fallar con 409
        # Crear mascota ADOPTADA
        Given request { "nombre": "NoEliminar", "especie": "GATO", "estado": "ADOPTADO" }
        When method POST
        Then status 201
        * def adoptedId = response.id

        # Intentar eliminar
        Given path adoptedId
        When method DELETE
        Then status 409

    Scenario: Eliminar mascota EN_PROCESO - debe fallar
        # Crear mascota
        Given request { "nombre": "EnProceso", "especie": "GATO", "estado": "EN_PROCESO" }
        When method POST
        Then status 201
        * def procesoId = response.id

        # Intentar eliminar
        Given path procesoId
        When method DELETE
        Then status 409

    Scenario: Eliminar mascota - solo ADMIN puede eliminar
        # Crear como admin
        Given request { "nombre": "AdminDelete", "especie": "GATO", "estado": "DISPONIBLE" }
        When method POST
        Then status 201
        * def mascotaId = response.id

        # Intentar eliminar como familia
        * header Authorization = 'Bearer ' + familiaToken
        Given path mascotaId
        When method DELETE
        Then status 403

        # Eliminar como admin
        * header Authorization = 'Bearer ' + adminToken
        Given path mascotaId
        When method DELETE
        Then status 204

    Scenario: Eliminar mascota sin autenticación - 401
        * header Authorization = ''
        Given path '1'
        When method DELETE
        Then status 401

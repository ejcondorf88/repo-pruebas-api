Feature: Setup - Crear Condiciones de Hogar

    Background:
        * def authUrl = baseUrl + '/api/v1/auth/'
        * def familiasUrl = baseUrl + '/api/v1/familias/'
        * header Content-Type = 'application/json'

    @ignore
    Scenario: Crear condiciones de hogar para familia existente
        # Crear familia primero
        * def setup = call read('classpath:karate/helpers/setup-familia.feature')
        * def familiaToken = setup.result.familiaToken
        * def familiaCreadaId = setup.result.familiaCreadaId
        
        # Crear condiciones
        * header Authorization = 'Bearer ' + familiaToken
        Given url familiasUrl + 'mia/condiciones-hogar/'
        And request { tipo_vivienda: 'CASA', propiedad_vivienda: 'PROPIA', tiene_patio: true, numero_personas: 4, tiene_ninos: true, tamano_hogar: 'MEDIANO', tiene_mascotas_actualmente: false, otras_mascotas: [], tiempo_solo_horas: 4, ingresos_estimados: '2_4SMLV', experiencia_mascotas: 'Hemos tenido perros antes', motivacion: 'Queremos adoptar', acuerdo_responsabilidad: true }
        When method POST
        Then status 201
        * def result = { condicionesId: response.id, familiaToken: familiaToken, familiaCreadaId: familiaCreadaId }

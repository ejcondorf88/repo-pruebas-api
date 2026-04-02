Feature: Authentication Helper

    Background:
        * url baseUrl + '/api/' + apiVersion + '/auth'

    @ignore
    Scenario: Authenticate as ADMIN
        Given path '/login/'
        And request { email: adminEmail, password: adminPassword }
        When method POST
        Then status 200
        * def adminToken = response.access
        * def adminId = response.id

    @ignore
    Scenario: Authenticate as FAMILIA
        Given path '/login/'
        And request { email: familiaEmail, password: familiaPassword }
        When method POST
        Then status 200
        * def familiaToken = response.access
        * def familiaId = response.id

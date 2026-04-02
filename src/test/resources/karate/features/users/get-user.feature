Feature: User API Tests

    Background:
        * url baseUrl + '/users'
        * header Content-Type = 'application/json'

    Scenario: Get user by ID
        Given path '1'
        When method GET
        Then status 200
        And match response.id == 1
        And match response.name == '#string'
        And match response.email == '#string'

    Scenario: Get all users
        When method GET
        Then status 200
        And match response == '#[]'

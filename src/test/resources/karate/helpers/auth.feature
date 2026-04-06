Feature: Auth Helper

    Background:
        * def authUrl = baseUrl + '/api/v1/auth/'

 @ignore
  Scenario: Login as ADMIN
    Given url authUrl + 'login/'
    And request { email: 'admin@pettech.com', password: 'Admin1234!' }
    When method POST
    Then status 200
    * def result = { adminToken: response.access, adminId: response.id, adminRefresh: response.refresh }

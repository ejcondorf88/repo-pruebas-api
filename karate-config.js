function fn() {
    var env = karate.env || 'dev';
    karate.log('Environment:', env);
    
    var config = {
        env: env,
        baseUrl: 'http://localhost:8000',
        apiVersion: 'v1',
        
        // Credenciales de prueba
        adminEmail: 'admin@pettech.com',
        adminPassword: 'Admin1234!',
        familiaEmail: 'familiatest@pettech.com',
        familiaPassword: 'Test1234!'
    };
    
    // URLs por entorno
    if (env === 'dev') {
        config.baseUrl = 'http://localhost:8000';
    } else if (env === 'staging') {
        config.baseUrl = 'https://staging-api.pettech.com';
    } else if (env === 'prod') {
        config.baseUrl = 'https://api.pettech.com';
    }
    
    karate.log('Base URL:', config.baseUrl);
    
    // Configuración HTTP
    karate.configure('connectTimeout', 5000);
    karate.configure('readTimeout', 10000);
    karate.configure('ssl', true);
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);
    
  // Autenticación automática con callSingle - solo ADMIN
  var authResult = karate.callSingle('classpath:karate/helpers/auth.feature', config);
  if (authResult && authResult.result) {
    config.adminToken = authResult.result.adminToken;
    config.adminId = authResult.result.adminId;
  }
  config.familiaToken = null;
  config.familiaId = null;

  return config;
}
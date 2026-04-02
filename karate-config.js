function fn() {
    var env = karate.env || 'dev';
    var config = {
        env: env,
        baseUrl: 'https://jsonplaceholder.typicode.com',
        timeout: 30000
    };

    if (env === 'dev') {
        config.baseUrl = 'https://jsonplaceholder.typicode.com';
    } else if (env === 'staging') {
        config.baseUrl = 'https://staging-api.example.com';
    } else if (env === 'prod') {
        config.baseUrl = 'https://api.example.com';
    }

    karate.configure('connectTimeout', 5000);
    karate.configure('readTimeout', 10000);
    karate.configure('ssl', true);

    karate.log('Environment:', env);
    karate.log('Base URL:', config.baseUrl);

    return config;
}

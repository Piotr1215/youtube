# [Server Configuration]

## [Database Settings]
host = localhost
port = 5432
name = myapp_prod
pool_size = 10

## [Cache Settings]
driver = redis
ttl = 3600
prefix = app_cache

## [Logging]
level = info
format = json
output = stdout

## [API Settings]
rate_limit = 100
timeout = 30
retry_count = 3
base_url = /api/v1

## [Security]
cors_enabled = true
csrf_protection = true
session_timeout = 1800

## [Feature Flags]
dark_mode = true
beta_features = false
analytics = true

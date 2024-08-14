Authentik Docker Compose installation

Step 1:  wget https://goauthentik.io/docker-compose.yml
Step 2:  echo "PG_PASS=$(openssl rand -base64 36 | tr -d '\n')" >> .env
         echo "AUTHENTIK_SECRET_KEY=$(openssl rand -base64 60 | tr -d '\n')" >> .env
Step 3:  echo "AUTHENTIK_ERROR_REPORTING__ENABLED=true" >> .env
Step 4:  Add email settings in the .env file.
                # SMTP Host Emails are sent to
                AUTHENTIK_EMAIL__HOST=mail.mcfetridge.us
                AUTHENTIK_EMAIL__PORT=587
                # Optionally authenticate (don't add quotation marks to your password)
                AUTHENTIK_EMAIL__USERNAME=auth@mcfetridge.us
                AUTHENTIK_EMAIL__PASSWORD=2bXruBXL5s2mf7RDeezq
                # Use StartTLS
                AUTHENTIK_EMAIL__USE_TLS=true
                # Use SSL
                AUTHENTIK_EMAIL__USE_SSL=false
                AUTHENTIK_EMAIL__TIMEOUT=10
                # Email address authentik will send from, should have a correct @domain
                AUTHENTIK_EMAIL__FROM=auth@mcfetridge.us
                COMPOSE_PORT_HTTP=8941
                COMPOSE_PORT_HTTPS=4443
Step 5: run docker compose pull
        docker compose up -d
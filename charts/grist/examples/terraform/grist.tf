resource "helm_release" "grist" {
  chart     = "../../helm_chart"
  name      = "grist"
  namespace = "grist"
  values = [
    <<-EOT
    image:
      tag: 1.1.9
    commonEnvVars: &commonEnvVars
      APP_HOME_URL: https://grist.minikube.local
      GRIST_ORG_IN_PATH: "true"
      GRIST_OIDC_SP_HOST: https://grist.minikube.local/
      GRIST_OIDC_IDP_ISSUER: http://keycloak.grist.svc.cluster.local/realms/grist
      GRIST_OIDC_IDP_SCOPES: openid email organizations
      GRIST_OIDC_IDP_CLIENT_ID: grist
      GRIST_OIDC_IDP_CLIENT_SECRET: yT00LmUDppwn3s4cFCNPV3Qg95pU14ZQ
      GRIST_DEFAULT_EMAIL: "admin@example.org"
      GRIST_SANDBOX_FLAVOR: gvisor
      GRIST_HIDE_UI_ELEMENTS: billing
      APP_STATIC_INCLUDE_CUSTOM_CSS: true
      GRIST_DEFAULT_LOCALE: fr
      GRIST_HELP_CENTER: https://outline.incubateur.anct.gouv.fr/doc/documentation-grist-YPWlYTHa8j
      REDIS_URL: redis://default:grist@redis-master
      GRIST_ANON_PLAYGROUND: false
      PERMITTED_CUSTOM_WIDGETS: "calendar"
      TYPEORM_TYPE: postgres
      TYPEORM_DATABASE: grist
      TYPEORM_HOST: postgresql
      TYPEORM_USERNAME: grist
      TYPEORM_PASSWORD: grist
      GRIST_SINGLE_PORT: 0
      GRIST_ALLOWED_HOSTS: grist.minikube.local

    docWorker:
      replicas: 1
      envVars:
        <<: *commonEnvVars

        GRIST_SERVERS: docs
        GRIST_DOCS_MINIO_BUCKET: grist
        GRIST_DOCS_MINIO_ENDPOINT: minio
        GRIST_DOCS_MINIO_PORT: 9000
        GRIST_DOCS_MINIO_USE_SSL: 0
        GRIST_DOCS_MINIO_BUCKET_REGION: local
        GRIST_DOCS_MINIO_ACCESS_KEY: gristgristgrist
        GRIST_DOCS_MINIO_SECRET_KEY: gristgristgrist

    homeWorker:
      replicas: 1
      envVars:
        <<: *commonEnvVars

        GRIST_SERVERS: home,static

    loadBalancer:
      replicas: 1

    ingress:
      enabled: true
      host: grist.minikube.local
    EOT
  ]
}

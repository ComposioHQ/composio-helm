{{/* Common PostgreSQL ENV variables and helpers used by Composio */}}

{{/* ENV used by composio deployments for connecting to postgresql */}}
{{- define "snippet.postgresql-env" }}
- name: DATABASE_URL
  value: {{ include "composio.postgresql.url" . }}
{{- end }}

{{/* ENV used by migrate job for connecting to postgresql */}}
{{- define "snippet.postgresql-migrate-env" }}
- name: DATABASE_URL
  value: {{ include "composio.postgresql.url" . }}
{{- end }}

{{/*
Create a default fully qualified postgresql app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "composio.postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name .Values.postgresql.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "composio.fullname" .) "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres secret
*/}}
{{- define "composio.postgresql.secretName" -}}
{{- if and .Values.postgresql.enabled .Values.postgresql.existingSecret }}
{{- .Values.postgresql.existingSecret | quote -}}
{{- else if and (not .Values.postgresql.enabled) .Values.externalPostgresql.existingSecret }}
{{- .Values.externalPostgresql.existingSecret | quote -}}
{{- else -}}
{{- if .Values.postgresql.enabled -}}
{{- include "composio.postgresql.fullname" . -}}
{{- else -}}
{{- printf "%s-external" (include "composio.fullname" .) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres secret password key
*/}}
{{- define "composio.postgresql.secretPasswordKey" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.existingSecretPasswordKey }}
{{- .Values.externalPostgresql.existingSecretPasswordKey | quote -}}
{{- else -}}
"postgresql-password"
{{- end -}}
{{- end -}}

{{/*
Set postgres host
*/}}
{{- define "composio.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- include "composio.postgresql.fullname" . -}}
{{- else -}}
{{- required "externalPostgresql.postgresqlHost is required if not postgresql.enabled" .Values.externalPostgresql.postgresqlHost | quote }}
{{- end -}}
{{- end -}}

{{/*
Set postgres port
*/}}
{{- define "composio.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
5432
{{- else -}}
{{- .Values.externalPostgresql.postgresqlPort -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres username
*/}}
{{- define "composio.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
"postgres"
{{- else -}}
{{- .Values.externalPostgresql.postgresqlUsername | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres database
*/}}
{{- define "composio.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.database | quote -}}
{{- else -}}
{{- .Values.externalPostgresql.postgresqlDatabase | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set if postgres secret should be created
*/}}
{{- define "composio.postgresql.createSecret" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.postgresqlPassword -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Define the PostgreSQL URL
*/}}
{{- define "composio.postgresql.url" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "postgresql://%s:%s@%s:%s/%s" (include "composio.postgresql.username" . | trimAll "\"") .Values.postgresql.auth.password (include "composio.postgresql.host" . | trimAll "\"") (include "composio.postgresql.port" . ) (include "composio.postgresql.database" .  | trimAll "\"") -}}
{{- else -}}
{{- printf "postgresql://%s:%s@%s:%s/%s" (include "composio.postgresql.username" . | trimAll "\"") .Values.externalPostgresql.postgresqlPassword (include "composio.postgresql.host" . | trimAll "\"") (include "composio.postgresql.port" . ) (include "composio.postgresql.database" .  | trimAll "\"") -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis fullname
*/}}
{{- define "composio.redis.fullname" -}}
{{- if .Values.redis.fullnameOverride -}}
{{- .Values.redis.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.redis.nameOverride -}}
{{- printf "%s-%s" .Release.Name .Values.redis.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "composio.fullname" .) "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis host
*/}}
{{- define "composio.redis.host" -}}
{{- if .Values.redis.enabled }}
    {{- printf "%s-master" (include "composio.redis.fullname" .) -}}
{{- else -}}
    {{- printf "%s" .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Session Recording Redis host
*/}}
{{- define "composio.sessionRecordingRedis.host" -}}
{{- if .Values.externalSessionRecordingRedis.host }}
    {{- printf "%s" .Values.externalSessionRecordingRedis.host -}}
{{- else -}}
    {{ include "composio.redis.host" . }}
{{- end -}}
{{- end -}}

{{/*
Return the Redis port
*/}}
{{- define "composio.redis.port" -}}
{{- if .Values.redis.enabled }}
    {{- printf "6379" | quote -}}
{{- else -}}
    {{- .Values.externalRedis.port | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return the Session Recording Redis port
*/}}
{{- define "composio.sessionRecordingRedis.port" -}}
{{- if .Values.externalSessionRecordingRedis.port }}
    {{- .Values.externalSessionRecordingRedis.port | quote -}}
{{- else -}}
    {{ include "composio.redis.port" . }}
{{- end -}}
{{- end -}}

{{/*
Return the Redis URL
*/}}
{{- define "composio.redis.url" -}}
{{- printf "redis://%s:%s" (include "composio.redis.host" .) (include "composio.redis.port" . | replace "\"" "") -}}
{{- end -}}

{{/*
Return true if a secret object for Redis should be created
*/}}
{{- define "composio.redis.createSecret" -}}
{{- if and (not .Values.redis.enabled) (not .Values.externalRedis.existingSecret) .Values.externalRedis.password }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret name
*/}}
{{- define "composio.redis.secretName" -}}
{{- if .Values.redis.enabled }}
    {{- if .Values.redis.auth.existingSecret }}
        {{- printf "%s" .Values.redis.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "composio.redis.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalRedis.existingSecret }}
    {{- printf "%s" .Values.externalRedis.existingSecret -}}
{{- else -}}
    {{- printf "%s-external" (include "composio.redis.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret key
*/}}
{{- define "composio.redis.secretPasswordKey" -}}
{{- if and .Values.redis.enabled .Values.redis.auth.existingSecret }}
    {{- required "You need to provide existingSecretPasswordKey when an existingSecret is specified in redis" .Values.redis.auth.existingSecretPasswordKey | printf "%s" }}
{{- else if and (not .Values.redis.enabled) .Values.externalRedis.existingSecret }}
    {{- required "You need to provide existingSecretPasswordKey when an existingSecret is specified in redis" .Values.externalRedis.existingSecretPasswordKey | printf "%s" }}
{{- else -}}
    {{- printf "redis-password" -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis uses password authentication or not
*/}}
{{- define "composio.redis.auth.enabled" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Set site url. Either use siteUrl if set, or if ingress is enabled, use the
ingress hostname.

To enable ingress to the app with any Host header being set, e.g. as when a
reverse proxy is in front of the app listening on a different DNS name.
*/}}
{{- define "composio.site.url" -}}
    {{- if .Values.siteUrl -}}
        {{- .Values.siteUrl -}}
    {{- else if (and .Values.ingress.hostname .Values.ingress.enabled) -}}
        "https://{{ .Values.ingress.hostname }}"
    {{- else -}}
        "http://127.0.0.1:8000"
    {{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "composio.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "composio.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "composio.helmOperation" -}}
{{- if .Release.IsUpgrade -}}
    upgrade
{{- else -}}
    install
{{- end -}}
{{- end -}}

{{- define "ingress.type" -}}
{{- if ne (.Values.ingress.type | toString) "<nil>" -}}
  {{ .Values.ingress.type }}
{{- else if .Values.ingress.nginx.enabled -}}
  nginx
{{- else if (eq (.Values.cloud | toString) "gcp") -}}
  clb
{{- end -}}
{{- end -}}

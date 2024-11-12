{{/* Loki related templates */}}

{{- define "composio.loki.enabled" -}}
{{- if .Values.loki.enabled -}}
true
{{- end -}}
{{- end -}}

{{- define "composio.loki.url" -}}
{{- .Values.loki.url -}}
{{- end -}} 
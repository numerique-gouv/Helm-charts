{{- define "custom.labels" -}}
app: {{ .name }}
version: {{ .image.tag }}
{{- end -}}

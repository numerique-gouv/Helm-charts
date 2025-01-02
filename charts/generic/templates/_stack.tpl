{{- define "custom.stack" -}}
{{- if .Values.components }}
{{- range $key, $component := .Values.components }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $component.name }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
{{ include "custom.labels" $component | indent 4 }}
spec:
  replicas: {{ $component.replicas }}
  {{- if hasKey $component.strategy "type" }}
  strategy:
    type: {{ $component.strategy.type }}
  {{ end -}}
  selector:
    matchLabels:
{{ include "custom.labels" $component | indent 6 }}
  template:
    metadata:
      labels:
{{ include "custom.labels" $component | indent 8 }}
    spec:
{{- if $component.securityContext }}
      securityContext:
{{ toYaml $component.securityContext | indent 8 }}
{{- end }}
      {{ if $component.volumes -}}
      volumes:
{{ toYaml $component.volumes | indent 8 }}
      {{ end -}}
{{- if $component.initContainers }}
      initContainers:
{{ toYaml $component.initContainers | indent 8 }}
{{- end }}
      containers:
        - name: {{ $component.name }}
          {{- if $component.env }}
          env:
{{ toYaml $component.env | indent 12 }}
          {{ end -}}
          {{- if $component.args -}}
          args:
{{ toYaml $component.args | indent 12 }}
          {{- end }}
          {{ if $component.command -}}
          command:
{{ toYaml $component.command | indent 12 }}
          {{- end }}
          {{ if $component.resources -}}
          resources:
{{ toYaml $component.resources | indent 12 }}
          {{- end -}}
          {{- if $component.volumeMounts }}
          volumeMounts:
{{ toYaml $component.volumeMounts | indent 12 }}
          {{ end -}}
          imagePullPolicy: {{ $component.image.pullPolicy }}
          image: {{ $component.image.repository }}:{{ $component.image.tag }}
          {{- with $component.ports }}
          ports:
            {{- range $key, $port := $component.ports }}
            - containerPort: {{ $port.port }}
            {{- end }}
          {{- end }}
{{- if $component.sidecars }}
{{ toYaml $component.sidecars | indent 8 }}
{{ end }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $component.name }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
{{ include "custom.labels" $component | indent 4 }}
spec:
  selector:
{{ include "custom.labels" $component | indent 4 }}
  ports:
    {{- range $key, $port := $component.ports }}
    - protocol: TCP
      port: {{ $port.port }}
      targetPort: {{ $port.port }}
    {{ end }}
---
{{- range $key, $port := $component.ports }}
{{ if $port.ingress }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  {{- if $port.ingress.annotations }}
  annotations:
{{ toYaml $port.ingress.annotations | indent 4 }}
  {{- end }}
  name: {{ $component.name }}-{{ $port.port }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
{{ include "custom.labels" $component | indent 4 }}
spec:
  ingressClassName: {{ $port.ingress.ingressClass | default "nginx" }}
  {{- range $key2, $port2 := $component.ports }}
  rules:
  {{- if $port2.ingress }}
  - host: {{ $port2.ingress.host }}
    http:
      paths:
        - pathType: Prefix
          path: {{ $port2.ingress.path | default "/" }}
          backend:
            service:
              name: {{ $component.name }}
              port:
                number: {{ $port2.port }}
  {{- end -}}
  {{- end -}}
  {{- range $key2, $port2 := $component.ports }}
  tls:
  {{- if $port2.ingress.tls }}
  - hosts: 
      - {{ $port2.ingress.host }}
    secretName: {{ $component.name }}-{{ $port2.port }}
  {{ end }}
  {{ end }}
{{ end }}
{{ end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.imagePullSecrets.createSecret.registry (printf "%s:%s" .Values.imagePullSecrets.createSecret.username .Values.imagePullSecrets.createSecret.password | b64enc) | b64enc }}
{{- end }}

{{- define "app.Secretname" -}}
{{- with .Values.imagePullSecrets.name }}
{{- printf "%s" . -}}
{{ else }}
{{- printf "image-secret-%s" (include "app.fullname" .) -}}
{{- end }}  
{{- end -}}

{{- define "secretEnvName"}}
{{- $fullName := include "app.fullname" . -}}
{{- range $key, $val := .Values.secretEnv }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: secret-env-{{ $fullName }}
      key: {{ $key }}
{{- end}}
{{- end}}

{{- define "extraEnvName"}}
{{- range $key, $val := .Values.extraEnv }}
- name: {{ $key }}
  valueFrom:
    fieldRef:
      fieldPath: {{ $val }}
{{- end}}
{{- end}}

{{- define "app.secretEnvName"}}
{{- range $key, $val := .Values.secretEnv }}
   {{ $key }}: {{ toString $val | b64enc }}{{- end -}}
{{- end}}

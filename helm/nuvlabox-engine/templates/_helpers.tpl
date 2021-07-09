{{/*
Expand the name of the chart.
*/}}
{{- define "nuvlabox-engine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define the namespace based on the NUVLABOX_UUID
*/}}
{{- define "nuvlabox-engine.namespace" -}}
{{- if .Values.NUVLABOX_UUID }}
{{- .Values.NUVLABOX_UUID | replace "/" "-" }}
{{- else }}
nuvlabox
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nuvlabox-engine.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nuvlabox-engine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nuvlabox-engine.labels" -}}
helm.sh/chart: {{ include "nuvlabox-engine.chart" . }}
nuvlabox.component: "True"
nuvlabox.deployment: "production"
{{ include "nuvlabox-engine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common peripheral manager labels
*/}}
{{- define "nuvlabox-engine.peripheral-manager.labels" -}}
nuvlabox.peripheral.component: "True"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nuvlabox-engine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nuvlabox-engine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nuvlabox-engine.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nuvlabox-engine.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the namespace to use for namespaced resources.
*/}}
{{- define "girus.namespace" -}}
{{- .Values.namespaceOverride | default .Release.Namespace -}}
{{- end -}}

{{/*
Add generic labels to resources
*/}}
{{- define "girus.labels" -}}
app.kubernetes.io/part-of: {{ .Values.label.partOf }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

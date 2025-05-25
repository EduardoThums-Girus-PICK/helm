{{/*
Return the namespace to use for namespaced resources.
*/}}
{{- define "girus.namespace" -}}
{{- .Values.namespaceOverride | default .Release.Namespace -}}
{{- end -}}

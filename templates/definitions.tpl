{{- define "fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}

{{- define "masternodes" -}}
{{- $replicas := .Values.master.replicas | int }}
{{- $name := printf "%s-master" (include "fullname" .) }}
{{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $name }}-{{ $i }},
{{- end -}}
{{- end -}}






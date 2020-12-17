{{- define "type_def" -}}
type {{ .Names.Camel }} struct {
{{- range $attrName, $attr := .Attrs }}
	{{- if $attr.Shape }}
	{{ $attr.Shape.Documentation }}
	{{- end }}
	{{- if $attr.ReferencedType }}
	{{ $attr.Names.Camel }} {{ $attr.GoType }} `json:"{{ $attr.Names.CamelLower }},omitempty"`

  // {{ $attr.Names.Camel }}Ref is a reference to an {{ $attr.ReferencedType }} used
  // to set the {{ $attr.Names.Camel }} field.
  // +optional
  {{ $attr.Names.Camel }}Ref {{if $attr.IsSlice -}}[]xpv1.Reference{{- else -}}*xpv1.Reference{{- end -}} `json:"{{ $attr.Names.CamelLower }}Ref,omitempty"`

  // {{ $attr.Names.Camel }}Selector selects references to {{ $attr.ReferencedType }}
  // used to set the {{ $attr.Names.Camel }}.
  // +optional
  {{ $attr.Names.Camel }}Selector *xpv1.Selector `json:"{{ $attr.Names.CamelLower }}Selector,omitempty"`
	{{ else }}
	{{ $attr.Names.Camel }} {{ $attr.GoType }} `json:"{{ $attr.Names.CamelLower }},omitempty"`
	{{- end }}
{{- end }}
}
{{- end -}}

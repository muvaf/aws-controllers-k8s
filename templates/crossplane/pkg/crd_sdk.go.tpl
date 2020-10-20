{{ template "boilerplate" }}

package {{ .CRD.Names.Snake }}

import ({{- if .CRD.TypeImports }}
{{- range $packagePath, $alias := .CRD.TypeImports }}
	{{ if $alias }}{{ $alias }} {{ end }}"{{ $packagePath }}"
{{ end }}
{{- end }}
	svcsdk "github.com/aws/aws-sdk-go/service/{{ .ServiceIDClean }}"
	"github.com/muvaf/test-generated-aws/apis/{{ .ServiceIDClean }}/{{ .APIVersion}}"
)

{{- if .CRD.Ops.ReadMany }}
func Generate{{ .CRD.Ops.ReadMany.InputRef.Shape.ShapeName }}(cr *{{ .APIVersion}}.{{ .CRD.Names.Camel }}) *svcsdk.{{ .CRD.Ops.ReadMany.InputRef.Shape.ShapeName }} {
	res := &svcsdk.{{ .CRD.Ops.ReadMany.InputRef.Shape.ShapeName }}{}
{{ GoCodeSetReadManyInput .CRD "cr" "res" 1 }}
	return res
}
{{ end }}

// GenerateCreateRepositoryInput returns a CreateRepositoryInput object.
func Generate{{ .CRD.Ops.Create.InputRef.Shape.ShapeName }}(cr *{{ .APIVersion}}.{{ .CRD.Names.Camel }}) *svcsdk.{{ .CRD.Ops.Create.InputRef.Shape.ShapeName }} {
	res := &svcsdk.{{ .CRD.Ops.Create.InputRef.Shape.ShapeName }}{}
{{ GoCodeSetCreateInput .CRD "cr" "res" 1 }}
	return res
}

{{ if .CRD.Ops.Delete -}}
// newDeleteRequestPayload returns an SDK-specific struct for the HTTP request
// payload of the Delete API call for the resource
func Generate{{ .CRD.Ops.Delete.InputRef.Shape.ShapeName }}(cr *{{ .APIVersion}}.{{ .CRD.Names.Camel }}) *svcsdk.{{ .CRD.Ops.Delete.InputRef.Shape.ShapeName }} {
	res := &svcsdk.{{ .CRD.Ops.Delete.InputRef.Shape.ShapeName }}{}
{{ GoCodeSetDeleteInput .CRD "cr" "res" 1 }}
	return res
}
{{- end -}}

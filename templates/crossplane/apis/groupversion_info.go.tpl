{{ template "boilerplate" }}

package {{ .APIVersion }}

import (
    "k8s.io/apimachinery/pkg/runtime/schema"
    "sigs.k8s.io/controller-runtime/pkg/scheme"
)

var (
    // SchemeGroupVersion is the API Group Version used to register the objects
    SchemeGroupVersion = schema.GroupVersion{Group: "{{ .APIGroup }}", Version: "{{ .APIVersion }}"}

    // SchemeBuilder is used to add go types to the GroupVersionKind scheme
    SchemeBuilder = &scheme.Builder{GroupVersion: SchemeGroupVersion}

    // AddToScheme adds the types in this group-version to the given scheme.
    AddToScheme = SchemeBuilder.AddToScheme
)

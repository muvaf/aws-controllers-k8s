module github.com/aws/aws-controllers-k8s

go 1.14

require (
	github.com/aws/aws-sdk-go v1.34.18
	github.com/crossplane/crossplane-runtime v0.10.0
	github.com/crossplane/provider-aws v0.12.0
	github.com/dlclark/regexp2 v1.2.0
	// pin to v0.1.1 due to release problem with v0.1.2
	github.com/gertd/go-pluralize v0.1.1
	github.com/ghodss/yaml v1.0.0
	github.com/go-logr/logr v0.1.0
	github.com/google/go-cmp v0.5.0
	github.com/iancoleman/strcase v0.0.0-20191112232945-16388991a334
	github.com/mitchellh/go-homedir v1.1.0
	github.com/pkg/errors v0.9.1
	github.com/spf13/cobra v1.0.0
	github.com/spf13/pflag v1.0.5
	github.com/stretchr/testify v1.5.1
	go.uber.org/zap v1.10.0
	k8s.io/api v0.18.8
	k8s.io/apimachinery v0.18.8
	k8s.io/client-go v0.18.8
	sigs.k8s.io/controller-runtime v0.6.2
)

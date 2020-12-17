{{ template "boilerplate" }}

// Code generated by ack-generate. DO NOT EDIT.

package {{ .CRD.Names.Lower }}

import (
	"context"

	"github.com/pkg/errors"
	"github.com/google/go-cmp/cmp"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	svcsdkapi "github.com/aws/aws-sdk-go/service/{{ .ServiceIDClean }}/{{ .ServiceIDClean }}iface"
	svcapi "github.com/aws/aws-sdk-go/service/{{ .ServiceIDClean }}"
	"github.com/aws/aws-sdk-go/aws/session"

	"github.com/crossplane/crossplane-runtime/pkg/meta"
	"github.com/crossplane/crossplane-runtime/pkg/event"
	"github.com/crossplane/crossplane-runtime/pkg/logging"
	"github.com/crossplane/crossplane-runtime/pkg/reconciler/managed"
	cpresource "github.com/crossplane/crossplane-runtime/pkg/resource"
	xpv1 "github.com/crossplane/crossplane-runtime/apis/common/v1"

	svcapitypes "github.com/crossplane/provider-aws/apis/{{ .ServiceIDClean }}/{{ .APIVersion}}"
	awsclient "github.com/crossplane/provider-aws/pkg/clients"
)

const (
	errUnexpectedObject = "managed resource is not an {{ .CRD.Names.Camel }} resource"

	errCreateSession = "cannot create a new session"
	errCreate = "cannot create {{ .CRD.Names.Camel }} in AWS"
	errDescribe = "failed to describe {{ .CRD.Names.Camel }}"
	errDelete = "failed to delete {{ .CRD.Names.Camel }}"
)

type connector struct {
	kube client.Client
}

func (c *connector) Connect(ctx context.Context, mg cpresource.Managed) (managed.ExternalClient, error) {
	cr, ok := mg.(*svcapitypes.{{ .CRD.Names.Camel }})
	if !ok {
		return nil, errors.New(errUnexpectedObject)
	}
	sess, err := awsclient.GetConfigV1(ctx, c.kube, mg, cr.Spec.ForProvider.Region)
	if err != nil {
		return nil, err
	}
  return &external{client: svcapi.New(sess), kube: c.kube}, errors.Wrap(err, errCreateSession)
}

type external struct {
	kube   client.Client
	client svcsdkapi.{{ .SDKAPIInterfaceTypeName }}API
}
{{ if or .CRD.Ops.ReadOne .CRD.Ops.GetAttributes .CRD.Ops.ReadMany }}
func (e *external) Observe(ctx context.Context, mg cpresource.Managed) (managed.ExternalObservation, error) {
	cr, ok := mg.(*svcapitypes.{{ .CRD.Names.Camel }})
	if !ok {
		return managed.ExternalObservation{}, errors.New(errUnexpectedObject)
	}
	if err := e.preObserve(ctx, cr); err != nil {
		return managed.ExternalObservation{}, errors.Wrap(err, "pre-observe failed")
	}
	if meta.GetExternalName(cr) == "" {
		return managed.ExternalObservation{
			ResourceExists: false,
		}, nil
	}

{{- if .CRD.Ops.ReadOne }}
	input := Generate{{ .CRD.Ops.ReadOne.InputRef.Shape.ShapeName }}(cr)
	resp, err := e.client.{{ .CRD.Ops.ReadOne.Name }}WithContext(ctx, input)
  if err != nil {
    return managed.ExternalObservation{ResourceExists: false}, errors.Wrap(cpresource.Ignore(IsNotFound, err), errDescribe)
  }
{{- else if .CRD.Ops.GetAttributes }}
	input := Generate{{ .CRD.Ops.GetAttributes.InputRef.Shape.ShapeName }}(cr)
	resp, err := e.client.{{ .CRD.Ops.GetAttributes.Name }}WithContext(ctx, input)
  if err != nil {
    return managed.ExternalObservation{ResourceExists: false}, errors.Wrap(cpresource.Ignore(IsNotFound, err), errDescribe)
  }
{{- else if .CRD.Ops.ReadMany }}
	input := Generate{{ .CRD.Ops.ReadMany.InputRef.Shape.ShapeName }}(cr)

	resp, err := e.client.{{ .CRD.Ops.ReadMany.Name }}WithContext(ctx, input)
	if err != nil {
		return managed.ExternalObservation{ResourceExists: false}, errors.Wrap(cpresource.Ignore(IsNotFound, err), errDescribe)
	}
	resp = e.filterList(cr, resp)
	if len(resp.Items) == 0 {
	  return managed.ExternalObservation{ResourceExists: false}, nil
	}
{{- end }}
	currentSpec := cr.Spec.ForProvider.DeepCopy()
	lateInitialize(&cr.Spec.ForProvider, resp)
	Generate{{ .CRD.Names.Camel }}(resp).Status.AtProvider.DeepCopyInto(&cr.Status.AtProvider)
	return e.postObserve(ctx, cr, resp, managed.ExternalObservation{
		ResourceExists:   true,
		ResourceUpToDate: isUpToDate(cr, resp),
		ResourceLateInitialized: !cmp.Equal(&cr.Spec.ForProvider, currentSpec),
	}, nil)
}
{{ else }}
// {{ .CRD.Names.Camel }} API does not natively implement a Get call. It should
// be handled with custom code.
{{ end }}
func (e *external) Create(ctx context.Context, mg cpresource.Managed) (managed.ExternalCreation, error) {
	cr, ok := mg.(*svcapitypes.{{ .CRD.Names.Camel }})
	if !ok {
		return managed.ExternalCreation{}, errors.New(errUnexpectedObject)
	}
	cr.Status.SetConditions(xpv1.Creating())
	if err := e.preCreate(ctx, cr); err != nil {
		return managed.ExternalCreation{}, errors.Wrap(err, "pre-create failed")
	}
	input := Generate{{ .CRD.Ops.Create.InputRef.Shape.ShapeName }}(cr)
	resp, err := e.client.{{ .CRD.Ops.Create.Name }}WithContext(ctx, input)
	if err != nil {
		return managed.ExternalCreation{}, errors.Wrap(err, errCreate)
	}
{{ GoCodeSetCreateOutput .CRD "resp" "cr" 1 false }}
	return e.postCreate(ctx, cr, resp, managed.ExternalCreation{}, err)
}

func (e *external) Update(ctx context.Context, mg cpresource.Managed) (managed.ExternalUpdate, error) {
	cr, ok := mg.(*svcapitypes.{{ .CRD.Names.Camel }})
	if !ok {
		return managed.ExternalUpdate{}, errors.New(errUnexpectedObject)
	}
	if err := e.preUpdate(ctx, cr); err != nil {
		return managed.ExternalUpdate{}, errors.Wrap(err, "pre-update failed")
	}
	return e.postUpdate(ctx, cr, managed.ExternalUpdate{}, nil)
}

{{- if .CRD.Ops.Delete }}
func (e *external) Delete(ctx context.Context, mg cpresource.Managed) error {
	cr, ok := mg.(*svcapitypes.{{ .CRD.Names.Camel }})
	if !ok {
		return errors.New(errUnexpectedObject)
	}
	cr.Status.SetConditions(xpv1.Deleting())
	{{- if .CRD.Ops.Delete }}
  input := Generate{{ .CRD.Ops.Delete.InputRef.Shape.ShapeName }}(cr)
  _, err := e.client.{{ .CRD.Ops.Delete.Name }}WithContext(ctx, input)
	return errors.Wrap(cpresource.Ignore(IsNotFound, err), errDelete)
}
{{ end }}
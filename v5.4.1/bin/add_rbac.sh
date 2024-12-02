#!/bin/bash

## Add read permission to access the kubernetes API and OpenShift RBACs.
oc create clusterrole neuvector-binding-app --verb=get,list,watch,update --resource=nodes,pods,services,namespaces
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-app failed!" && exit 1

oc create clusterrole neuvector-binding-rbac --verb=get,list,watch --resource=rolebindings.rbac.authorization.k8s.io,roles.rbac.authorization.k8s.io,clusterrolebindings.rbac.authorization.k8s.io,clusterroles.rbac.authorization.k8s.io,imagestreams.image.openshift.io
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-rbac failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-app system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user neuvector-binding-app failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-rbac system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user neuvector-binding-rbac failed" && exit 1

oc create clusterrole neuvector-binding-admission --verb=get,list,watch,create,update,delete --resource=validatingwebhookconfigurations,mutatingwebhookconfigurations
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-admission failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-admission system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user neuvector-binding-admission failed" && exit 1

oc create clusterrole neuvector-binding-customresourcedefinition --verb=watch,create,get,update --resource=customresourcedefinitions
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-customresourcedefinition failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-customresourcedefinition system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user neuvector-binding-customresourcedefinition failed" && exit 1

oc create clusterrole neuvector-binding-nvsecurityrules --verb=get,list,delete --resource=nvsecurityrules,nvclustersecurityrules
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-nvsecurityrules failed" && exit 1

oc create clusterrole neuvector-binding-nvadmissioncontrolsecurityrules --verb=get,list,delete --resource=nvadmissioncontrolsecurityrules
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-nvadmissioncontrolsecurityrules failed" && exit 1

oc create clusterrole neuvector-binding-nvdlpsecurityrules --verb=get,list,delete --resource=nvdlpsecurityrules
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-nvdlpsecurityrules failed" && exit 1

oc create clusterrole neuvector-binding-nvwafsecurityrules --verb=get,list,delete --resource=nvwafsecurityrules
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-nvwafsecurityrules failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-nvsecurityrules system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc policy add-cluster-role-to-user neuvector-binding-nvsecurityrules failed" && exit 1

oc adm policy add-cluster-role-to-user view system:serviceaccount:neuvector:controller --rolebinding-name=neuvector-binding-view
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user view system:serviceaccount:neuvector:controller failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-nvwafsecurityrules system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user neuvector-binding-nvwafsecurityrules failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-nvadmissioncontrolsecurityrules system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user neuvector-binding-nvadmissioncontrolsecurityrules failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-nvdlpsecurityrules system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user neuvector-binding-nvdlpsecurityrules failed" && exit 1

oc create role neuvector-binding-scanner --verb=get,patch,update,watch --resource=deployments -n neuvector
[[ "$?" != "0" ]] && echo "oc create role neuvector-binding-scanner failed" && exit 1

oc adm policy add-role-to-user neuvector-binding-scanner system:serviceaccount:neuvector:updater system:serviceaccount:neuvector:controller -n neuvector --role-namespace neuvector
[[ "$?" != "0" ]] && echo "oc add-role-to-user neuvector-binding-scanner failed" && exit 1

oc create clusterrole neuvector-binding-co --verb=get,list --resource=clusteroperators
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-co failed" && exit 1

oc adm policy add-cluster-role-to-user neuvector-binding-co system:serviceaccount:neuvector:enforcer system:serviceaccount:neuvector:controller
[[ "$?" != "0" ]] && echo "oc add-cluster-role-to-user neuvector-binding-co failed" && exit 1

oc create role neuvector-binding-secret --verb=get,list,watch --resource=secrets -n neuvector
[[ "$?" != "0" ]] && echo "oc create role neuvector-binding-secret failed" && exit 1

oc adm policy add-role-to-user neuvector-binding-secret system:serviceaccount:neuvector:controller system:serviceaccount:neuvector:enforcer system:serviceaccount:neuvector:scanner system:serviceaccount:neuvector:registry-adapter -n neuvector --role-namespace neuvector
[[ "$?" != "0" ]] && echo "oc add-role-to-user neuvector-binding-secret failed" && exit 1

oc create clusterrole neuvector-binding-nvcomplianceprofiles --verb=get,list,delete --resource=nvcomplianceprofiles
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-nvcomplianceprofiles failed" && exit 1

oc create clusterrolebinding neuvector-binding-nvcomplianceprofiles --clusterrole=neuvector-binding-nvcomplianceprofiles --serviceaccount=neuvector:controller
[[ "$?" != "0" ]] && echo "oc create clusterrolebinding neuvector-binding-nvcomplianceprofiles failed" && exit 1

oc create clusterrole neuvector-binding-nvvulnerabilityprofiles --verb=get,list,delete --resource=nvvulnerabilityprofiles
[[ "$?" != "0" ]] && echo "oc create clusterrole neuvector-binding-nvvulnerabilityprofiles failed" && exit 1

oc create clusterrolebinding neuvector-binding-nvvulnerabilityprofiles --clusterrole=neuvector-binding-nvvulnerabilityprofiles --serviceaccount=neuvector:controller
[[ "$?" != "0" ]] && echo "oc create clusterrolebinding neuvector-binding-nvvulnerabilityprofiles failed" && exit 1

oc apply -f "${BASH_SOURCE[@]%/*}"/neuvector-roles-k8s.yaml
[[ "$?" != "0" ]] && echo "oc apply neuvector-roles-k8s.yaml failed" && exit 1

oc create role neuvector-binding-lease --verb=create,get,update --resource=leases -n neuvector
[[ "$?" != "0" ]] && echo "oc create role neuvector-binding-lease failed" && exit 1

oc adm policy add-role-to-user neuvector-binding-cert-upgrader system:serviceaccount:neuvector:cert-upgrader -n neuvector --role-namespace neuvector
[[ "$?" != "0" ]] && echo "oc add-role-to-user neuvector-binding-cert-upgrader failed" && exit 1

oc adm policy add-role-to-user neuvector-binding-job-creation system:serviceaccount:neuvector:cert-upgrader -n neuvector --role-namespace neuvector
[[ "$?" != "0" ]] && echo "oc add-role-to-user neuvector-binding-job-creation failed" && exit 1

oc adm policy add-role-to-user neuvector-binding-lease system:serviceaccount:neuvector:controller system:serviceaccount:neuvector:cert-upgrader -n neuvector --role-namespace neuvector
[[ "$?" != "0" ]] && echo "oc add-role-to-user neuvector-binding-lease failed" && exit 1

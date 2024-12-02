# Delete ClusterRoles
oc delete clusterrole neuvector-binding-app
oc delete clusterrole neuvector-binding-rbac
oc delete clusterrole neuvector-binding-admission
oc delete clusterrole neuvector-binding-customresourcedefinition
oc delete clusterrole neuvector-binding-nvsecurityrules
oc delete clusterrole neuvector-binding-nvadmissioncontrolsecurityrules
oc delete clusterrole neuvector-binding-nvdlpsecurityrules
oc delete clusterrole neuvector-binding-nvwafsecurityrules
oc delete clusterrole neuvector-binding-co
oc delete clusterrole neuvector-binding-nvcomplianceprofiles
oc delete clusterrole neuvector-binding-nvvulnerabilityprofiles

# Delete ClusterRoleBindings
oc delete clusterrolebinding neuvector-binding-nvcomplianceprofiles
oc delete clusterrolebinding neuvector-binding-nvvulnerabilityprofiles
oc delete clusterrolebinding neuvector-binding-view

# Delete Roles
oc delete role neuvector-binding-scanner -n neuvector
oc delete role neuvector-binding-secret -n neuvector
oc delete -f "${BASH_SOURCE[@]%/*}"/neuvector-roles-k8s.yaml
oc delete role neuvector-binding-lease -n neuvector

# Remove ClusterRole Assignments from Users
oc adm policy remove-cluster-role-from-user neuvector-binding-app system:serviceaccount:neuvector:controller
oc adm policy remove-cluster-role-from-user neuvector-binding-rbac system:serviceaccount:neuvector:controller
oc adm policy remove-cluster-role-from-user neuvector-binding-admission system:serviceaccount:neuvector:controller
oc adm policy remove-cluster-role-from-user neuvector-binding-customresourcedefinition system:serviceaccount:neuvector:controller
oc adm policy remove-cluster-role-from-user neuvector-binding-nvsecurityrules system:serviceaccount:neuvector:controller
oc adm policy remove-cluster-role-from-user neuvector-binding-nvwafsecurityrules system:serviceaccount:neuvector:controller
oc adm policy remove-cluster-role-from-user neuvector-binding-nvadmissioncontrolsecurityrules system:serviceaccount:neuvector:controller
oc adm policy remove-cluster-role-from-user neuvector-binding-nvdlpsecurityrules system:serviceaccount:neuvector:controller
oc adm policy remove-cluster-role-from-user neuvector-binding-co system:serviceaccount:neuvector:enforcer
oc adm policy remove-cluster-role-from-user neuvector-binding-co system:serviceaccount:neuvector:controller
oc adm policy remove-role-from-user neuvector-binding-cert-upgrader system:serviceaccount:neuvector:cert-upgrader --role-namespace=neuvector -n neuvector
oc adm policy remove-role-from-user neuvector-binding-job-creation system:serviceaccount:neuvector:cert-upgrader --role-namespace=neuvector -n neuvector
oc adm policy remove-role-from-user neuvector-binding-lease system:serviceaccount:neuvector:controller system:serviceaccount:neuvector:cert-upgrader --role-namespace=neuvector -n neuvector

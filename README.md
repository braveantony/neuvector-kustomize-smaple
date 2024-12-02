# 透過 Kustomize 客製化建立不同環境的 Neuvector

優點 : 藉由 Kustomize 的特性，將每個環境不同的設定，永久儲存成特定的 YAML，方便過一段時間後，回來看更改了哪些設定，或是順利的工作交接。

注意 : 這個範例只在 OpenShift 4.12 ~ 4.16 測試過 Neuvector v5.4.1 版，不適用舊版的 Neuvector。

## 快速開始建立 Neuvector

### Step0: 下載 Repo

```
git clone https://github.com/braveantony/neuvector-kustomize-smaple.git
```

### Step1: 使用 normal user 登入

Prerequest: 需先 `ssh` 連到可以執行 `oc` 命令的管理主機 

```
oc login -u <user_name>
```

### Step2: 建立 Neuvector Namespace

```
oc new-project neuvector
```

### Step3: 使用 admin 帳號登入

```
oc login -u system:admin
```

### Step4: 建立 Service Accounts 並賦予 Privileged SCC

```
oc create sa controller -n neuvector
oc create sa enforcer -n neuvector
oc create sa basic -n neuvector
oc create sa updater -n neuvector
oc create sa scanner -n neuvector
oc create sa registry-adapter -n neuvector
oc create sa cert-upgrader -n neuvector
oc -n neuvector adm policy add-scc-to-user privileged -z enforcer

cat << 'EOF' | oc apply -f -
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: false
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups: []
kind: SecurityContextConstraints
metadata:
  name: neuvector-scc-controller
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- azureFile
- projected
- secret
EOF

oc -n neuvector adm policy add-scc-to-user neuvector-scc-controller -z controller
```

### Step5: 為 NeuVector 安全規則創建自定義資源 (CRD)。

```
export CONFIG_DIR="${PWD}"/neuvector-kustomize-smaple/v5.4.1/ && \
oc apply -f ${CONFIG_DIR}/config/crd/
```

### Step6: 添加讀取權限，以訪問 kubernetes API 和 OpenShift RBAC。

```
${CONFIG_DIR}/bin/add_rbac.sh
```

### Step7:檢查 neuvector/controller、neuvector/enforcer 和 neuvector/updater 這三個 Service Accounts是否已成功新增

```
oc get ClusterRoleBinding neuvector-binding-app neuvector-binding-rbac neuvector-binding-admission neuvector-binding-customresourcedefinition neuvector-binding-nvsecurityrules neuvector-binding-view neuvector-binding-nvwafsecurityrules neuvector-binding-nvadmissioncontrolsecurityrules neuvector-binding-nvdlpsecurityrules neuvector-binding-co -o wide
```

螢幕輸出:

```
NAME                                                ROLE                                                            AGE     USERS   GROUPS   SERVICEACCOUNTS
neuvector-binding-app                               ClusterRole/neuvector-binding-app                               3m11s                    neuvector/controller
neuvector-binding-rbac                              ClusterRole/neuvector-binding-rbac                              3m11s                    neuvector/controller
neuvector-binding-admission                         ClusterRole/neuvector-binding-admission                         3m11s                    neuvector/controller
neuvector-binding-customresourcedefinition          ClusterRole/neuvector-binding-customresourcedefinition          3m11s                    neuvector/controller
neuvector-binding-nvsecurityrules                   ClusterRole/neuvector-binding-nvsecurityrules                   3m10s                    neuvector/controller
neuvector-binding-view                              ClusterRole/view                                                3m10s                    neuvector/controller
neuvector-binding-nvwafsecurityrules                ClusterRole/neuvector-binding-nvwafsecurityrules                3m10s                    neuvector/controller
neuvector-binding-nvadmissioncontrolsecurityrules   ClusterRole/neuvector-binding-nvadmissioncontrolsecurityrules   3m10s                    neuvector/controller
neuvector-binding-nvdlpsecurityrules                ClusterRole/neuvector-binding-nvdlpsecurityrules                3m10s                    neuvector/controller
neuvector-binding-co                                ClusterRole/neuvector-binding-co                                3m10s                    neuvector/enforcer, neuvector/controller
```

### Step8: 設定資料永存

```
# 1. 先定義 StorageClass 的名稱
SC="<storageclass name>"

# 2. 置換 PVC 檔案中定義的 StorageClass 名稱
sed -i "s|managed-nfs-storage|${SC}|g" $CONFIG_DIR/config/overlays/test/neuvector-pvc.yaml

# 3. 部屬 PVC
oc apply -f $CONFIG_DIR/config/overlays/test/neuvector-pvc.yaml

# 4. 檢查
oc get -f $CONFIG_DIR/config/overlays/test/neuvector-pvc.yaml
```

> 如果 pvc 名稱有變動，請執行以下命令修改 PVC 的名稱

```
nano $CONFIG_DIR/config/overlays/test/enable-persistent-data.yaml
```

要修改的部分如下 : 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: neuvector-controller-pod
  namespace: neuvector
spec:
  template:
    spec:
      containers:
      - name: neuvector-controller-pod
        env:
        - name: CTRL_PERSIST_CONFIG
          value: "1"
        volumeMounts:
        - mountPath: /var/neuvector
          name: nv-share
          readOnly: false
      volumes:
      - name: nv-share
        persistentVolumeClaim:
          claimName: neuvector-data    ## 修改這
```

### Step9: 修改 Sample Yaml 檔

修改 Image Registry 的位置，欄位 `newName` 

```
nano "${CONFIG_DIR}"/config/overlays/test/kustomization.yaml
```

修改 controller、manager 和 scanner 的 replicas 數量，欄位 `count`

```
nano "${CONFIG_DIR}"/config/overlays/test/kustomization.yaml
```

修改 CRI-O 的位置，如果 CRI-O Socket 的位置是 `/var/run/crio/crio.sock`，則不需修改

```
nano "${CONFIG_DIR}"/config/overlays/test/crio-patch.yaml
```

新增多餘的 Taints (如果要部署的節點沒有任何 Taints 則可跳過本步驟)

```
[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master"}]
[{"effect":"NoSchedule","key":"node-role.kubernetes.io/controlplane"}]
```

```
nano "${CONFIG_DIR}"/config/overlays/test/enforcer-tolerations-patch.yaml
```

修改 controller, manager, 和 enforcer 的 NodeSelector

```
nano "${CONFIG_DIR}"/config/overlays/test/node-selector-patch.yaml
```

範例輸出 : 

```
      nodeSelector:
        node-role.kubernetes.io/infra: ''
```

調整REST API Service Type

```
nano "${CONFIG_DIR}"/config/overlays/test/enable-REST-API.yaml
```

```
apiVersion: v1
kind: Service
metadata:
  name: neuvector-service-controller
  namespace: neuvector
spec:
  ports:
    - port: 10443
      name: controller
      protocol: TCP
  type: ClusterIP                      ## 修改這裡
  selector:
    app: neuvector-controller-pod
```

修改硬體資源要求和限制

```
nano "${CONFIG_DIR}"/config/overlays/test/resource-limit-patch.yaml
```

### Step10: 建立 Neuvector

```
oc apply -k $CONFIG_DIR/config/overlays/test/
```

檢查 Pod 運行狀態和 route

```
oc get pod,route
```

### Step11: 在本機測試 Neuvector 可否透過 https 正常連線

訪問 Neuvector web console

```
curl https://neuvector-route-webui-neuvector.apps.ocp4.example.com
```

螢幕輸出 :

```
This and all future requests should be directed to <a href="/index.html?v=2358c7ec6b">this URI</a>.
```

### Step12: Access Neuvector Web Console

```
oc get route
NAME                    HOST/PORT                                                         PATH   SERVICES                  PORT      TERMINATION   WILDCARD
neuvector-route-webui   neuvector-route-webui-neuvector.apps.ocp4.example.com          neuvector-service-webui   manager   passthrough   None
```

打開瀏覽器，輸入以下網址

```
https:// neuvector-route-webui-neuvector.apps.ocp4.example.com
```




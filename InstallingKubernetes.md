Set up  cluster commands

0. Install kubeadm, kubectl


    On master node
    ```
    sudo -E kubeadm --pod-network-cidr=10.244.0.0/16    --apiserver-advertise-address=<ip-of-master-vm>  init
    ```

    On each joining node
    ```
    kubeadm join  --token <token_that_was_given_by_output_of_above> <ip_of_master_vm>
    ```

1. Install network overlay

    ```
    kubectl apply -f  https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    ```


    Note, calico did not work for me, Flannel did.

2. Create persistent volumes

    ```
    kubectl apply -f  persistent_vol.yaml
    ```


    persistent_vol.yaml

    ```
    kind: PersistentVolume
    apiVersion: v1
    metadata:
      name: pvmongodb
      labels:
        type: local
    spec:
      capacity:
        storage: 10Gi
      accessModes:
        - ReadWriteOnce
      hostPath:
        path: "/bitnami/mongodb"
    ---

    kind: PersistentVolume
    apiVersion: v1
    metadata:
      name: pvrabbitmq
      labels:
        type: local
    spec:
      capacity:
        storage: 10Gi
      accessModes:
        - ReadWriteOnce
      hostPath:
        path: "/bitnami/rabbitmq"
    ```


3.  Setup RBAC for helm! Necessary on k8s 1.6+

    https://github.com/kubernetes/helm/blob/master/docs/service_accounts.md






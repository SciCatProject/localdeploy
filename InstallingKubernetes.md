# Set up cluster commands

1. Install kubeadm, kubectl

   On master node

   ```bash
   sudo -E kubeadm --pod-network-cidr=10.244.0.0/16    --apiserver-advertise-address=<ip-of-master-vm>  init
   ```

   On each joining node

   ```bash
   kubeadm join  --token <token_that_was_given_by_output_of_above> <ip_of_master_vm>
   ```

2. Install network overlay

   ```bash
   kubectl apply -f  https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
   ```

   Note, calico did not work for me, Flannel did.

3. Create persistent volumes

   ```bash
   kubectl apply -f  persistent_vol.yaml
   ```

   persistent_vol.yaml

   ```yaml
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

4. Setup RBAC for helm! Necessary on k8s 1.6+

   <https://github.com/kubernetes/helm/blob/master/docs/service_accounts.md>

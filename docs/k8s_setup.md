# k8s環境構築

## 手順

### 共通

1. VirtualBoxインストール
1. Vagrantインストール
1. gitインストール
1. 環境変数にプロキシ設定
1. `$ vagrant box add ubuntu/xeniel64`
1. `$ vagrant plugin install vagrant-proxyconf`

### node定義

1. vagrant\commonを必要なnode数コピー
1. それぞれのVagrantfileの以下を編集
    * `vm_name = "{node name}"`： `node name`を変更する。ex) master, worker1
    * `private_ip = "{ip}"`: `ip`を任意の値に変更する
    * `s.vm.network :forwarded_port, host: 2222, guest: 22`： `host: 2222`を変更する
    * `s.proxy`： プロキシを設定する
    * `{add ip}`：上記で設定したIPをすべて追加する

1. `$ vagrant up`

### [master node]

1. サーバにログイン
1. `$ sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf`

    ```text
    Environment="KUBELET_DNS_ARGS=--cluster-dns=10.244.0.10 --cluster-domain=cluster.local --node-ip={Vagrantfileで設定したIP}
    ```
1. `$ sudo systemctl daemon-reload`
1. `$ sudo systemctl restart kubelet`
1. `$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address={Vagrantfileで設定したIP} --service-cidr=10.244.0.0/16`
1. 以下のような結果が出力されるのでコピーする
    ```shell
    You can now join any number of machines by running the following on each node
    as root:
    kubeadm join {Vagrantfileで設定したIP}:6443 --token dx2bxh.fyym79hcykl1ryge --discovery-token-ca-cert-hash sha256:557fbf00b0865b2b0c76b24a742f485eb1e5eb49b01c2c142a34703d6fc7550c
    ```
1. `$ mkdir -p $HOME/.kube` * 1
1. `$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config` * 1
1. `$ sudo chown $(id -u):$(id -g) $HOME/.kube/config` * 1
1. 確認コマンド

    ```shell
    vagrant@master:~$ kubectl get node
    NAME      STATUS     ROLES     AGE       VERSION
    master    NotReady   master    5m        v1.10.3
    ```
1. `$ curl -O https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml`
1. `$ vi kube-flannel.yml`

    "--iface=enp0s8"をcommandに追記 * 2
    ```yml
    containers:
          - name: kube-flannel
            image: quay.io/coreos/flannel:v0.9.1-amd64
            command: [ "/opt/bin/flanneld", "--ip-masq", "--kube-subnet-mgr", "--iface=enp0s8" ]
    ```
1. `$ kubectl apply -f kube-flannel.yml`
1. 確認コマンド(5分ほど待ってから)
    ```shell
    vagrant@master:~$ kubectl get node
    NAME      STATUS    ROLES     AGE       VERSION
    master    Ready     master    26m       v1.10.3
    vagrant@master:~$ kubectl get po -o wide -n kube-system
    NAME                             READY     STATUS    RESTARTS   AGE       IP           NODE
    etcd-master                      1/1       Running   0          1m        <none>       master
    kube-apiserver-master            1/1       Running   0          1m        <none>       master
    kube-controller-manager-master   1/1       Running   0          1m        <none>       master
    kube-dns-86f4d74b45-skm6z        3/3       Running   0          2m        10.244.0.7   master
    kube-flannel-ds-75482            1/1       Running   0          1m        <none>       master
    kube-proxy-bcrhq                 1/1       Running   0          2m        <none>       master
    kube-scheduler-master            1/1       Running   0          1m        <none>       master
    ```

### [woker node]

1. `$ vagrant up`
1. `$ sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf`

    ```text
    Environment="KUBELET_DNS_ARGS=--cluster-dns=10.244.0.10 --cluster-domain=cluster.local --node-ip={Vagrantfileで設定したIP}"
    ```
1. `$ sudo systemctl daemon-reload`
1. `$ sudo systemctl restart kubelet`
1. 上記で実行した`kubeadm init`の結果を実行

    ex)

    ```shell
    kubeadm join {masterのVagrantfileで設定したIP}:6443 --token dx2bxh.fyym79hcykl1ryge --discovery-token-ca-cert-hash sha256:557fbf00b0865b2b0c76b24a742f485eb1e5eb49b01c2c142a34703d6fc7550c
    ```
1. [master node] `$ kubectl label node {worker1など任意の名前} node-role.kubernetes.io/node=`

## 課題

* vagrant box取得に半日かかる

## 備考

* \* 1はkubeadm init実行時にやれと指令が下るので従う

    ```shell
    Your Kubernetes master has initialized successfully!

    To start using your cluster, you need to run the following as a regular user:

      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```

* \* 2 enp0s8は固定値ではありません。Vagrantfileで定義したipと同じアダプターを`$ ifconfig`を利用して設定してください

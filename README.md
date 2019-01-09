# mujinhonya

## Run Docker

1. Dockerfileとmotion_trigger_action.pyを同階層に配置する
2. 下記のコマンドを実行し、Imageを作成する
```bash
sudo docker build ./ -t motion_trigger_action
```
3. コンテナを実行する
```bash
sudo docker build ./ -t motion_trigger_action
sudo docker run -it --rm --device /dev/gpiomem -v /opt/vc/lib:/opt/vc/lib motion_trigger_action
```
※`--privileged` ラズパイデバイスへのアクセス権限を与える  
※`-v /opt/vc/lib:/opt/vc/lib` ラズパイライブラリへのアクセス権限を与える
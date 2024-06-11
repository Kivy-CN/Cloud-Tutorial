要强制 `docker login` 使用 HTTP 而不是 HTTPS 连接到 Docker Registry，你需要配置 Docker 客户端以允许对特定的非安全注册中心进行明文 HTTP 通信。这通常通过修改 Docker 的配置文件 `daemon.json` 来实现。

请按照以下步骤操作：

1. **编辑 Docker 配置文件**：
   - 在 Linux 上，这个文件通常位于 `/etc/docker/daemon.json`。
   - 如果你使用的是 Docker Desktop for Windows 或 Mac，你可以通过 Docker Desktop 的设置界面访问 Docker Engine 的配置。

2. **添加非安全注册中心**：
   - 在 `daemon.json` 文件中，你需要添加或修改 `insecure-registries` 属性，包括你的注册中心的地址。例如：

     ```json
     {
       "insecure-registries" : ["192.168.56.105"]
     }
     ```

   - 如果文件已经包含其他配置，只需添加或修改 `insecure-registries` 部分即可。

3. **重启 Docker 服务**：
   - 在 Linux 上，你可以使用以下命令重启 Docker 服务：
     ```bash
     sudo systemctl restart docker
     ```
   - 如果你使用的是 Docker Desktop，重启 Docker Desktop 应用即可。

4. **尝试再次登录**：
   - 现在，你应该能够使用 HTTP 连接到你的 Docker Registry 了。使用以下命令（不需要指定 `http://`，因为 Docker 已经知道这是一个非安全的注册中心）：
     ```bash
     echo "Harbor12345" | docker login -u admin --password-stdin 192.168.56.105
     ```

请注意，使用 HTTP 连接到 Docker Registry 存在安全风险，因为你的认证信息和数据将以明文形式传输。只有在你确信网络环境安全且不对外暴露时，才应该使用这种配置。
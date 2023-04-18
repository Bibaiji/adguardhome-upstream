# AdGuardHome上游DNS服务器

在 [AdGuardHome](https://github.com/AdGuardTeam/AdGuardHome) 中使用 [Potterli20/dns-adguardhome-whitelist_full.txt
](https://github.com/Potterli20/file) 列表

* [使用步骤](#使用步骤)
    * [准备阶段](#准备阶段)
    * [获取并运行脚本](#获取并运行脚本)
    * [使用systemd timer服务实现自动化更新](#使用systemd-timer服务实现自动化更新)
* [优势与细节](#优势与细节)
    * [优势](#优势)
    * [文件介绍](#文件介绍)
    * [dnsmasq-china文件是如何运行的?](#dnsmasq-china是如何运行的？)
    * [强项](#强项)
* [其他](#其他)
    * [感谢](#感谢)
    * [注意事项](#注意事项)
    * [相关链接](#相关链接)

## 使用步骤

### 准备阶段

安装 [cURL](https://curl.se/) 和 [sed](https://www.gnu.org/software/sed/) 服务. 并且修改 `AdGuardHome.yaml` 配置:

- `upstream_dns_file` **必须填写为** `/usr/share/adguardhome.upstream`

<details><summary>这东西是干啥用的?</summary>

 `upstream_dns_file` 可以实现从文件中加载上游服务器.更多资讯详情可见 [AdGuardHome Wiki](https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration).

</details>

注意：大部分unix系统可以在`/opt/AdGuardHome` 或 `/root/AdGuardHome` 找到 `AdGuardHome.yaml` 文件, 在苹果macOS 你可以在 `/Applications/AdGuardHome` 中尝试寻找它, 或者直接使用 `find /* -name AdGuardHome.yaml` 命令进行查找.

### 获取并运行脚本

注意：这个步骤可能会让你的Adguard Home崩溃，请按需求备份它（我的已经崩溃好几次了）.

```
curl -o "/usr/local/bin/upstream.sh" "https://raw.githubusercontent.com/Bibaiji/adguardhome-upstream/master/upstream.sh"
chmod +x /usr/local/bin/upstream.sh
/usr/local/bin/upstream.sh
```

<details><summary>在non-systemd系统如何运行?</summary>

如果是在non-systemd系统上运行的Adguard Home,在[upstream.sh](./upstream.sh)中替换命令 `systemctl restart AdGuardHome`去重启AdGuardHome.例如openwrt: `sed -i "s|systemctl restart AdGuardHome|/etc/init.d/AdGuardHome|" /usr/local/bin/upstream`.

</details>

### 使用systemd timer服务实现自动化更新

模板中, 系统 **每天在5点**调用systemd timer服务.

```
curl -o "/etc/systemd/system/upstream.service" "https://gitlab.com/fernvenue/adguardhome-upstream/-/raw/master/upstream.service"
curl -o "/etc/systemd/system/upstream.timer" "https://gitlab.com/fernvenue/adguardhome-upstream/-/raw/master/upstream.timer"
systemctl enable upstream.timer
systemctl start upstream.timer
systemctl status upstream
```

<details><summary>在non-systemd系统如何运行?</summary>

你可以使用 [cron](https://en.wikipedia.org/wiki/Cron) 去自动化调用它, 例如添加 `0 5 * * * /usr/local/bin/upstream.sh` 到cron服务中.

</details>

## 优势和细节

### 优势

- 提高解析速度.
- 防止DNS污染.
- 白名单内域名采用国内大厂DNS服务器,其他域名采用google/cloudflare的DNS服务器.

### 文件介绍

- [LICENSE](./LICENSE): BSD3 条款许可证.
- [README.md](./README.md): 描述文件.
- [upstream.service](./upstream.service): Systemd服务模板.
- [upstream.timer](./upstream.timer): Systemd timer服务模板.
- [upstream.sh](./upstream.sh): 更新与转化脚本.
- [v4.conf](./v4.conf): 仅IPv4上游.
- [v6only.conf](./v6only.conf): 仅IPv6上游.
- [v6.conf](./v6.conf): 包含IPv4和IPv6上游.

### dnsmasq-china文件是如何运行的？

国内域名使用特定的上游DNS服务器加速链接，国外域名使用无污染、解析快的DNS服务器加速链接（我的服务器ping dns.google后仅有18ms的延迟）。此列表收集使用位于中国大陆的DNS服务器的域名，允许我们为它们使用一些不会破坏CDN或基于地理位置的结果的DNS服务器，同时对其他域使用加密和受信任的DNS服务器。

### 强项

一方面，对于DNS解析，当域名服务器在其他地域时，即使域名解析为中国大陆中的某个地址，我们在大多数情况下仍可以通过来自其他地域的DNS请求获得最快的解析，你可能会说一些DNS服务器有缓存，通常会带来很多问题。事实上，AdGuardHome 从 v0.107 开始就采用了乐观缓存，这比依赖上游DNS缓存要好得多。另一方面，许多测试表明，到处都有DNS污染。因此，推断结果是否被 IP 地址的位置污染不切实际。此列表仅包括使用中国大陆DNS服务器的域，这就是为什么它比任何其他类似方法更好的原因。

## 其他


### 感谢

此贴原帖来源于fernvenue/adguardhome-upstream，感谢大佬的项目使得我们可以用这个方法使用无污染上游DNS服务器文件，同时感谢Potterli20大佬提供的dns-adguardhome-whitelist文件，本文我对原帖内容进行了翻译操作并加入了自己的一些修改，由于本人不是计算机专业出身，对java语言、shell语言不熟悉，所有东西都还在学习当中，很多地方理解不是很透彻，不当之处，敬请诸君指出.


### 注意事项

- 由于国内链接Github稳定性太差，速度太慢，所以可以根据需要使用加速链接进行下载.
- 可根据需要修改v4.conf，v6.conf，v6only.conf以及upstream.sh文件.

### 相关链接

- 原帖: https://github.com/fernvenue/adguardhome-upstream
- Potterli20: https://github.com/Potterli20/file
- AdGuardHome: https://github.com/AdguardTeam/AdGuardHome
- felixonmars/dnsmasq-china-list: https://github.com/felixonmars/dnsmasq-china-list
- Google Public DNS: https://developers.google.com/speed/public-dns
- Cloudflare DNS: https://www.cloudflare.com/dns/
- TUNA DNS: https://tuna.moe/help/dns/


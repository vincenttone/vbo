# V-Bo
> 貌似现在这个api调用会遇到ssl证书问题，大家可以在68行左右的地方设置自己的证书地址。因为比较忙，所以这个api维护的少，见谅。
> 此项目代码不多，逻辑也简单，使用的是幽灵方法，并没有应用到实际应用中。所以最好只是用来学习，而不是实际应用。

## lib/weibo.rb
> 目前只有一个文件，方法也很少，一些简单封装。



- 实例化：`vbo = Vbo::Weibo.new`
- 首先通过设置环境变量`WB_APP_KEY`, `WB_APP_SECRET`, `WB_CALLBACK`来设置对应的微博app配置。你也可以通过`vbo.set_app_config`方法来设置对应的app key等你需要的配置。
- 可以通过调用 `vbo.get_authorize_url` 来获取用户需要授权的地址
- 用户授权后拿到code后，通过 `vbo.set_access_code` 设置CODE
- 通过 `vbo.get_access_token` 获取access token，您可以把它存入session或是其他地方，并检查其是否过期等...
- 通过`vbo.set_access_token access_token`来设置access token
- 调用api，调用时使用两个下划线代替url中的斜杠，前缀加入调用方法：比如调用`statuses/get_user_timeline`(get 方法)时使用`get__statuses__get_user_timeline`

## 关于DEMO
test.rb是使用vbo写的一个简单命令查看微博的测试文件。
gvbo.rb为gtk调用，头次写，见谅…
> 请将demo/lib.rb中的key和scret等信息修改成自己的

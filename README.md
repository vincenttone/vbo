# V-Bo

> 目前只有一个文件，方法也很少，一些简单封装，仅此而已。待完善。
> 请自行修改test.rb第9行为自己的配置进行调试
> 如果希望包装成gem包，请自行包装。
> 实际应用中可以根据喜好进行续权和token保存操作。


- 实例化：`vbo = Vbo::Weibo.new`
- 首先通过设置环境变量`WB_APP_KEY`, `WB_APP_SECRET`, `WB_CALLBACK`来设置对应的微博app配置。你也可以通过`vbo.set_app_config`方法来设置对应的app key等你需要的配置。
- 可以通过调用 `vbo.get_authorize_url` 来获取用户需要授权的地址
- 用户授权后拿到code后，通过 `vbo.set_access_code` 设置CODE
- 通过 `vbo.get_access_token` 获取access token，您可以把它存入session或是其他地方，并检查其是否过期等...
- 通过`vbo.set_access_token access_token`来设置access token
- 调用api，调用时使用两个下划线代替url中的斜杠，前缀加入调用方法：比如调用`statuses/get_user_timeline`(get 方法)时使用`get__statuses__get_user_timeline`

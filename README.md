# V-Bo
*自己闲来无事写的weibo api访问方法

> 目前只有一个文件，方法也很少，一些简单封装，仅此而已。待完善。

> - 首先通过设置环境变量*WB_APP_KEY*, *WB_APP_SECRET*, *WB_CALLBACK*来设置对应的微博api配置。\
当然你也可以通过修改文件中的常量来设置。

> vbo = Vbo::Weibo.new
> - 可以通过调用 *vbo.get_authorize_url* 来获取用户需要授权的地址
> - 用户授权后拿到code后，通过 *vbo.set_access_code* 设置CODE
> - 通过 *vbo.get_access_token* 获取access token
> - 调用api，调用时使用两个下划线代替url中的斜杠，前缀加入调用方法：
> 比如调用statuses/get_user_timeline(get 方法)时使用get__statuses__get_user_timeline

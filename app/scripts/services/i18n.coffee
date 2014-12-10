
angular.module('jm.i18next')

.config(['$provide', ($provide) ->
  $provide.decorator('$i18next', [
    '$delegate'
    ($i18next) ->
      # 参考自 RoR : http://guides.rubyonrails.org/i18n.html#error-message-scopes
      # 查找属性名、错误信息、格式的顺序如下：
      #   errors.models.[model].attributes.[attribute]
      #   errors.attributes.[attribute]
      #   errors.models.[model].messages.[message]
      #   errors.messages.[message]
      #   errors.models.[model].format
      #   errors.format
      trans = do ->
        exists = _.bind $.i18n.exists, $.i18n

        t = (key, options) ->
          return false unless key
          $.i18n.t key, options

        transWithNS = (transPath, opts) ->
          return t(transPath, opts) if exists transPath
          namespaces = $.i18n.options.ns.namespaces
          keyPath = _(namespaces).map((ns) -> "#{ns}:#{transPath}").filter(exists).first()
          t keyPath, opts

        (model, path, key, opts) ->
          if model? and path? and key?
            result = transWithNS "errors.models.#{model}.#{path}.#{key}", opts
            return result if result
          if model? and key?
            result = transWithNS "errors.models.#{model}.#{key}", opts
            return result if result
          if path? and key?
            result = transWithNS "errors.#{path}.#{key}", opts
            return result if result
          if path?
            result = transWithNS "errors.#{path}", opts
            return result if result
          false

      $i18next.model = (options = {}) ->
        {model, attribute, message} = options

        i18nModel = if model? then trans(model, null, 'name') else ''
        i18nAttr = if attribute? then trans(model, "attributes", attribute, model_name: i18nModel) else ''
        i18nMessage = if message? then trans(model, "messages", message, model_name: i18nModel) else ''
        tmpl = trans model, "format"

        data = _.extend {}, options, attribute: i18nAttr, message: i18nMessage
        _.template tmpl, data

      $i18next
  ])
])

angular.module('app.services')

.config([
  '$i18nextProvider'
  ($i18nextProvider) ->
    $i18nextProvider.options = {
      fallbackLng: 'zh-CN'
      useCookie: false
      useLocalStorage: false
      resGetPath: 'locales/__lng__/__ns__.json'
      ns:
        namespaces: ['base', 'copy']
        defaultNs: 'base'
    }
])

.filter('i18next', ['$i18next', ($i18next) ->
  filter = (string, options) ->
    $i18next string, angular.extend ns: 'base', options
  filter.$stateful = true
  filter
])

.factory('errorAlert', [
  '$i18next', '$dialog', '$q'
  ($i18next ,  $dialog ,  $q) ->
    alert = _.debounce (resp) ->
      if resp?.data?.errors? and _(resp.data.errors).first()?
        {resource, field, code} = _(resp.data.errors).first()
        opts = model: resource.toLowerCase(), attribute: field, message: code
      else if method = resp?.config?.method?.toLowerCase()
        opts = message: "#{method}_request_failed"
      else
        opts = message: 'request_failed'
      message = $i18next.model opts
      $dialog.alert {message, translate: false}
    , 500, leading: true

    # 这里的闭包是为了保证将来在生成函数时能够加入一些配置
    ->
      (resp) ->
        alert resp
        $q.reject resp
])

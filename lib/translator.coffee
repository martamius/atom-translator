TranslationService = require './translation-service'
{CompositeDisposable} = require 'atom'
RETRIEVE_LANGUAGES_ERROR = 'Cannot retrieve supported languages'
TRANSLATION_FAILED = 'Translation failed'

module.exports =


  languages: null,
  state: null,
  translationService: null,
  chineseRegex : /[^\x00-\x7F]+.*[^\x00-\x7F]*/g,
  configDefaults: {
    clientId: 'atom-translator',
    # Please don't abuse!
    clientSecret: '8i5GjrCXS+Iab9TcaKn7gNkTcjIJn2hxPr7pLFsRhQA=',
  },

  activate: (state) ->
    @state = state ? {}
    @translationService = new TranslationService(@configDefaults)
    atom.commands.add "atom-workspace", "translator:translate", => @translate()






  deactivate: ->




  provideLinter: () ->


    provider = {
      name: 'Translator',
      grammarScopes:  ['*'],
      scope: 'file',
      lintOnFly: false,
      lint: (textEditor) =>
        return new Promise ( (fulfill, reject) =>

          console.log "linting"
          messages = []
          matches = null
          translationArr = []
          for line, lineNum in textEditor.buffer.lines
            #console.log("line: "+line + "line Num:"+lineNum)

            while (matches = @chineseRegex.exec(line)) isnt null
              continue if matches[0] is ""
              translationArr.push(matches[0])
              message = {
                type: 'Info',
                text: 'Found translation',
                range:[[lineNum,matches.index], [lineNum,matches.index+matches[0].length]],
                filePath: textEditor.getPath(),
                severity: 'info'
              }
              messages.push(message)

          promise = @translationService.translateTextLines(
            translationArr,
            'zh-CHS',
            'en')
          promise.then(
            ((result) =>
              resultArray = result.split('\r\n')
              console.log(resultArray)
              for l,ln in resultArray
                messages[ln].text = l
              fulfill(messages);

            ),
            ((error) -> reject(error)) )

        )

    }
    return provider


  serialize: =>
    return @state

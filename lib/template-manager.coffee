
module.exports =
class TemplateManager

    constructor: (functions)->
        @functions = functions
        @psrMethodNames = atom.config.get 'php-getters-setters.camelCasedMethodNames'
        @ignoredTypeHints = atom.config.get 'php-getters-setters.doNotTypeHint'
        @getterTemplate = atom.config.get 'php-getters-setters.getterTemplate'
        @setterTemplate = atom.config.get 'php-getters-setters.setterTemplate'

    getCamelCasedVariableName: (variable) ->
        parts = variable.split('_')

        if null == parts
            parts = [variable]

        name = ''
        for part in parts
            name += part.charAt(0).toUpperCase() + part.slice 1

        return name

    getSnakeCasedVariableName: (variable) ->
        parts = variable.split('_')
        console.log parts
        if null == parts
            parts = [variable]

        name = ''
        for part in parts
            # parts = variable.match(/_(.*)|([A-Z][a-z]+)/g)
            name += '_' + part

        return name

    determineTypeHint: (type) ->
        if type in @ignoredTypeHints
            return ""

        return type

    processVariable: (variable) ->
        name = variable.name.replace(/^_/,'');
        return {
            name: name,
            type: variable.type,
            typeHint: @determineTypeHint(variable.type),
            description: variable.description || variable.name,
            methodScope: variable.methodScope || 'public'
        }

    getMethodName: (type, variableName) ->
        if @psrMethodNames
            return type + @getCamelCasedVariableName(variableName)

        return type + @getSnakeCasedVariableName(variableName)


    write: (template, methodType, variable) ->
        variable = @processVariable(variable)
        methodName  = @getMethodName(methodType, variable.name)

        if name in @functions
            console.log(methodName, 'function exists, not adding')
            return ''

        if variable.typeHint != ''
            variable.typeHint += ' '


        return template.replace /%description%/g, variable.description
         .replace /%methodName%/g, methodName
         .replace /%variable%/g, variable.name
         .replace /%type%/g, variable.type
         .replace /%scope%/g, variable.methodScope
         .replace /%typeHint%/g, variable.typeHint


    writeGetter : (variable) ->
        return @write(@getterTemplate, 'get', variable)

    writeSetter : (variable) ->
        return @write(@setterTemplate, 'set', variable)


        return
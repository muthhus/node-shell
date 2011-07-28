
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
Interface = require('readline').Interface

module.exports = (settings) ->
    # Validation
    throw new Error 'No shell provided' if not settings.shell
    # Only in shell mode
    return if not settings.shell.isShell
    # Persist readline history
    # Default to ~/.node_shell/{md5(workspace)}
    createDir = not settings.historyFile and not path.existsSync process.env['HOME'] + '/.node_shell'
    fs.mkdirSync process.env['HOME'] + '/.node_shell', 0700 if createDir
    settings.historyFile ?=
        process.env['HOME'] + 
        '/.node_shell/' + 
        crypto.createHash('md5').update(settings.shell.project_dir).digest('hex')
    if path.existsSync settings.historyFile
        try
            settings.shell.interface.history = JSON.parse fs.readFileSync(settings.historyFile, 'utf8')
        catch e
            settings.shell.styles.red('Corrupted history file').ln()
    historyStream = fs.createWriteStream settings.historyFile, {flag: 'w'}
    Interface.prototype._addHistory = ((parent) -> ->
        if this.history.length
            buffer = new Buffer JSON.stringify( this.history )
            fs.write historyStream.fd, buffer, 0, buffer.length, 0
        parent.apply this, arguments
    ) Interface.prototype._addHistory
    null
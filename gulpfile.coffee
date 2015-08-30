gulp                = require 'gulp'
gulpLoadPlugins     = require 'gulp-load-plugins'
gutil               = require 'gutil'

P                   = gulpLoadPlugins()

gulp.task 'jsMain', ->

    gulp.src [
        './main.coffee'
    ]
    .pipe P.plumber()
    .pipe P.coffee
        bare: true
    .on 'error', gutil.log
    #.pipe P.jsmin()
    .on 'error', (err) ->
        gutil.log '[JS ERROR]'
        gutil.log err
        return
    .pipe gulp.dest('./')

gulp.task 'jsDom', ->

    gulp.src [
        './node/SimpleDomain.coffee'
    ]
    .pipe P.plumber()
    .pipe P.coffee
        bare: true
    .on 'error', gutil.log
    #.pipe P.jsmin()
    .on 'error', (err) ->
        gutil.log '[JS ERROR]'
        gutil.log err
        return
    .pipe gulp.dest('./node/')

gulp.task 'less', ->

    gulp.src [
        'main.less'
    ]
    .pipe P.plumber()
    .pipe P.less()
    .pipe gulp.dest('./')




gulp.task 'watch', [
    'jsMain'
    'jsDom'
    'less'
], ->

    gulp.watch './main.coffee', [ 'jsMain' ]
    .on 'change', (event) ->
        gutil.log "[JS #{event.type}]: #{event.path}"
        return

    gulp.watch './node/SimpleDomain.coffee', [ 'jsDom' ]
    .on 'change', (event) ->
        gutil.log "[JS #{event.type}]: #{event.path}"
        return

    gulp.watch './main.less', ['less']
    .on 'change', (event)->
        gutil.log "[LESS #{event.type}]: #{event.path}"
        return

    gutil.log 'Watcher ready!'
    return

gulp.task 'default', [
  'watch'
]

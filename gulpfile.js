var gulp = require('gulp');
var elm = require('gulp-elm');
var gutil = require('gulp-util');

gulp.task('elm-init', elm.init);
 
gulp.task('elm', ['elm-init'], function(){
    return gulp.src('src/*.elm')
        .pipe(elm()).on('error', errorHandler)
        .pipe(gulp.dest('dist/'));
});
 
gulp.task('elm-bundle', ['elm-init'], function(){
    return gulp.src('src/*.elm')
        .pipe(elm.bundle('bundle.js')).on('error', errorHandler)
        .pipe(gulp.dest('dist/'));
});

/**
 * function errorHandler(err)
 *
 * @param err
 */
function errorHandler(err){
	gutil.beep();
	gutil.log(gutil.colors.red('Error: '), err.message);
	this.emit('end');
}
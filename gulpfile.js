var gulp = require('gulp');
var elm = require('gulp-elm');
var gutil = require('gulp-util');
var connect = require('gulp-connect');

// File paths
var paths = {
  dest: 'dist',
  elm: 'src/*.elm' 
};

// Init Elm
gulp.task('elm-init', elm.init);
 
// Compile Elm to HTML
gulp.task('elm', ['elm-init'], function(){
    return gulp.src(paths.elm)
        .pipe(elm({ filetype: 'html'})).on('error', errorHandler)
        .pipe(gulp.dest(paths.dest));
});

// Bundle Elm into single file
gulp.task('elm-bundle', ['elm-init'], function(){
    return gulp.src(paths.elm)
        .pipe(elm.bundle('bundle.html')).on('error', errorHandler)
        .pipe(gulp.dest('dist/'));
});

// Watch for changes and compile Elm
gulp.task('watch', function() {
    gulp.watch(paths.elm, ['elm']);
});

// Local server
gulp.task('connect', function() {
    connect.server({
        root: 'dist',
        port: 3000
    });
});

// Error handling (beep and echo error message)
function errorHandler(err){
	gutil.beep();
	gutil.log(gutil.colors.red('Error: '), err.message);
	this.emit('end');
}

// Main gulp tasks
gulp.task('build', ['elm']);
gulp.task('default', ['connect', 'build', 'watch']);
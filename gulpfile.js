var gulp = require('gulp');
var elm = require('gulp-elm');
var gutil = require('gulp-util');
var plumber = require('gulp-plumber');
var connect = require('gulp-connect');

// File paths
var paths = {
  dest: 'dist',
  elm: 'src/*.elm',
  static: 'src/*.{html,css}'
};

// Init Elm
gulp.task('elm-init', elm.init);
 
// Compile Elm to HTML
gulp.task('elm', ['elm-init'], function(){
    return gulp.src(paths.elm)
        .pipe(plumber())
        .pipe(elm()).on('error', errorHandler)
        .pipe(gulp.dest(paths.dest));
});

// Move static assets to dist
gulp.task('static', function() {
    return gulp.src(paths.static)
        .pipe(plumber())
        .pipe(gulp.dest(paths.dest));
});

// Bundle Elm into single file
gulp.task('elm-bundle', ['elm-init'], function(){
    return gulp.src(paths.elm)
        .pipe(elm.bundle('bundle.html')).on('error', errorHandler)
        .pipe(gulp.dest('dist/'));
});

// Watch for changes and compile
gulp.task('watch', function() {
    gulp.watch(paths.elm, ['elm']);
    gulp.watch(paths.static, ['static']);
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
gulp.task('build', ['elm', 'static']);
gulp.task('default', ['connect', 'build', 'watch']);
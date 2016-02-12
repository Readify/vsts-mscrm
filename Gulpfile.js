var gulp = require('gulp');
var exec = require('child_process').exec;
var minimist = require('minimist');
var semver = require('semver');

// Default version data. Should be replaced as soon as the get-version task runs.
var version = {
    "Major": 0,
    "Minor": 0,
    "Patch": 1,
    "MajorMinorPatch": "0.0.1",
};

var args = minimist(process.argv);

gulp.task('get-version', function (callback) {
    if (args.overrideversion && semver.valid(args.overrideversion)) {
        version.MajorMinorPatch = args.overrideversion;
        version.Major = semver.major(args.overrideversion);
        version.Minor = semver.minor(args.overrideversion);
        version.Patch = semver.patch(args.overrideversion);
        callback();
    } else {
        exec('gitversion', function(err, stdout, stderr) { 
            version = JSON.parse(stdout);
            callback(err);
        });
    }
});

gulp.task('stamp-manifest', ['get-version'], function (callback) {
    callback();
});

gulp.task('stamp-export-solution-task', ['get-version'], function (callback) {
    callback(); 
});

gulp.task('stamp-import-solution-task', ['get-version'], function (callback) {
    callback(); 
});

gulp.task('stamp-pack-solution-task', ['get-version'], function (callback) {
    callback(); 
});

gulp.task('stamp-unpack-solution-task', ['get-version'], function (callback) {
    callback(); 
});

gulp.task('stamp', ['stamp-manifest', 'stamp-export-solution-task', 'stamp-import-solution-task', 'stamp-pack-solution-task', 'stamp-unpack-solution-task'], function(callback) {
    callback();
});

gulp.task('pack', ['stamp'], function (callback) {
    callback();
});

gulp.task('default', ['pack']);